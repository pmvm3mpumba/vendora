import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/validators/auth_validators.dart';
import '../models/app_user.dart';

class AuthRepository {
  AuthRepository({required this.auth, required this.firestore});

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  Stream<User?> get authChanges => auth.authStateChanges();
  User? get currentUser => auth.currentUser;

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile(String uid) {
    return firestore.collection('users').doc(uid).snapshots();
  }

  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    required String whatsappNumber,
  }) async {
    await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Auth et Firestore ne forment pas une transaction commune.
    // Si cette écriture échoue, l'écran de récupération de profil prendra le relais.
    await completeProfile(
      name: name,
      phone: phone,
      role: role,
      whatsappNumber: whatsappNumber,
    );
  }

  Future<void> completeProfile({
    required String name,
    required String phone,
    required UserRole role,
    required String whatsappNumber,
  }) async {
    final user = currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'unauthenticated');
    }
    await firestore.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'email': user.email!,
      'phone': AuthValidators.normalizePhone(phone),
      'role': role.name,
      'whatsappNumber': role == UserRole.seller
          ? AuthValidators.normalizePhone(whatsappNumber)
          : '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() => auth.signOut();
}
