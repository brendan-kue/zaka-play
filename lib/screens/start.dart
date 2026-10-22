import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class Wordmark extends StatelessWidget {
  final double size;
  final bool light;
  const Wordmark({super.key, this.size = 40, this.light = true});
  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(children: [
          TextSpan(
              text: 'zaka',
              style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, color: light ? Colors.white : Z.ink)),
          TextSpan(
              text: ' play',
              style: TextStyle(fontSize: size, fontWeight: FontWeight.w500, color: light ? Z.mint : Z.mintDark)),
        ]),
      );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _gone = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), _next);
  }

  void _next() {
    if (_gone || !mounted) return;
    _gone = true;
    final s = context.read<AppState>();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => s.onboarded ? const SignUpScreen() : const OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _next,
        child: Scaffold(
          backgroundColor: Z.violet,
          body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset('assets/icon.png', width: 120, height: 120)),
              const SizedBox(height: 24),
              const Wordmark(),
              const SizedBox(height: 8),
              const Text('Play. Earn. Cash out.', style: TextStyle(color: Color(0xFFC9BEF0), fontSize: 16)),
            ]),
          ),
        ),
      );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _i = 0;
  static const _pages = [
    (Icons.sports_esports_rounded, 'Pick a game or task', 'Choose from games, quick surveys and app offers. New ones every day.'),
    (Icons.emoji_events_rounded, 'Hit the goals, earn coins', 'Reach the level or finish the task and coins land in your wallet.'),
    (Icons.account_balance_wallet_rounded, 'Cash out your way', 'Swap coins for airtime, data, Takealot or Checkers vouchers, or cash.'),
  ];

  void _done() {
    context.read<AppState>().finishOnboarding();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Align(alignment: Alignment.topRight, child: TextButton(onPressed: _done, child: const Text('Skip'))),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _i = i),
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(color: Z.violet, borderRadius: BorderRadius.circular(40)),
                        child: Icon(p.$1, size: 80, color: Z.mint),
                      ),
                      const SizedBox(height: 36),
                      Text(p.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Text(p.$3,
                          textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Z.muted)),
                    ]);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    width: i == _i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: i == _i ? Z.violet : Z.lilac, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PillButton(_i == _pages.length - 1 ? 'Get started' : 'Next',
                  onPressed: () => _i == _pages.length - 1
                      ? _done()
                      : _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut)),
            ]),
          ),
        ),
      );
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _agree = false;

  void _submit() {
    if (!_form.currentState!.validate()) return;
    if (!_agree) {
      toast(context, 'Please confirm you are 18+ and accept the terms');
      return;
    }
    context.read<AppState>().signUp(_name.text, '+27${_phone.text}', _email.text);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    nav.popUntil((r) => r.isFirst);
    messenger.showSnackBar(const SnackBar(content: Text('Welcome bonus +${AppConfig.welcomeBonus} coins'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(24), children: [
              const SizedBox(height: 12),
              const Wordmark(size: 32, light: false),
              const SizedBox(height: 24),
              const Text('Create your account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('Get ${AppConfig.welcomeBonus} bonus coins when you sign up.',
                  style: const TextStyle(color: Z.muted, fontSize: 15)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your first name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Cellphone', prefixText: '+27 '),
                validator: (v) => (v == null || v.replaceAll(' ', '').length < 9) ? 'Enter a valid number' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || !v.contains('@') || !v.contains('.')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RichText(
                      text: TextSpan(style: const TextStyle(color: Z.ink, fontSize: 14), children: [
                        const TextSpan(text: 'I am 18 or older and accept the '),
                        TextSpan(
                            text: 'Terms',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Z.violet),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(Uri.parse(AppConfig.termsUrl))),
                        const TextSpan(text: ' and '),
                        TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Z.violet),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(Uri.parse(AppConfig.privacyUrl))),
                        const TextSpan(text: '.'),
                      ]),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              PillButton('Create account', color: Z.violet, textColor: Colors.white, onPressed: _submit),
            ]),
          ),
        ),
      );
}
