import 'package:cloud_firestore/cloud_firestore.dart';

/// Lecture défensive : une donnée mal formée devient une erreur contrôlée.
abstract final class FirestoreValues {
  static String text(
    Map<String, dynamic> data,
    String key, {
    int minLength = 1,
    int maxLength = 200,
  }) {
    final value = data[key];
    if (value is! String ||
        value.trim().length < minLength ||
        value.length > maxLength) {
      throw FormatException('Champ texte invalide : $key.');
    }
    return value.trim();
  }

  static int integer(
    Map<String, dynamic> data,
    String key, {
    int minimum = 0,
    int maximum = 1000000,
  }) {
    final value = data[key];
    if (value is! int || value < minimum || value > maximum) {
      throw FormatException('Champ entier invalide : $key.');
    }
    return value;
  }

  static bool boolean(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! bool) throw FormatException('Champ booléen invalide : $key.');
    return value;
  }

  static DateTime? timestamp(Map<String, dynamic> data, String key) {
    final value = data[key];
    // Les serverTimestamp peuvent être null pendant une écriture en attente.
    if (value == null) return null;
    if (value is! Timestamp) throw FormatException('Date invalide : $key.');
    return value.toDate().toUtc();
  }
}
