import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inwentarz_ee/services/db_utils.dart';

class EquipmentDetailsPage extends StatelessWidget {
  EquipmentDetailsPage(this.equipmentId, {Key? key}) : super(key: key);

  String equipmentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Szczegóły aparatury"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.doc('equipment/${equipmentId}').get().asStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView(
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        snapshot.data!.get('name'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Container(
                      width: 200,
                      height: 200,
                      child: DBUtils.getFromData(snapshot.data, 'main_image') != null
                            ? Image.network(DBUtils.getFromData(snapshot.data, 'main_image'), fit: BoxFit.contain,)
                            : Image.asset("assets/images/default-camera.jpeg", fit: BoxFit.contain),
                    ),
                  ],
                )
              ],
            );
          }
        },
      ),
    );
  }
}
