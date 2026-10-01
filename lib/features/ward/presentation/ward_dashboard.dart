import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class WardDashboard extends ConsumerWidget {
  const WardDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dataTickProvider);
    final user = ref.watch(sessionProvider);
    final repo = ref.watch(repositoryProvider);
    final stats = repo.stats(wardId: user?.wardId, stateId: user?.stateId, lgaId: user?.lgaId);
    // Prefer ward scope when set; else show all for demo
    final scoped = user?.wardId != null
        ? repo.stats(wardId: user!.wardId)
        : repo.stats();
    final agents = user?.wardId != null ? repo.agents(wardId: user!.wardId) : repo.agents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ward Coordinator'),
        actions: [
          IconButton(onPressed: () => ref.read(sessionProvider.notifier).logout(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          SoftCard(
            color: ApcColors.brown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.fullName ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                Text(AppRoles.label(user?.role ?? ''), style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _tile('Members', scoped.registered, ApcColors.green),
              _tile('Pending', scoped.pending, ApcColors.blue),
              _tile('Agents', agents.length, ApcColors.brown),
              _tile('Activities', scoped.approved + scoped.pending, ApcColors.gold),
            ],
          ),
          const SizedBox(height: 16),
          GradientCtaButton(
            label: 'Review pending approvals',
            icon: Icons.fact_check_outlined,
            onPressed: () => context.push('/ward/approvals'),
          ),
          const SizedBox(height: 16),
          const Text('Ward agents', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final a in agents)
            SoftCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: ApcColors.greenSoft, child: Text(a.fullName.characters.first)),
                title: Text(a.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(a.phone),
              ),
            ),
          if (agents.isEmpty) const SoftCard(child: Text('No agents in this ward scope (showing demo).', style: TextStyle(color: ApcColors.muted))),
          // ignore unused
          if (stats.registered < 0) const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _tile(String label, int v, Color c) => SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$v', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: c)),
            Text(label, style: const TextStyle(color: ApcColors.muted, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
