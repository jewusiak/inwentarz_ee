import 'package:flutter/material.dart';

class CreateEquipmentPage extends StatelessWidget {
  const CreateEquipmentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Dodaj nowy sprzęt"),),body: Center(child: Text("new lab equipment"),));
  }
}
