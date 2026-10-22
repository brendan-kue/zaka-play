import 'package:flutter/material.dart';

class OfferStep {
  final String title;
  final int coins;
  const OfferStep(this.title, this.coins);
}

class Offer {
  final String id;
  final String name;
  final String category; // Games, Surveys, Apps
  final String genre;
  final Color color;
  final String? tag;
  final bool easy;
  final List<OfferStep> steps;
  const Offer({
    required this.id,
    required this.name,
    required this.category,
    required this.genre,
    required this.color,
    required this.steps,
    this.tag,
    this.easy = false,
  });
  int get total => steps.fold(0, (a, s) => a + s.coins);
  String get letter => name.substring(0, 1).toUpperCase();
}

class Payout {
  final String id;
  final String label;
  final String subtitle;
  final Color color;
  final int minRand;
  final String fieldLabel;
  const Payout(this.id, this.label, this.subtitle, this.color, this.minRand, this.fieldLabel);
}

class CashoutRecord {
  final DateTime date;
  final String method;
  final int rand;
  final String status;
  CashoutRecord(this.date, this.method, this.rand, this.status);

  Map<String, dynamic> toJson() => {'d': date.toIso8601String(), 'm': method, 'r': rand, 's': status};
  static CashoutRecord fromJson(Map<String, dynamic> j) =>
      CashoutRecord(DateTime.parse(j['d']), j['m'], j['r'], j['s']);
}

/// Demo offers, shown until a real offerwall URL is set in config.dart.
const demoOffers = <Offer>[
  Offer(id: 'blockblast', name: 'Block Blast!', category: 'Games', genre: 'Puzzle', color: Color(0xFFFF6B4A), tag: 'Hot', steps: [
    OfferStep('Install and open the game', 200),
    OfferStep('Reach level 5', 600),
    OfferStep('Reach level 12', 1000),
    OfferStep('Reach level 20', 1400),
  ]),
  Offer(id: 'farmstory', name: 'Farm Story', category: 'Games', genre: 'Casual', color: Color(0xFF22B07D), steps: [
    OfferStep('Install and open the game', 300),
    OfferStep('Reach level 10', 1300),
    OfferStep('Reach level 25', 4000),
  ]),
  Offer(id: 'solitaire', name: 'Solitaire Grand', category: 'Games', genre: 'Cards', color: Color(0xFF3D8BFF), easy: true, steps: [
    OfferStep('Install and open the game', 100),
    OfferStep('Play for 15 minutes', 800),
  ]),
  Offer(id: 'coinkingdom', name: 'Coin Kingdom', category: 'Games', genre: 'Adventure', color: Color(0xFFF2A20C), tag: 'New', steps: [
    OfferStep('Install and open the game', 400),
    OfferStep('Build castle level 3', 2400),
    OfferStep('Build castle level 8', 5000),
  ]),
  Offer(id: 'matchmania', name: 'Match Mania', category: 'Games', genre: 'Puzzle', color: Color(0xFFE0408A), steps: [
    OfferStep('Install and open the game', 200),
    OfferStep('Reach level 15', 1900),
  ]),
  Offer(id: 'survey1', name: 'Quick Survey: Shopping', category: 'Surveys', genre: '5 min', color: Color(0xFF9B5CFF), easy: true, steps: [
    OfferStep('Complete the survey', 400),
  ]),
  Offer(id: 'poll', name: 'Daily Poll', category: 'Surveys', genre: '1 min', color: Color(0xFF6C5CE7), easy: true, steps: [
    OfferStep('Answer 3 questions', 50),
  ]),
  Offer(id: 'tunebox', name: 'TuneBox Music', category: 'Apps', genre: 'Music', color: Color(0xFF1DB954), steps: [
    OfferStep('Install and sign up', 1500),
  ]),
];

const payouts = <Payout>[
  Payout('airtime', 'Airtime and data', 'MTN, Vodacom, Cell C, Telkom', Color(0xFFFFCB05), 10, 'Cellphone number'),
  Payout('takealot', 'Takealot voucher', 'Sent by email', Color(0xFF0071CE), 50, 'Email address'),
  Payout('checkers', 'Checkers voucher', 'Sent by SMS', Color(0xFFE2231A), 50, 'Cellphone number'),
  Payout('bank', 'Bank or eWallet', 'Paid within 48 hours', Color(0xFF1EE3A2), 100, 'Cellphone (eWallet) or account no.'),
];
