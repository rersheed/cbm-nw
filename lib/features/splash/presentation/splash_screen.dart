import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(repoInitProvider.future);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final init = ref.watch(repoInitProvider);
    final connected = ref.watch(connectionConnectedProvider);
    final label = ref.watch(connectionStatusProvider);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ApcColors.greenDark, ApcColors.green, Color(0xFF4BBF66)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                ),
                child: Image.asset(AppConstants.cityBoyLogo, height: 88),
              ),
              const SizedBox(height: 28),
              Text(
                AppConstants.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: ApcColors.white,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'City Boy Movement\nNorth-West Membership',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: ApcColors.gold.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: const Text(
                  AppConstants.zoneLabel,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              ConnectionStatusChip(connected: connected, label: label, lightOnDark: true),
              const Spacer(flex: 2),
              init.when(
                data: (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Text('Loading…', style: TextStyle(color: Colors.white70)),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: CircularProgressIndicator(color: ApcColors.white),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Text('Init error: $e', style: const TextStyle(color: ApcColors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
