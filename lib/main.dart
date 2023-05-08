import 'package:flutter/material.dart';
import 'package:inwentarz_ee/data_access/session_data.dart';
import 'package:inwentarz_ee/views/home_page.dart';
import 'package:inwentarz_ee/views/login_page.dart';
import 'package:inwentarz_ee/views/qr_scanner.dart';
import 'package:inwentarz_ee/views/search_page.dart';

import 'views/create_equipment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SessionData().checkAuthenticationStatus();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SessionData().checkAuthenticationStatus(),
      builder: (context, snapshot) => snapshot.hasData
          ? MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.amber,
              ),
              routes: {
                '/': (context) => HomePage(),
                '/login': (context) => LoginPage(),
                '/qrscanner': (context) => QRScannerPage(),
                '/search': (context) => SearchPage(),
                '/new_equipment': (context) => CreateOrEditEquipmentPage(),
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
