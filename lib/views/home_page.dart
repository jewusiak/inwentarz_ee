import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inwentarz_ee/data_access/session_data.dart';
import 'package:inwentarz_ee/widgets/circular_indicator_dialog.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: SessionData(),
      child: Consumer<SessionData>(
        builder: (context, instance, child) => Scaffold(
          appBar: AppBar(
            title: Center(child: Text("Inwentarz EE")),
          ),
          body: Stack(
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
                        child: Image.asset("assets/images/default-avatar.png"),
                      ),
                    ),
                  ),
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
                            instance.authenticated
                                ? (instance.userProfile.displayName ??
                                    instance.userProfile.email)
                                : "Niezalogowany",
                            style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: Colors.black87),
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    instance.authenticated
                                        ? "Wyloguj się"
                                        : "Zaloguj się",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            Theme.of(context).primaryColor,
                                        decorationThickness: 2,
                                        fontSize: 20)),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.arrow_forward,
                                )
                              ]),
                        ),
                        onTap: () async {
                          if (instance.authenticated) {
                            try {
                              showCircularProgressIndicatorDialog(context);
                              await Future.delayed(
                                  Duration(milliseconds: 1500)); //TODO: remove
                              await instance.logout();
                            } catch (e) {
                              print(e);
                            }
                            Navigator.of(context).pop();
                            setState(() {});
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
                            homePageIcon(
                                context, '/search', Icons.search, true),
                            homePageIcon(
                                context, '/qrscanner', Icons.qr_code, true),
                            homePageIcon(context, '/new_equipment', Icons.add,
                                instance.authenticated),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget homePageIcon(context, String route, IconData icon, bool enabled) =>
    Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
          color: enabled
              ? Theme.of(context).primaryColor
              : Theme.of(context).disabledColor,
          borderRadius: BorderRadius.circular(30)),
      child: IconButton(
        onPressed: () {
          if (enabled)
            Navigator.pushNamed(context, route);
          else
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Zaloguj się."),
              duration: Duration(milliseconds: 500),
            ));
        },
        icon: Icon(
          icon,
          size: 70,
          color: enabled ? null : Colors.black45,
        ),
      ),
    );
