import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class LgaDashboard extends ConsumerWidget {
  const LgaDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dataTickProvider);
    final user = ref.watch(sessionProvider);
    final repo = ref.watch(repositoryProvider);
    final lgaId = user?.lgaId;
    final stats = lgaId != null ? repo.stats(lgaId: lgaId) : repo.stats();
    final lga = lgaId != null ? repo.findLga(lgaId) : null;
    final wards = lga?.wards ??
        (repo.states.isNotEmpty && repo.states.first.lgas.isNotEmpty
            ? repo.states.first.lgas.first.wards
            : <dynamic>[]);

    final wardPerf = <({String name, int count})>[];
    for (final w in wards) {
      final c = repo.members(wardId: w.id).length;
      wardPerf.add((name: w.name as String, count: c));
    }
    wardPerf.sort((a, b) => b.count.compareTo(a.count));
    final maxC = wardPerf.isEmpty ? 1 : wardPerf.map((e) => e.count).reduce((a, b) => a > b ? a : b).clamp(1, 9999);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LGA Coordinator'),
        actions: [
          IconButton(onPressed: () => context.push('/ward/approvals'), icon: const Icon(Icons.fact_check_outlined)),
          IconButton(onPressed: () => ref.read(sessionProvider.notifier).logout(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          SoftCard(
            color: ApcColors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.fullName ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                Text('${lga?.name ?? 'Demo LGA'} · ${AppRoles.label(user?.role ?? '')}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: SoftCard(child: _num('Total', stats.registered, ApcColors.green))),
              const SizedBox(width: 10),
              Expanded(child: SoftCard(child: _num('Wards', wards.length, ApcColors.brown))),
              const SizedBox(width: 10),
              Expanded(child: SoftCard(child: _num('Pending', stats.pending, ApcColors.blue))),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Ward performance', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SoftCard(
            child: Column(
              children: [
                for (final w in wardPerf)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(w.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                            Text('${w.count}', style: const TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: w.count / maxC,
                            minHeight: 8,
                            backgroundColor: ApcColors.surface,
                            color: ApcColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (wardPerf.isEmpty) const Text('No ward data', style: TextStyle(color: ApcColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _num(String l, int v, Color c) => Column(
        children: [
          Text('$v', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c)),
          Text(l, style: const TextStyle(fontSize: 11, color: ApcColors.muted, fontWeight: FontWeight.w600)),
        ],
      );
}
