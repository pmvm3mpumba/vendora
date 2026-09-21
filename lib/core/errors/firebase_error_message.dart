import 'package:firebase_core/firebase_core.dart';

String firebaseErrorMessage(Object error) {
  if (error is FirebaseException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'invalid-login-credentials' => 'Email ou mot de passe incorrect.',
      'invalid-email' => 'L’adresse email est invalide.',
      'email-already-in-use' =>
        'Un compte existe déjà avec cette adresse email.',
      'weak-password' || 'password-does-not-meet-requirements' =>
        'Le mot de passe ne respecte pas les critères de sécurité du projet.',
      'user-disabled' => 'Ce compte a été désactivé.',
      'too-many-requests' => 'Trop de tentatives. Réessaie plus tard.',
      'network-request-failed' || 'unavailable' || 'deadline-exceeded' =>
        'Connexion au service impossible. Vérifie Internet puis réessaie.',
      'permission-denied' =>
        'Accès refusé. Vérifie les règles Firestore déployées pour ce projet.',
      'operation-not-allowed' => 'La connexion par email doit être activée dans Firebase Authentication.',
      'unauthenticated' => 'Reconnecte-toi pour continuer.',
      _ => 'L’opération a échoué. Réessaie dans un instant.',
    };
  }
  return 'Impossible de terminer l’opération. Réessaie.';
}
