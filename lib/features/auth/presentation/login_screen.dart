import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  DemoUser? selected;
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController(text: 'demo1234');
  bool busy = false;
  bool useOtp = false;

  @override
  Widget build(BuildContext context) {
    final init = ref.watch(repoInitProvider);
    final connected = ref.watch(connectionConnectedProvider);
    final connLabel = ref.watch(connectionStatusProvider);

    return Scaffold(
      backgroundColor: ApcColors.surface,
      body: SafeArea(
        child: init.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (repo) {
            final users = repo.demoUsers;
            selected ??= users.isNotEmpty ? users.first : null;
            if (selected != null && phoneCtrl.text.isEmpty) {
              phoneCtrl.text = selected!.phone;
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ConnectionStatusChip(connected: connected, label: connLabel),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white),
                      boxShadow: softShadow(blur: 28, y: 12, opacity: 0.08),
                    ),
                    child: Image.asset(AppConstants.cityBoyLogo, height: 64),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ApcColors.ink),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to City Boy NW Membership',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ApcColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 22),
                SoftCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!useOtp)
                        TextField(
                          controller: passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password (demo)',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                            suffixIcon: Icon(Icons.visibility_outlined),
                          ),
                        ),
                      if (useOtp)
                        const Text(
                          'OTP will be requested on the next screen (demo: 123456)',
                          style: TextStyle(fontSize: 12, color: ApcColors.muted),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => setState(() => useOtp = !useOtp),
                            child: Text(useOtp ? 'Use password' : 'Use OTP instead'),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/forgot'),
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Pick a demo role', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final u in users)
                      ChoiceChip(
                        selected: selected?.id == u.id,
                        label: Text(AppRoles.shortLabel(u.role)),
                        selectedColor: ApcColors.green,
                        labelStyle: TextStyle(
                          color: selected?.id == u.id ? ApcColors.white : ApcColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => setState(() {
                          selected = u;
                          phoneCtrl.text = u.phone;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (selected != null)
                  SoftCard(
                    padding: const EdgeInsets.all(14),
                    color: ApcColors.greenSoft,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: ApcColors.green,
                          child: Text(
                            selected!.fullName.characters.first,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(selected!.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
                              Text(
                                '${AppRoles.label(selected!.role)} · ${selected!.phone}',
                                style: const TextStyle(fontSize: 12, color: ApcColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                GradientCtaButton(
                  label: useOtp ? 'Continue to OTP' : 'Login',
                  busy: busy,
                  onPressed: selected == null
                      ? null
                      : () async {
                          setState(() => busy = true);
                          if (useOtp) {
                            ref.read(pendingLoginUserProvider.notifier).setUser(selected);
                            if (mounted) {
                              setState(() => busy = false);
                              context.push('/otp');
                            }
                          } else {
                            await ref.read(sessionProvider.notifier).login(selected!);
                            if (mounted) setState(() => busy = false);
                          }
                        },
                ),
                const SizedBox(height: 18),
                Text(
                  'Agent → Ward → LGA → State → Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ApcColors.muted.withValues(alpha: 0.9),
                    fontSize: 11,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
