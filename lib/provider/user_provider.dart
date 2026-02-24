import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobo_expenses/model/employee.dart';
import 'package:mobo_expenses/model/user_model.dart';
import 'package:mobo_expenses/services/user_services.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../core/utils/snackbar.dart';

class UserProvider extends ChangeNotifier {
  Uint8List? image;
  bool isLoading = false;
  UserModel? user;
  Employee? currentEmployee;

  bool isAdmin = false;

  /// set admin or user
  setAdmin(bool value) {
    isAdmin = value;
    notifyListeners();
  }

  final userServices = UserServices();

  ///checking current role of user

  checkCurrentUserRole() async {
    try {
      final result = await userServices.checkingAdmin();
      isAdmin = result;
      notifyListeners();
    } on OdooException catch (e) {
      rethrow;
    }
  }

  ///fetch current employee details
  getCurrentEmployee(BuildContext context, int id) async {
    try {
      isLoading = true;

      final res = await userServices.gettingCurrentEmployee();

      currentEmployee = res;

      notifyListeners();
    } catch (e) {
      showSnackBar(
        context,
        'error,fetching employee error',
        backgroundColor: Colors.red,
      );
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///fetching user details
  getUserDetails(BuildContext context) async {
    try {
      isLoading = true;

      final userdetails = await userServices.gettingUserDetails();

      image = base64Decode(userdetails!.image1920!);

      user = userdetails;

      notifyListeners();
    } catch (e) {
      showSnackBar(
        context,
        'error,fetching user details error',
        backgroundColor: Colors.red,
      );
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///greetings
  String getGreeting() {
    final currentTime = DateTime.now();
    final hour = currentTime.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
