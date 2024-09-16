
import 'package:flutter/foundation.dart';

enum ViewState { inital, loading, succuss, fail }

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.inital;
  ViewState get state => _state;

  void setstate(state) {
    _state = state;
    notifyListeners();
  }
}
