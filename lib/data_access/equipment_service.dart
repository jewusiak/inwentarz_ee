import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inwentarz_ee/data_access/models/base_url.dart';
import 'package:inwentarz_ee/data_access/models/equipment.dart';
import 'package:inwentarz_ee/data_access/session_data.dart';
import 'package:sn_progress_dialog/options/completed.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class EquipmentService {
  static Future<int> createEquipment(
      String name,
      String location,
      String description,
      DateTime? nextCalibration,
      List<String> attachmentPaths,
      List<String> fileNames,
      context) async {
    ProgressDialog progressDialog = ProgressDialog(context: context);

    progressDialog.show(
      msg: "Tworzenie sprzętu",
      msgFontWeight: FontWeight.normal,
      completed: Completed(completedMsg: "Zakończono!", completionDelay: 1500),
      max: 1,
      valueColor: Colors.transparent,
    );

    var sessionToken = SessionData().token;

    var response = await http.post(
        Uri.https("${BaseUrl.baseHttpsUrl}/equipment"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $sessionToken"
        },
        body: jsonEncode({
          "name": name,
          "location": location,
          "description": description,
          "nextCalibration": nextCalibration?.toIso8601String()
        }));

    if (response.statusCode != 201)
      throw Exception("Could not create equipment! (${response.statusCode})");
    var equipmentId = jsonDecode(utf8.decode(response.bodyBytes))['id']!;

    await uploadAttachmentsAndAttachToEquipment(
        sessionToken, attachmentPaths, progressDialog, fileNames, equipmentId);
    progressDialog.update(value: 1);
    await Future.delayed(Duration(milliseconds: 1600));
    return equipmentId;
  }

  static Future<void> uploadAttachmentsAndAttachToEquipment(
      String sessionToken,
      List<String> attachmentPaths,
      ProgressDialog progressDialog,
      List<String> fileNames,
      equipmentId) async {
    var uploadUri = Uri.https(BaseUrl.authority, "/attachment");

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
          Uri.https(BaseUrl.authority,
              "/attachment/${attachmentId}/assign_equipment/${equipmentId}"),
          headers: {"Authorization": "Bearer $sessionToken"});
      if (joinResponse.statusCode != 200)
        throw Exception(
            "Failed to attach to equipment (${joinResponse.statusCode}).");
    }
  }

  static Future<int> updateEquipment(
      int id,
      String name,
      String location,
      String description,
      DateTime? nextCalibration,
      List<String> attachmentPaths,
      List<String> fileNames,
      context) async {
    ProgressDialog progressDialog = ProgressDialog(context: context);

    progressDialog.show(
      msg: "Aktualizowanie sprzętu",
      msgFontWeight: FontWeight.normal,
      completed: Completed(completedMsg: "Zakończono!", completionDelay: 1500),
      max: 1,
      valueColor: Colors.transparent,
    );

    var sessionToken = SessionData().token;

    var response = await http.put(
        Uri.https(BaseUrl.authority, "/equipment/${id}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $sessionToken"
        },
        body: jsonEncode({
          "name": name,
          "location": location,
          "description": description,
          "nextCalibration": nextCalibration?.toIso8601String()
        }));

    if (response.statusCode != 200)
      throw Exception("Could not update equipment! (${response.statusCode})");
    var equipmentId = jsonDecode(utf8.decode(response.bodyBytes))['id']!;

    await uploadAttachmentsAndAttachToEquipment(
        sessionToken, attachmentPaths, progressDialog, fileNames, id);

    progressDialog.update(value: 1);
    await Future.delayed(Duration(milliseconds: 1600));
    return equipmentId;
  }

  static Future<Equipment> getEquipment(int equipmentId) async {
    var response = await http
        .get(Uri.https(BaseUrl.authority, "/equipment/getbyid/$equipmentId"));
    if (response.statusCode != 200)
      throw Exception("Couldn't download equipment (${response.statusCode}).");
    return Equipment.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  static Future<Equipment> getEquipmentByUuid(String uuid) async {
    var response = await http
        .get(Uri.https(BaseUrl.authority, "/equipment/getbyqrcode/$uuid"));
    if (response.statusCode != 200)
      throw Exception("Couldn't download equipment (${response.statusCode}).");
    return Equipment.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  static Future<void> removeEquipment(int id) async {
    var response = await http.delete(
      Uri.https(BaseUrl.authority, "/equipment/$id"),
      headers: {"Authorization": "Bearer ${SessionData().token}"},
    );
    if (response.statusCode != 204)
      throw Exception("Couldn't remove equipment (${response.statusCode}).");
  }

  static Future<Uint8List> generateQrCodeAsBytes(int id) async {
    var response = await http.get(
      Uri.https(BaseUrl.authority, "/equipment/genqrcode/$id"),
      headers: {"Authorization": "Bearer ${SessionData().token}"},
    );
    if (response.statusCode != 200)
      throw Exception(
          "Couldn't download QR core for equipment (${response.statusCode}).");
    return response.bodyBytes;
  }

  static Future<List<Equipment>> doSearch(
      String id, String location, String name, bool searchInDescription) async {
    Map<String, String> queryParams = {};
    if (id.isNotEmpty) queryParams.addAll({'id': id});
    if (location.isNotEmpty) queryParams.addAll({'location': location});
    if (name.isNotEmpty) queryParams.addAll({'name': name});
    queryParams.addAll({'searchInDescription': searchInDescription.toString()});
    var response = await http
        .get(Uri.https(BaseUrl.authority, "/equipment/search", queryParams));
    if (response.statusCode != 200)
      throw Exception(
          "Couldn't search through equipment (${response.statusCode}).");
    return (jsonDecode(utf8.decode(response.bodyBytes)) as List)
        .map((e) => Equipment.fromJson(e))
        .toList();
  }

  static Future<List<Equipment>> getAll() async {
    var response =
        await http.get(Uri.https(BaseUrl.authority, "/equipment/getall"));
    if (response.statusCode != 200)
      throw Exception("Couldn't get all equipment (${response.statusCode}).");
    return (jsonDecode(utf8.decode(response.bodyBytes)) as List)
        .map((e) => Equipment.fromJson(e))
        .toList();
  }
}
