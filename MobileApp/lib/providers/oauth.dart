import 'dart:async';
import 'dart:convert';
import 'package:automated_attendance_app/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'hasura.dart';

class OauthModel extends ChangeNotifier {
  Timer _refreshTimer;
  HasuraModel hasura;

  OauthModel(this.hasura) : super() {
    refresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _busy = false;

  bool get busy => _busy;

  TokenResponse _token;

  TokenResponse get token => _token;

  Map<String, dynamic> get user => jwtDecode(_token?.idToken);
  String get userId => user != null ? user["oid"] : null;

  Future<Map<String, dynamic>> get userDetails async {
    if (_token?.accessToken == null) return null;

    final response = await http.get(
      'https://graph.microsoft.com/v1.0/me/',
      headers: {'Authorization': 'Bearer ${_token.accessToken}'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<void> refresh() async {
    try {
      _busy = true;
      notifyListeners();

      print("Loading refresh token...");

      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        _busy = false;
        notifyListeners();
        return;
      }

      print("Refreshing token...");

      return await _appAuth
          .token(
            TokenRequest(
              'f55fe8fe-74c4-45d6-bccc-e29aba32b102',
              'university.innopolis.attendance://innopolis.university/',
              serviceConfiguration: AuthorizationServiceConfiguration(
                'https://login.microsoftonline.com/8b33a0fd-354e-48f9-b6fa-b85f0b6e3e55/oauth2/v2.0/authorize',
                'https://login.microsoftonline.com/8b33a0fd-354e-48f9-b6fa-b85f0b6e3e55/oauth2/v2.0/token',
              ),
              refreshToken: refreshToken,
            ),
          )
          .catchError((error) => null)
          .then(this.useToken);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> login() async {
    try {
      _busy = true;
      notifyListeners();

      print("Logging in...");

      await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              'f55fe8fe-74c4-45d6-bccc-e29aba32b102',
              'university.innopolis.attendance://innopolis.university/',
              serviceConfiguration: AuthorizationServiceConfiguration(
                'https://login.microsoftonline.com/8b33a0fd-354e-48f9-b6fa-b85f0b6e3e55/oauth2/v2.0/authorize',
                'https://login.microsoftonline.com/8b33a0fd-354e-48f9-b6fa-b85f0b6e3e55/oauth2/v2.0/token',
              ),
              scopes: [
                'email',
                'openid',
                'profile',
                'User.Read',
                'offline_access'
              ],
              promptValues: ['login'],
            ),
          )
          .catchError((error) => print(error))
          .then(this.useToken);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> useToken(TokenResponse token) async {
    try {
      hasura.setToken(token?.idToken);
      await hasura.hasura.mutation("mutation {ensureUser{success}}");
      _token = token;
      await _secureStorage.write(key: 'username', value: user['email']);
      final refreshDelay = Duration(seconds: (user['exp'] - user['iat']) ~/ 2);
      _refreshTimer = new Timer(refreshDelay, this.refresh);
    } catch (e) {
      print(e);
      _token = null;
    } finally {
      await _secureStorage.write(
          key: 'refresh_token', value: token?.refreshToken);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    await _secureStorage.delete(key: 'refresh_token');
    notifyListeners();
  }
}
