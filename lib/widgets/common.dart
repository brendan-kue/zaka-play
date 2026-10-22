import 'package:flutter/material.dart';
import '../config.dart';
import '../theme.dart';

class Coin extends StatelessWidget {
  final double size;
  const Coin({super.key, this.size = 20});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Z.gold,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0A800), width: size * 0.08),
        ),
        child: Text('Z',
            style: TextStyle(fontSize: size * 0.55, fontWeight: FontWeight.w900, color: const Color(0xFFB97F00), height: 1)),
      );
}

class LetterTile extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;
  const LetterTile(this.letter, this.color, {super.key, this.size = 56});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * 0.26)),
        child: Text(letter,
            style: TextStyle(color: Colors.white, fontSize: size * 0.42, fontWeight: FontWeight.w900)),
      );
}

class ZCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const ZCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(12)});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      );
}

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final double height;
  const PillButton(this.label,
      {super.key, this.onPressed, this.color = Z.mint, this.textColor = Z.ink, this.height = 52});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            disabledBackgroundColor: Z.lilac,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          onPressed: onPressed,
          child: Text(label),
        ),
      );
}

String fmtCoins(int c) {
  final s = c.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return b.toString();
}

String fmtRand(int coins) => 'R${(coins / AppConfig.coinsPerRand).toStringAsFixed(2)}';

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: Z.violet,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
    ));
}
