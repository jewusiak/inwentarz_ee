import 'package:cloud_firestore/cloud_firestore.dart';

import 'file_utils.dart';

class DBUtils {
  static Future createEquipmentAndUploadAttachments(
      String name, String location, String description, DateTime? nextCalibration, List<String> _attachmentPaths, String? mainImagePath) async {
    var collection = FirebaseFirestore.instance.collection("equipment");
    var docReference = await collection.add({'name': name, 'location': location, 'description': description, 'next_calibration': nextCalibration});

    List<String> attachmentUrls = await FileUtils.uploadFilesToFirebase(_attachmentPaths, docReference.id);
    if (mainImagePath != null) {
      var mainImageUrl = (await FileUtils.uploadFilesToFirebase([mainImagePath], docReference.id))[0];
      docReference.set({'main_image': mainImageUrl}, SetOptions(merge: true));
    }
    docReference.set({'attachments': attachmentUrls}, SetOptions(merge: true));
  }

  static dynamic getFromData(data, name) {
    try {
      return data!.get(name);
    } catch (e) {}
    return null;
  }
}
