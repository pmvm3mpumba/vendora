abstract final class AuthValidators {
  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 2) return 'Saisis un nom d’au moins 2 caractères.';
    if (text.length > 80) {
      return 'Le nom doit contenir au maximum 80 caractères.';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'L’adresse email est obligatoire.';
    if (text.length > 254 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
      return 'Saisis une adresse email valide.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire.';
    }
    if (value.length < 8) return 'Utilise au moins 8 caractères.';
    return null;
  }

  static String? loginPassword(String? value) {
    return value == null || value.isEmpty
        ? 'Le mot de passe est obligatoire.'
        : null;
  }

  static String normalizePhone(String value) {
    return value.trim().replaceAll(RegExp(r'[\s().-]'), '');
  }

  static String? phone(String? value) {
    final text = normalizePhone(value ?? '');
    if (!RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(text)) {
      return 'Utilise le format international, par exemple +257XXXXXXXX.';
    }
    return null;
  }
}
