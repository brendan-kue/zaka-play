import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Wallet', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Z.violet, borderRadius: BorderRadius.circular(24)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Available', style: TextStyle(color: Color(0xFFC9BEF0))),
            const SizedBox(height: 6),
            Row(children: [
              const Coin(size: 30),
              const SizedBox(width: 8),
              Text(fmtCoins(s.available),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const Spacer(),
              Text(fmtRand(s.available),
                  style: const TextStyle(color: Z.mint, fontSize: 20, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 6),
            Text('Pending ${fmtCoins(s.pending)}  |  1 000 coins = R${(1000 / AppConfig.coinsPerRand).toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFFC9BEF0), fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Cash out to', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        for (final p in payouts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ZCard(
              onTap: () => _sheet(context, p),
              child: Row(children: [
                LetterTile(p.label[0], p.color, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(p.subtitle, style: const TextStyle(color: Z.muted, fontSize: 12)),
                  ]),
                ),
                Text('From R${p.minRand}', style: const TextStyle(color: Z.violet, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        if (s.history.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final h in s.history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${h.method}  R${h.rand}', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(DateFormat('d MMM yyyy, HH:mm').format(h.date)),
              trailing: Text(h.status, style: const TextStyle(color: Z.muted, fontWeight: FontWeight.w700)),
            ),
        ],
      ]),
    );
  }

  void _sheet(BuildContext context, Payout p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => CashoutSheet(p),
    );
  }
}

class CashoutSheet extends StatefulWidget {
  final Payout p;
  const CashoutSheet(this.p, {super.key});
  @override
  State<CashoutSheet> createState() => _CashoutSheetState();
}

class _CashoutSheetState extends State<CashoutSheet> {
  late int _amount = widget.p.minRand;
  final _field = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = widget.p;
    final cost = _amount * AppConfig.coinsPerRand;
    final short = cost - s.available;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [p.minRand, p.minRand * 2, p.minRand * 5]
              .map((a) => ChoiceChip(
                    label: Text('R$a'),
                    selected: _amount == a,
                    onSelected: (_) => setState(() => _amount = a),
                    selectedColor: Z.violet,
                    showCheckmark: false,
                    labelStyle: TextStyle(color: _amount == a ? Colors.white : Z.ink, fontWeight: FontWeight.w700),
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),
        Row(children: [
          const Coin(size: 18),
          const SizedBox(width: 6),
          Text('${fmtCoins(cost)} coins', style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 14),
        TextField(
          controller: _field,
          keyboardType: p.fieldLabel.startsWith('Email') ? TextInputType.emailAddress : TextInputType.phone,
          decoration: InputDecoration(labelText: p.fieldLabel, fillColor: Z.bg),
        ),
        const SizedBox(height: 16),
        PillButton(
          short > 0 ? 'You need ${fmtCoins(short)} more coins' : 'Request cash-out',
          color: Z.violet,
          textColor: Colors.white,
          onPressed: short > 0
              ? null
              : () {
                  if (_field.text.trim().length < 5) {
                    toast(context, 'Enter your ${p.fieldLabel.toLowerCase()}');
                    return;
                  }
                  final ok = s.requestCashout(p, _amount);
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  if (ok) {
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Request sent. Paid within 48 hours.'),
                        behavior: SnackBarBehavior.floating));
                  }
                },
        ),
      ]),
    );
  }
}
