import 'package:flutter/material.dart';
import 'package:inwentarz_ee/views/equipment_details_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EquipmentDetailsPage("25XTSFbqhykLludGe1Uw");
    return Scaffold(appBar: AppBar(title: Text("Wyszukaj po nazwie"),),body: Center(child: Text("search"),));
  }
}
