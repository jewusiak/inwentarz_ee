import 'package:flutter/material.dart';
import 'package:inwentarz_ee/data_access/session_data.dart';
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
      appBar: AppBar(
        title: Text("Zaloguj się"),
      ),
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
                  border: OutlineInputBorder(),
                ),
                controller: _loginController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofocus: true,
                autofillHints: [AutofillHints.email],
                cursorHeight: 20,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Hasło",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) => login(_loginController.value.text,
                    _passwordController.value.text, context),
                autofillHints: [AutofillHints.password],
                cursorHeight: 20,
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () => login(_loginController.value.text,
                      _passwordController.value.text, context),
                  child: Text("Zaloguj się")),
            ],
          ),
        ),
      ),
    );
  }
}

Future login(String email, String password, context) async {
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Uzupełnij dane.')));
    return;
  }

  try {
    showCircularProgressIndicatorDialog(context);
    await SessionData().authenticate(email.trim(), password.trim());
    Navigator.of(context).pop();
  } on Exception catch (e) {
    if (e.toString().contains("401"))
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nieprawidłowe dane logowania.')));
    else if (e.toString().contains("403"))
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Konto nieaktywne. Skontaktuj się z administratorem.')));
  }
  Navigator.of(context).pop();
}
