import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Z.violet,
            child: Text((s.name ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              Text(s.phone, style: const TextStyle(color: Z.muted)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        ZCard(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Coin(size: 22),
              const SizedBox(width: 8),
              Text('Level ${s.level} - ${s.levelName}', style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                  value: s.levelProgress, minHeight: 10, color: Z.mint, backgroundColor: Z.lilac),
            ),
            const SizedBox(height: 6),
            Text('${fmtCoins(10000 - (s.lifetime % 10000))} coins to Level ${s.level + 1}',
                style: const TextStyle(color: Z.muted, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Z.violet, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Invite friends',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('You both get ${AppConfig.referralBonus} coins when they finish their first offer.',
                style: TextStyle(color: Color(0xFFC9BEF0))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFF160A33), borderRadius: BorderRadius.circular(12)),
                  child: Text(s.referralCode,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Z.mint, foregroundColor: Z.ink),
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text: 'Join me on Zaka Play and earn rewards for playing games! Use my code ${s.referralCode}'));
                  toast(context, 'Code copied');
                },
                child: const Text('Copy', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        _row(context, Icons.lightbulb_rounded, 'How it works', () => _info(context, 'How it works', const [
              ('1. Pick an offer', 'Choose a game, survey or app from Offers.'),
              ('2. Hit the goals', 'Install from Zaka Play and reach each step. Coins confirm once our partner verifies.'),
              ('3. Cash out', 'Swap coins for airtime, data, vouchers or cash from R10.'),
            ])),
        _row(context, Icons.help_rounded, 'Help and FAQ', () => _info(context, 'Help and FAQ', const [
              ('When do I get my coins?', 'Once the partner confirms, usually within minutes and at most 3 days.'),
              ('Why did my offer not track?', 'You must be a new player, install from our link, and not use a VPN or emulator.'),
              ('How fast are cash-outs?', 'Within 48 hours on weekdays.'),
              ('Is Zaka Play free?', 'Yes. No deposits and no in-app purchases.'),
            ])),
        _row(context, Icons.mail_rounded, 'Contact support',
            () => launchUrl(Uri.parse('mailto:${AppConfig.supportEmail}'))),
        _row(context, Icons.description_rounded, 'Terms', () => launchUrl(Uri.parse(AppConfig.termsUrl))),
        _row(context, Icons.privacy_tip_rounded, 'Privacy Policy', () => launchUrl(Uri.parse(AppConfig.privacyUrl))),
        _row(context, Icons.logout_rounded, 'Log out', () => context.read<AppState>().logOut()),
        _row(context, Icons.delete_forever_rounded, 'Delete account', () => _confirmDelete(context)),
      ]),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final s = context.read<AppState>();
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
            'Your coins and history will be removed. Any coins you have not cashed out will be lost. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800))),
        ],
      ),
    );
    if (yes != true) return;
    final body = Uri.encodeComponent('Please delete my Zaka Play account.\nUser ID: ${s.uid}\nPhone: ${s.phone}');
    await launchUrl(Uri.parse(
        'mailto:${AppConfig.supportEmail}?subject=${Uri.encodeComponent('Delete my Zaka Play account')}&body=$body'));
    await s.logOut();
  }

  Widget _row(BuildContext context, IconData icon, String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ZCard(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Icon(icon, color: Z.violet),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_right_rounded, color: Z.muted),
          ]),
        ),
      );

  void _info(BuildContext context, String title, List<(String, String)> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          for (final i in items) ...[
            Text(i.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(i.$2, style: const TextStyle(color: Z.muted)),
            const SizedBox(height: 12),
          ],
        ]),
      ),
    );
  }
}
