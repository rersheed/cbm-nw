import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final ctrls = List.generate(6, (_) => TextEditingController());
  final foci = List.generate(6, (_) => FocusNode());
  bool busy = false;

  @override
  void dispose() {
    for (final c in ctrls) {
      c.dispose();
    }
    for (final f in foci) {
      f.dispose();
    }
    super.dispose();
  }

  String get code => ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter 6 digits')));
      return;
    }
    setState(() => busy = true);
    final repo = ref.read(repositoryProvider);
    final user = repo.demoUsers.first;
    await ref.read(sessionProvider.notifier).login(user);
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'Enter the 6-digit code sent to your phone.\nDemo hint: any 6 digits work (e.g. 123456).',
            style: TextStyle(color: ApcColors.muted),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 6; i++)
                SizedBox(
                  width: 48,
                  child: TextField(
                    controller: ctrls[i],
                    focusNode: foci[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) foci[i + 1].requestFocus();
                      if (v.isEmpty && i > 0) foci[i - 1].requestFocus();
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          GradientCtaButton(label: 'Verify', busy: busy, onPressed: _verify),
          TextButton(onPressed: () => context.pop(), child: const Text('Back')),
        ],
      ),
    );
  }
}
