import 'package:flutter/material.dart';
import 'package:inwentarz_ee/widgets/app_bars.dart';
import 'package:inwentarz_ee/widgets/nav_drawer.dart';

class TestPage extends StatelessWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeadingPopAppBar(title: "Test page",nav: Navigator.of(context)),
      drawer: NavDrawer(),
      body: Center(child: Text("Textsss")),
    );
  }
}
