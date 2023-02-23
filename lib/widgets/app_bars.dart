import 'package:flutter/material.dart';

class LeadingPopAppBar extends AppBar {
  LeadingPopAppBar({Key? key, required title, required nav}): super(key: key,
        title: Text(title),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new), onPressed: () => nav.pop(),),
      );

}
