import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          height: 200,
          left: 0,
          right: 0,
          child: FittedBox(
            child: Image.asset("assets/images/nav-bg.png"),
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
          ),
        ),
        Positioned(
          top: 150,
          left: 0,
          right: 0,
          child: Align(
            child: CircleAvatar(
              radius:50,
              backgroundColor: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ClipOval( child: Image.asset("assets/images/grzes.jpg"),),
              )
            ),
            alignment: Alignment.center,
          ),
        )
      ],
    );
  }
}
