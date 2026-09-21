import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/firebase_error_message.dart';
import '../data/auth_repository.dart';
import '../models/app_user.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    _authSubscription = _repository.authChanges.listen(
      _onAuthChanged,
      onError: (Object error) {
        _sessionError = firebaseErrorMessage(error);
        _ready = true;
        _emit();
      },
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<User?> _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSubscription;
  AppUser? _profile;
  bool _ready = false;
  bool _busy = false;
  bool _disposed = false;
  int _generation = 0;
  String? _operationError;
  String? _sessionError;

  AppUser? get profile => _profile;
  bool get ready => _ready;
  bool get busy => _busy;
  bool get isAuthenticated => _repository.currentUser != null;
  String? get operationError => _operationError;
  String? get sessionError => _sessionError;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _onAuthChanged(User? user) async {
    final generation = ++_generation;
    _ready = false;
    _profile = null;
    _sessionError = null;
    _emit();
    await _profileSubscription?.cancel();
    if (_disposed || generation != _generation) return;
    _profileSubscription = null;

    if (user == null) {
      _ready = true;
      _emit();
      return;
    }

    _profileSubscription = _repository.watchProfile(user.uid).listen(
      (snapshot) {
        if (_disposed || generation != _generation) return;
        try {
          final data = snapshot.data();
          _profile = data == null ? null : AppUser.fromMap(snapshot.id, data);
          _sessionError = null;
        } catch (_) {
          _profile = null;
          _sessionError = 'Le profil enregistré a un format invalide. '
              'Vérifie le document utilisateur dans Firestore.';
        }
        _ready = true;
        _emit();
      },
      onError: (Object error) {
        if (_disposed || generation != _generation) return;
        _profile = null;
        _sessionError = firebaseErrorMessage(error);
        _ready = true;
        _emit();
      },
    );
  }

  void clearOperationError() {
    _operationError = null;
    _emit();
  }

  Future<bool> _perform(Future<void> Function() action) async {
    if (_busy) return false;
    _busy = true;
    _operationError = null;
    _emit();
    try {
      await action();
      return true;
    } catch (error) {
      _operationError = firebaseErrorMessage(error);
      return false;
    } finally {
      _busy = false;
      _emit();
    }
  }

  Future<bool> signIn(String email, String password) {
    return _perform(() => _repository.signIn(email, password));
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    required String whatsappNumber,
  }) {
    return _perform(() => _repository.register(
      email: email, password: password, name: name, phone: phone,
      role: role, whatsappNumber: whatsappNumber,
    ));
  }

  Future<bool> completeProfile({
    required String name,
    required String phone,
    required UserRole role,
    required String whatsappNumber,
  }) {
    return _perform(() => _repository.completeProfile(
      name: name, phone: phone, role: role, whatsappNumber: whatsappNumber,
    ));
  }

  Future<bool> signOut() => _perform(_repository.signOut);

  Future<void> retryProfile() => _onAuthChanged(_repository.currentUser);

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    _authSubscription.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
