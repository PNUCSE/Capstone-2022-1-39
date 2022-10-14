import 'package:flutter/cupertino.dart';

import '../util/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
      email: '',
      password: '',
      name: '',
      phone: '',
      address: '',
      birth: '',
      role: '',
      id: '');

  User get user => _user;

  changeUser(User user) {
    _user = user;
    notifyListeners();
  }

  removeUser() {
    _user = User(
        email: '',
        password: '',
        name: '',
        phone: '',
        address: '',
        birth: '',
        role: '',
        id: '');
    notifyListeners();
  }
}
