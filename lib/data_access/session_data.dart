import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:inwentarz_ee/data_access/models/base_url.dart';
import 'package:inwentarz_ee/data_access/models/user_profile.dart';

class SessionData extends ChangeNotifier {
  static SessionData _instance = SessionData._internal();

  factory SessionData() {
    return _instance;
  }

  SessionData._internal() {
    _secureStorage = const FlutterSecureStorage();
    _authenticated = false;
  }

  FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _token;

  String get token => _token!;

  bool? _authenticated = false;

  bool get authenticated => _authenticated!;

  UserProfile? _userProfile;

  UserProfile get userProfile => _userProfile!;

  Future<void> _writeToken(String token) async {
    await _secureStorage.write(key: "token", value: token);
    _token = token;
  }

  Future<String?> readToken() async {
    _token = await _secureStorage.read(key: "token");
    return _token;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: "token");
    _instance = SessionData._internal();
  }

  Future<void> authenticate(String email, String password) async {
    final response = await http.post(
        Uri.parse(BaseUrl.baseHttpsUrl + "/auth/authenticate"),
        body: jsonEncode(
            {"email": email, "password": password, "jwtexpirytime": 30}),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      await _writeToken(decodedResponse['token']!);
      _userProfile = UserProfile.fromJson(decodedResponse['user']!);
      _authenticated = true;
      notifyListeners();
    } else {
      throw Exception("Failed to authenticate! " + response.body);
    }
  }

  Future<bool> checkAuthenticationStatus() async {
    await readToken();
    if (_token == null) return false;
    final response = await http.get(
        Uri.parse(BaseUrl.baseHttpsUrl + "/users/myprofile"),
        headers: {"Authorization": "Bearer " + token});

    if (response.statusCode == 200) {
      _userProfile =
          UserProfile.fromJson(jsonDecode(utf8.decode(response.bodyBytes))!);
      _authenticated = true;
    } else if (![401, 403].contains(response.statusCode))
      throw Exception("Connection or server error. (${response.statusCode})");
    notifyListeners();
    return false;
  }
}
