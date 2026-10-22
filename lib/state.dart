import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'models.dart';

/// Holds the user's account, coins and progress.
/// Demo mode keeps everything on the phone. When AppConfig.apiBase is set,
/// balances should come from the server instead (see firebase/functions).
class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  String? name;
  String phone = '';
  String email = '';
  String uid = '';
  int available = 0;
  int pending = 0;
  int lifetime = 0;
  int streak = 0;
  String lastClaim = '';
  bool onboarded = false;
  Map<String, int> progress = {}; // offerId -> steps completed
  List<CashoutRecord> history = [];

  bool get signedIn => name != null && name!.isNotEmpty;
  double get rand => available / AppConfig.coinsPerRand;
  String get referralCode => 'ZAKA-${(name ?? 'FRIEND').toUpperCase().replaceAll(' ', '')}-27';
  bool get claimedToday => lastClaim == _today();

  int get level => 1 + (lifetime ~/ 10000);
  double get levelProgress => (lifetime % 10000) / 10000;
  String get levelName => const ['Starter', 'Earner', 'Pro', 'Champion', 'Legend'][(level - 1).clamp(0, 4)];

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    name = p.getString('name');
    phone = p.getString('phone') ?? '';
    email = p.getString('email') ?? '';
    uid = p.getString('uid') ?? '';
    available = p.getInt('available') ?? 0;
    pending = p.getInt('pending') ?? 0;
    lifetime = p.getInt('lifetime') ?? 0;
    streak = p.getInt('streak') ?? 0;
    lastClaim = p.getString('lastClaim') ?? '';
    onboarded = p.getBool('onboarded') ?? false;
    final pr = p.getString('progress');
    if (pr != null) progress = Map<String, int>.from(jsonDecode(pr));
    final h = p.getString('history');
    if (h != null) {
      history = (jsonDecode(h) as List).map((e) => CashoutRecord.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    // pending coins from a previous session confirm on next launch
    if (pending > 0) {
      available += pending;
      pending = 0;
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    if (name != null) p.setString('name', name!);
    p.setString('phone', phone);
    p.setString('email', email);
    p.setString('uid', uid);
    p.setInt('available', available);
    p.setInt('pending', pending);
    p.setInt('lifetime', lifetime);
    p.setInt('streak', streak);
    p.setString('lastClaim', lastClaim);
    p.setBool('onboarded', onboarded);
    p.setString('progress', jsonEncode(progress));
    p.setString('history', jsonEncode(history.map((e) => e.toJson()).toList()));
  }

  void finishOnboarding() {
    onboarded = true;
    _save();
    notifyListeners();
  }

  void signUp(String n, String ph, String em) {
    name = n.trim();
    phone = ph.trim();
    email = em.trim();
    uid = 'u${DateTime.now().millisecondsSinceEpoch}';
    available += AppConfig.welcomeBonus;
    lifetime += AppConfig.welcomeBonus;
    _save();
    notifyListeners();
  }

  void claimStreak() {
    if (claimedToday) return;
    streak = (streak % 7) + 1;
    lastClaim = _today();
    available += AppConfig.dailyStreakBonus;
    lifetime += AppConfig.dailyStreakBonus;
    _save();
    notifyListeners();
  }

  int stepsDone(Offer o) => progress[o.id] ?? 0;

  /// Demo only: marks the next step done. In production the offerwall
  /// network's postback credits coins on the server.
  int completeNextStep(Offer o) {
    final done = stepsDone(o);
    if (done >= o.steps.length) return 0;
    final c = o.steps[done].coins;
    progress[o.id] = done + 1;
    pending += c;
    _save();
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      pending -= c;
      available += c;
      lifetime += c;
      _save();
      notifyListeners();
    });
    return c;
  }

  bool requestCashout(Payout p, int randAmount) {
    final cost = randAmount * AppConfig.coinsPerRand;
    if (cost > available) return false;
    available -= cost;
    history.insert(0, CashoutRecord(DateTime.now(), p.label, randAmount, 'Processing'));
    _save();
    notifyListeners();
    return true;
  }

  Future<void> logOut() async {
    await _prefs?.clear();
    name = null;
    phone = email = uid = lastClaim = '';
    available = pending = lifetime = streak = 0;
    onboarded = false;
    progress = {};
    history = [];
    notifyListeners();
  }
}
