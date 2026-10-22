import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'home.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});
  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String _filter = 'Games';
  static const _chips = ['Games', 'Surveys', 'Apps', 'Easy'];

  List<Offer> get _list =>
      demoOffers.where((o) => _filter == 'Easy' ? o.easy : o.category == _filter).toList();

  Future<void> _openOfferwall() async {
    final uid = context.read<AppState>().uid;
    final url = AppConfig.offerwallUrl.replaceAll('{uid}', Uri.encodeComponent(uid));
    await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
  }

  @override
  Widget build(BuildContext context) {
    final live = AppConfig.offerwallUrl.isNotEmpty;
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Offers', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        if (live) ...[
          ZCard(
            onTap: _openOfferwall,
            padding: const EdgeInsets.all(16),
            child: const Row(children: [
              Icon(Icons.bolt_rounded, color: Z.violet, size: 32),
              SizedBox(width: 12),
              Expanded(
                  child: Text('Open all offers\nHundreds of games and surveys',
                      style: TextStyle(fontWeight: FontWeight.w800))),
              Icon(Icons.chevron_right_rounded),
            ]),
          ),
          const SizedBox(height: 12),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _chips
                .map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: _filter == c,
                        onSelected: (_) => setState(() => _filter = c),
                        selectedColor: Z.violet,
                        labelStyle: TextStyle(
                            color: _filter == c ? Colors.white : Z.ink, fontWeight: FontWeight.w700),
                        showCheckmark: false,
                        backgroundColor: Colors.white,
                        shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        for (final o in _list) Padding(padding: const EdgeInsets.only(bottom: 12), child: OfferCard(o)),
        if (!live)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Demo offers. Real offers appear once an offerwall partner is connected.',
                textAlign: TextAlign.center, style: TextStyle(color: Z.muted, fontSize: 12)),
          ),
      ]),
    );
  }
}
