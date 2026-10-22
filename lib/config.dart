/// App-wide settings. Fill these in before going live.
class AppConfig {
  /// 1 000 coins = R2.00
  static const int coinsPerRand = 500;

  /// Offerwall web URL. Replace with the URL your offerwall network gives you
  /// (ayeT-Studios, Torox, AdGem, BitLabs...). {uid} is swapped for the user's id
  /// so the network's postback can credit the right account.
  /// Leave empty to run in demo mode with sample offers.
  static const String offerwallUrl = '';

  /// Your backend (Firebase Cloud Functions) base URL, e.g.
  /// https://africa-south1-zaka-play.cloudfunctions.net
  /// Leave empty for demo mode (everything stored on the phone).
  static const String apiBase = '';

  static const String supportEmail = 'support@zakaplay.co.za';
  static const String termsUrl = 'https://zakaplay.co.za/terms';
  static const String privacyUrl = 'https://zakaplay.co.za/privacy';

  static const int welcomeBonus = 500;
  static const int referralBonus = 500;
  static const int dailyStreakBonus = 50;
}
