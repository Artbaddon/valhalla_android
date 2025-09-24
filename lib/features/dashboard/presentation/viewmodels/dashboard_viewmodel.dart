import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  void setTab(int index) {
    if (_tabIndex != index) {
      _tabIndex = index;
      notifyListeners();
    }
  }
}
