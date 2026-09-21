/// Les conversions seront implémentées dans le module panier/devises.
/// Ici, nous fixons le format monétaire des documents Firestore.
enum AppCurrency {
  bif('BIF', 1),
  usd('USD', 100),
  eur('EUR', 100);

  const AppCurrency(this.code, this.minorUnitFactor);
  final String code;
  final int minorUnitFactor;

  static AppCurrency fromCode(String code) {
    for (final currency in values) {
      if (currency.code == code) return currency;
    }
    throw const FormatException('Devise non prise en charge.');
  }
}
