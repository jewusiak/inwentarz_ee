import 'package:flutter/material.dart';
import 'package:inwentarz_ee/nav_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: NavDrawer()),
      appBar: AppBar(
        title: Text("Inwentarz EE"),
      ),
      body: Center(
        child: Image.asset("assets/images/nav-bg.png"),
      ),
    );
  }
}
