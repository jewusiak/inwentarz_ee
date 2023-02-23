import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inwentarz_ee/widgets/app_bars.dart';
import 'package:inwentarz_ee/widgets/circular_indicator_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _state = 0; //0 - before, 1 - logging in, 2 - error

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeadingPopAppBar(title: "Zaloguj się", nav: Navigator.of(context)),
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "Twój email",
                ),
                controller: _loginController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofocus: true,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: "Hasło"),
                keyboardType: TextInputType.emailAddress,
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) => login(_loginController.value.text, _passwordController.value.text, context),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () => login(_loginController.value.text, _passwordController.value.text, context), child: Text("Zaloguj się")),
            ],
          ),
        ),
      ),
    );
  }
}

Future login(String email, String password, context) async {
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usupełnij dane.')));
    return;
  }

  showCircularProgressIndicatorDialog(context);

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.trim(), password: password);
    Navigator.of(context).pop();
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nieprawidłowe dane logowania.')));
    }
  }
    Navigator.of(context).pop();
}
