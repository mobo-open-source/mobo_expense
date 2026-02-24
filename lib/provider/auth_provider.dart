import 'package:flutter/material.dart';
import 'package:mobo_expenses/sharedpreferences/shared_pref.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import '../features/home/loading.dart';
import '../services/odoo_services.dart';

class AuthProvider extends ChangeNotifier {
  List<String> listSelection = <String>["https://", "http://"];
  String dropdownValue = "https://";
  String error = '';
  bool serverErrorVisible = false;
  bool obscure = false;
  List<dynamic> dbList = [];
  String selectedDb = "";
  bool isLoading = false;
  bool authErrorVisible = false;
  bool emptyEmail = false;
  bool emptyPass = false;
  bool dbListing = false;
  String baseUrl = '';
  String databse = '';
  List<String> urlList = [];

  OdooClient? client;
  OdooServices odooServices = OdooServices();

  ///hide &show databse
  showHideDatabase() {
    dbListing = !dbListing;
    notifyListeners();
  }

  ///select db
  selectDatabase(String db) {
    selectedDb = db;
    notifyListeners();
  }

  ///error show
  void changeErrorEmail(bool c) {
    emptyEmail = c;
    notifyListeners();
  }

  ///error show in password
  void changeErrorPassword(bool c) {
    emptyPass = c;
    notifyListeners();
  }

  void showErrorPassword() {
    emptyPass = true;
    notifyListeners();
  }

  void showErrorEmail() {
    emptyEmail = true;
    notifyListeners();
  }

  void selectList(String value) {
    dropdownValue = value;
    notifyListeners();
  }

  void getError(String failed) {
    dbList = [];
    serverErrorVisible = true;
    selectedDb = '';
    error = '$failed';

    notifyListeners();
  }

  void notErrorCase() {
    serverErrorVisible = false;
    error = '';
    notifyListeners();
  }

  changeObscure(bool ischanged) {
    obscure = !ischanged;
    notifyListeners();
  }

  changeAuthError(bool error) {
    authErrorVisible = !error;
    notifyListeners();
  }

  ///db list
  getDbList(String server, String selected) async {
    if (server.isEmpty) {
      getError("error please enter a server url first");
      return;
    }

    try {
      isLoading = true;
      final formattedAddress = server
          .replaceAll(RegExp(r'https://'), '')
          .replaceAll(RegExp(r'http://'), '');
      final url = "$selected$formattedAddress";

      final odooServices = OdooServices();
      odooServices.addUrl(url);
      baseUrl = url;
      SharedPref().setBaseUrl(url);
      dbList = await odooServices.getDatabaseList();
      selectedDb = dbList[0];
      serverErrorVisible = false;
      notifyListeners();
    } catch (e) {
      dbList = [];
      getError(
        "Invalid server response.This may not be an Odoo server or the URL path is incorrect.",
      );
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///authentication
  authentication({
    required String db,
    required String username,
    required String password,
    required BuildContext context,
  }) async {
    try {
      isLoading = true;

      notifyListeners();
      final odooServices = OdooServices();
      odooServices.addUrl(baseUrl);
      final res = await odooServices.authentication(
        db: db,
        username: username,
        password: password,
      );

      client = res;

      isLoading = false;
      dbList = [];
      notifyListeners();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Loading()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      authErrorVisible = true;

      isLoading = false;
      notifyListeners();
    }
  }

  ///getting previous section
  gettingPreviousSection({required String url, required String session}) async {
    try {
      final res = await odooServices.checkingAuthentication(
        baseUrl: url,
        json: session,
      );
      client = res;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  ///reset
  void reset() {
    listSelection = <String>["https://", "http://"];
    dropdownValue = "https://";
    error = '';
    serverErrorVisible = false;
    obscure = false;
    dbList = [];
    selectedDb = "";
    isLoading = false;
    authErrorVisible = false;
    emptyEmail = false;
    emptyPass = false;
    dbListing = false;
    baseUrl = '';
    databse = '';
    urlList = [];
    client = null;

    notifyListeners();
  }
}
