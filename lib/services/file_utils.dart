import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FileUtils {
  static Future<bool> checkStoragePermissions(context) async {
    if(Platform.isAndroid) return true;
    var permissionStatus = await Permission.storage.request();

    if (permissionStatus.isGranted) return true;

    if (permissionStatus.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Potrzebujemy dostępu"),
          content: Text("Aby móc dodać załączniki, należy uzyskać dostęp do plików. Przejdź do ustawień i ręcznie włącz dostęp do plików."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Anuluj")),
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: Text("Aktywuj")),
          ],
        ),
      );
    } else if (permissionStatus.isDenied) {
      bool _showAgain = false;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Potrzebujemy dostępu"),
          content: Text("Aby móc dodać załączniki, należy uzyskać dostęp do plików."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Anuluj")),
            TextButton(
                onPressed: () {
                  _showAgain = true;
                  Navigator.pop(context);
                },
                child: Text("Aktywuj")),
          ],
        ),
      );
      if (_showAgain) return checkStoragePermissions(context);
    }
    return false;
  }

  static Future<List<String>> uploadFilesToFirebase(List<String> attachmentPaths, String prefix) async {
    List<String> urls=[];
    for (int i = 0; i < attachmentPaths.length; i++){
      String filePath = attachmentPaths[i];
      var uploadedFile = await FirebaseStorage.instance.ref().child('files/${prefix}_$i${extension(filePath)}').putFile(File(filePath));
      urls.add(await uploadedFile.ref.getDownloadURL());
    }
    return urls;
  }
}
