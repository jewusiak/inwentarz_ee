import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inwentarz_ee/widgets/circular_indicator_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //drawer: Drawer(child: NavDrawer()),
        appBar: AppBar(
          title: Center(child: Text("Inwentarz EE")),
        ),
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snapshot) {
              return Stack(
                children: [
                  Positioned(
                    top: -200,
                    height: 350,
                    width: 350,
                    left: -200,
                    child: ClipOval(
                      child: FittedBox(
                        child: Image.asset("assets/images/nav-bg.png"),
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 47.48,
                    left: 47.48,
                    child: Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: ClipOval(
                              child: snapshot.hasData && snapshot.data!.photoURL != null
                                  ? Image.network(
                                      snapshot.data!.photoURL!,
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                    )
                                  : Image.asset("assets/images/default-avatar.png"),
                            ),
                          )),
                    ),
                  ),
                  Positioned(
                      top: 0,
                      left: 150,
                      right: 0,
                      height: 150,
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                snapshot.hasData
                                    ? (snapshot.data!.displayName != null && snapshot.data!.displayName!.isNotEmpty
                                        ? snapshot.data!.displayName!
                                        : snapshot.data!.email!)
                                    : "Niezalogowany",
                                style: GoogleFonts.raleway(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87),
                              ),
                            ),
                          ),
                          GestureDetector(
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
                                try {
                                  showCircularProgressIndicatorDialog(context);
                                  await Future.delayed(Duration(milliseconds: 1500)); //TODO: remove
                                  await FirebaseAuth.instance.signOut();
                                } catch (e) {
                                  print(e);
                                }
                                Navigator.of(context).pop();
                              } else {
                                Navigator.pushNamed(context, '/login');
                              }
                            },
                          ),
                        ],
                      )),
                  Positioned(
                    top: 150,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: Center(
                          child: SizedBox(
                            width: 250,
                            height: 250,
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                homePageIcon(context, '/search', Theme.of(context).primaryColor, Icons.search),
                                homePageIcon(context, '/qrscanner', Theme.of(context).primaryColor, Icons.qr_code),
                                homePageIcon(context, '/new_equipment', Theme.of(context).primaryColor, Icons.add),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }));
  }
}
//
// Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
//                     child: FittedBox(
//                         child: Text(
//                           snapshot.hasData ?  snapshot.data!.email! : "Niezalogowany",
//                           style: GoogleFonts.raleway(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87),
//                         ),
//                         fit: BoxFit.scaleDown),
//                   ),
//

Widget homePageIcon(context, String route, Color backgroundColor, IconData icon) => Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(30)),
      child: IconButton(
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(
          icon,
          size: 70,
        ),
      ),
    );
