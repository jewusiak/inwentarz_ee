import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'circular_indicator_dialog.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
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
                alignment: Alignment.center,
                child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: ClipOval(
                        child: snapshot.hasData && snapshot.data!.photoURL != null ? Image.network(snapshot.data!.photoURL!) : Image.asset("assets/images/default-avatar.png"),
                      ),
                    )),
              ),
            ),
            Positioned(
              top: 250,
              bottom: 0,
              left: 0,
              right: 0,
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: FittedBox(
                        child: Text(
                          snapshot.hasData ?  snapshot.data!.email! : "Niezalogowany",
                          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87),
                        ),
                        fit: BoxFit.scaleDown),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.abc,
                    ),
                    title: const Text('Page 2'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/testpage');
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 30,
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Text(snapshot.hasData ? "Wyloguj się" : "Zaloguj się",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                            decorationColor: Theme.of(context).primaryColor,
                            decorationThickness: 2,
                            fontSize: 20)),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward,
                    )
                  ]),
                ),
                onTap: () async {
                  if (snapshot.hasData) {
                    try{
                        showCircularProgressIndicatorDialog(context);
                        await Future.delayed(Duration(milliseconds: 1500)); //TODO: remove
                        await FirebaseAuth.instance.signOut();
                      }catch(e){
                        print(e);
                        }
                      Navigator.of(context).pop();
                    } else {
                    Navigator.popAndPushNamed(context, '/login');
                  }
                },
              ),
            )
          ],
        );
      }
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text("Zaloguj się"),
      SizedBox(width: 5),
      Icon(
        Icons.arrow_forward,
      )
    ]);
  }
}
