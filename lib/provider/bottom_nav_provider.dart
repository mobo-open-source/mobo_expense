import 'package:flutter/material.dart';

class BottomNavProvider extends ChangeNotifier {
  int index = 0;
  changeIndex(int tapedIndex) {
    index = tapedIndex;
    notifyListeners();
  }

  signOutIndex() {
    index = 0;
    notifyListeners();
  }
}
