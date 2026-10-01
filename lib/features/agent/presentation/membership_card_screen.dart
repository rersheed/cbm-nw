import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class MembershipCardScreen extends ConsumerWidget {
  const MembershipCardScreen({super.key, required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dataTickProvider);
    final m = ref.watch(repositoryProvider).findMember(memberId);
    if (m == null) {
      return Scaffold(appBar: AppBar(title: const Text('Card')), body: const Center(child: Text('Member not found')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Membership Card')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [ApcColors.greenDark, ApcColors.green, Color(0xFF5BCF75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: softShadow(blur: 28, y: 14, opacity: 0.2),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(AppConstants.cityBoyLogo, height: 48),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ApcColors.gold.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: const Text('NW ZONE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white54),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 48),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(MemberCategory.label(m.category), style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                          const SizedBox(height: 8),
                          Text(
                            m.memberCode ?? 'Pending ID',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text('${m.stateName ?? ''} · ${m.lgaName ?? ''} · ${m.wardName ?? ''}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text('City Boy Movement', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.qr_code_2, size: 48, color: ApcColors.ink),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                ApprovalTimeline(currentStatus: m.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
