import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initializing, unauthenticated, authenticated }

/// ViewModel cho trạng thái đăng nhập, dùng Firebase Auth qua AuthRepository.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _bootstrap();
  }

  final AuthRepository _repository;
  StreamSubscription<fb_auth.User?>? _sub;

  AuthStatus _status = AuthStatus.initializing;
  AppUser? _user;
  String? _errorMessage;
  bool _busy = false;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get uid => _user?.uid;
  String? get errorMessage => _errorMessage;
  bool get busy => _busy;

  Future<void> _bootstrap() async {
    _user = await _repository.currentUser();
    _status = _user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();

    // Theo dõi auth state thay đổi (logout từ device khác, token hết hạn, v.v.)
    _sub = _repository.authStateChanges().listen((fbUser) async {
      if (fbUser == null) {
        _user = null;
        _status = AuthStatus.unauthenticated;
      } else if (_user == null || _user!.uid != fbUser.uid) {
        _user = await _repository.currentUser();
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }

  Future<bool> login({required String email, required String password}) async {
    _setBusy(true);
    try {
      _user = await _repository.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _setBusy(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setBusy(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    try {
      _user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _setBusy(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setBusy(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  String _cleanError(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
