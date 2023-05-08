import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inwentarz_ee/data_access/models/base_url.dart';
import 'package:inwentarz_ee/data_access/models/event.dart';
import 'package:inwentarz_ee/data_access/session_data.dart';
import 'package:sn_progress_dialog/options/completed.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class EventService {
  static Future<void> removeEvent(int id) async {
    var response = await http.delete(
      Uri.parse(BaseUrl.baseHttpsUrl + "/events/" + id.toString()),
      headers: {"Authorization": "Bearer ${SessionData().token}"},
    );
    if (response.statusCode != 204)
      throw Exception("Couldn't remove event (${response.statusCode}).");
  }

  static Future<int> createEvent(
      int equipmentId,
      String comment,
      EventType eventType,
      List<String> attachmentPaths,
      List<String> fileNames,
      context) async {
    ProgressDialog progressDialog = ProgressDialog(context: context);

    progressDialog.show(
      msg: "Tworzenie zdarzenia",
      msgFontWeight: FontWeight.normal,
      completed: Completed(completedMsg: "Zakończono!", completionDelay: 1500),
      max: 1,
      valueColor: Colors.transparent,
    );

    var sessionToken = SessionData().token;

    var response = await http.post(Uri.parse("${BaseUrl.baseHttpsUrl}/events"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $sessionToken"
        },
        body: jsonEncode({"comment": comment, "eventType": eventType.name}));

    if (response.statusCode != 201)
      throw Exception("Could not create event! (${response.statusCode})");
    var eventId = jsonDecode(utf8.decode(response.bodyBytes))['id']!;

    await uploadAttachmentsAndAttachToEvent(
        sessionToken, attachmentPaths, progressDialog, fileNames, eventId);

    var equipmentJoinResponse = await http.post(
        Uri.parse(
            "${BaseUrl.baseHttpsUrl}/events/${eventId}/assign_equipment/${equipmentId}"),
        headers: {"Authorization": "Bearer $sessionToken"});
    if (equipmentJoinResponse.statusCode != 200)
      throw Exception(
          "Failed to attach event to equipment (${equipmentJoinResponse.statusCode}).");

    progressDialog.update(value: 1);
    await Future.delayed(Duration(milliseconds: 1600));
    return eventId;
  }

  static Future<void> uploadAttachmentsAndAttachToEvent(
      String sessionToken,
      List<String> attachmentPaths,
      ProgressDialog progressDialog,
      List<String> fileNames,
      int eventId) async {
    var uploadUri = Uri.parse("${BaseUrl.baseHttpsUrl}/attachment");

    var headers = {
      "Content-Type": "multipart/form-data",
      "Authorization": "Bearer $sessionToken"
    };

    var length = attachmentPaths.length;
    for (int i = 0; i < length; i++) {
      progressDialog.update(msg: "Wysyłanie załącznika ${i + 1}/${length}");
      var attachmentPath = attachmentPaths[i];
      var request = http.MultipartRequest("POST", uploadUri);
      request.headers.addAll(headers);
      request.files.add(http.MultipartFile.fromBytes(
        "file",
        await File(attachmentPath).readAsBytes(),
        filename: fileNames[i],
      ));
      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode != 201)
        throw new Exception("Failed to upload a file: ${fileNames[i]}");
      String attachmentId = jsonDecode(utf8.decode(response.bodyBytes))['id']!;

      var joinResponse = await http.post(
          Uri.parse(
              "${BaseUrl.baseHttpsUrl}/attachment/${attachmentId}/assign_event/${eventId}"),
          headers: {"Authorization": "Bearer $sessionToken"});
      if (joinResponse.statusCode != 200)
        throw Exception(
            "Failed to attach to event (${joinResponse.statusCode}).");
    }
  }
}
