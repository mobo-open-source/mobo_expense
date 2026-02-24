import 'dart:async';
import 'dart:convert';
import 'package:mobo_expenses/sharedpreferences/shared_pref.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../core/services/odoo_session_manager.dart';

class OdooServices {
  late OdooClient client;
  OdooSession? session;

  addUrl(String baseUrl) {
    client = OdooClient(baseUrl);
  }

  /// fetch the databse from server
  Future<List<dynamic>> getDatabaseList() async {
    try {
      final response = await Future.any([
        client.callRPC('/web/database/list', 'call', {}),

        Future.delayed(const Duration(seconds: 15)).then(
          (_) => throw TimeoutException(
            'Request timed out',
            const Duration(seconds: 15),
          ),
        ),
      ]);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  ///checking authentication
  Future checkingAuthentication({
    required String baseUrl,
    required String json,
  }) async {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final restoredSession = OdooSession.fromJson(map);

      final client = OdooClient(baseUrl, sessionId: restoredSession);
      return client;
    } on OdooException catch (e) {
      return null;
    }
  }

  /// authentication

  Future authentication({
    required String db,
    required String username,
    required String password,
  }) async {
    try {
      final session = await client.authenticate(db, username, password);
      SharedPref().setDatabase(db);
      SharedPref().setUsername(username);
      SharedPref().setSessionJson(jsonEncode(session.toJson()));
      SharedPref().setLoggedIn(true);
      return client;
    } on OdooException catch (e) {
      rethrow;
    }
  }

  ///checking module is installed or not

  expenseModuleInstalled() async {
    try {
      final client = await OdooSessionManager.getClientEnsured();
      final count = await client.callKw({
        'model': 'ir.module.module',
        'method': 'search_count',
        'args': [
          [
            ['name', '=', 'hr_expense'],
            ['state', '=', 'installed'],
          ],
        ],
        'kwargs': {},
      });
      return count > 0;
    } catch (e) {
      /// Keep as false; the MissingInventoryScreen will allow retry
    }
  }

  ///destroy session
  logOut(OdooClient currentClient) async {
    await currentClient.destroySession();
  }
}
