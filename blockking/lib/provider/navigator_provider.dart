import 'package:flutter/cupertino.dart';

class NavigatorProvider extends ChangeNotifier{
  int _index = 0;
  int _tabIndex = 0;

  int get index => _index;
  int get tabIndex => _tabIndex;

  changeToDonation(){
    _index = 1;
    notifyListeners();
  }

  changeToMy(){
    _index = 3;
    notifyListeners();
  }

  changeIndex(int index){
    _index = index;
    notifyListeners();
  }

  changeTabIndex(int index){
    _tabIndex = index;
    notifyListeners();
  }
}