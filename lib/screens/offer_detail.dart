import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class OfferDetailScreen extends StatelessWidget {
  final Offer o;
  const OfferDetailScreen(this.o, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final done = s.stepsDone(o);
    final finished = done >= o.steps.length;
    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        Container(
          color: o.color,
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 24),
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
            ),
            LetterTile(o.letter, Colors.white.withOpacity(0.25), size: 100),
            const SizedBox(height: 14),
            Text(o.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            Text('${o.genre}  |  ${o.category}', style: const TextStyle(color: Colors.white70)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Earn up to', style: TextStyle(color: Z.muted)),
            const SizedBox(height: 4),
            Row(children: [
              const Coin(size: 28),
              const SizedBox(width: 8),
              Text(fmtCoins(o.total), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(width: 12),
              Text('= ${fmtRand(o.total)}',
                  style: const TextStyle(color: Z.mintDark, fontWeight: FontWeight.w800, fontSize: 16)),
            ]),
            const SizedBox(height: 16),
            for (var i = 0; i < o.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ZCard(
                  child: Row(children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: i < done ? Z.mint : Z.lilac,
                      child: i < done ? const Icon(Icons.check_rounded, size: 16, color: Z.ink) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(o.steps[i].title,
                            style: TextStyle(fontWeight: FontWeight.w700, color: i < done ? Z.muted : Z.ink))),
                    Text('+${fmtCoins(o.steps[i].coins)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Z.mintDark)),
                  ]),
                ),
              ),
            const SizedBox(height: 6),
            const Text(
                'Complete within 14 days. New players only. Install from Zaka Play, and do not use a VPN or emulator. Coins confirm once our partner verifies, usually within minutes, up to 3 days.',
                style: TextStyle(color: Z.muted, fontSize: 12)),
            const SizedBox(height: 18),
            if (finished)
              const PillButton('Offer complete', onPressed: null)
            else
              PillButton(done == 0 ? 'Play and earn' : 'Next step (demo)',
                  color: Z.violet, textColor: Colors.white, onPressed: () {
                final c = s.completeNextStep(o);
                toast(context, '+${fmtCoins(c)} coins pending');
              }),
          ]),
        ),
      ]),
    );
  }
}
