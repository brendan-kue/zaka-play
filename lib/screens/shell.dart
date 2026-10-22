import 'package:flutter/material.dart';
import '../theme.dart';
import 'home.dart';
import 'offers.dart';
import 'wallet.dart';
import 'profile.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  static void goTo(BuildContext context, int tab) =>
      context.findAncestorStateOfType<_ShellState>()?.setTab(tab);
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;
  void setTab(int t) => setState(() => _tab = t);

  @override
  Widget build(BuildContext context) {
    const pages = [HomeScreen(), OffersScreen(), WalletScreen(), ProfileScreen()];
    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: setTab,
        backgroundColor: Colors.white,
        indicatorColor: Z.lilac,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.sports_esports_rounded), label: 'Offers'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
