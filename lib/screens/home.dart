import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'offer_detail.dart';
import 'shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final top = demoOffers.where((o) => s.stepsDone(o) < o.steps.length).take(3).toList();
    return ListView(padding: EdgeInsets.zero, children: [
      Container(
        color: Z.violet,
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hi ${s.name}', style: const TextStyle(color: Color(0xFFC9BEF0), fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Your balance', style: TextStyle(color: Color(0xFFC9BEF0), fontSize: 13)),
          const SizedBox(height: 10),
          Row(children: [
            const Coin(size: 36),
            const SizedBox(width: 10),
            Text(fmtCoins(s.available),
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
          ]),
          Text('= ${fmtRand(s.available)}${s.pending > 0 ? '   (+${fmtCoins(s.pending)} pending)' : ''}',
              style: const TextStyle(color: Z.mint, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: PillButton('Cash out', height: 44, onPressed: () => Shell.goTo(context, 2))),
            const SizedBox(width: 12),
            Expanded(
                child: PillButton('Invite +${AppConfig.referralBonus}',
                    height: 44, color: Z.violet2, textColor: Colors.white, onPressed: () => Shell.goTo(context, 3))),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFF2F1A66), borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              ...List.generate(
                  7,
                  (i) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: CircleAvatar(
                            radius: 10, backgroundColor: i < s.streak ? Z.mint : const Color(0xFF4A3590)),
                      )),
              const Spacer(),
              TextButton(
                onPressed: s.claimedToday
                    ? null
                    : () {
                        s.claimStreak();
                        toast(context, 'Daily streak +${AppConfig.dailyStreakBonus} coins');
                      },
                child: Text(s.claimedToday ? 'Back tomorrow' : 'Claim +${AppConfig.dailyStreakBonus}',
                    style: TextStyle(
                        color: s.claimedToday ? const Color(0xFF9C8FD0) : Z.mint, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Text('Daily streak ${s.streak} / 7', style: const TextStyle(color: Z.muted, fontWeight: FontWeight.w700)),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Text('Top offers for you', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      ),
      for (final o in top)
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: OfferCard(o)),
      if (top.isEmpty)
        const Padding(padding: EdgeInsets.all(20), child: Text('You have finished every offer. New ones soon!')),
    ]);
  }
}

class OfferCard extends StatelessWidget {
  final Offer o;
  const OfferCard(this.o, {super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final done = s.stepsDone(o) >= o.steps.length;
    return ZCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OfferDetailScreen(o))),
      child: Row(children: [
        LetterTile(o.letter, o.color, size: 60),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(o.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 2),
            Text('${o.genre}  |  ${o.category}', style: const TextStyle(color: Z.muted, fontSize: 12)),
            if (o.tag != null && !done)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Z.gold, borderRadius: BorderRadius.circular(8)),
                child: Text(o.tag!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
          ]),
        ),
        if (done)
          const Icon(Icons.check_circle_rounded, color: Z.mintDark)
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE6FFF5), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Coin(size: 16),
              const SizedBox(width: 4),
              Text('+${fmtCoins(o.total)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Z.mintDark)),
            ]),
          ),
      ]),
    );
  }
}
