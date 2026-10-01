import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';

class StateDashboard extends ConsumerStatefulWidget {
  const StateDashboard({super.key});
  @override
  ConsumerState<StateDashboard> createState() => _StateDashboardState();
}

class _StateDashboardState extends ConsumerState<StateDashboard> {
  String? drillState;
  String? drillLga;
  String? drillWard;

  @override
  Widget build(BuildContext context) {
    ref.watch(dataTickProvider);
    final user = ref.watch(sessionProvider);
    final repo = ref.watch(repositoryProvider);
    drillState ??= user?.stateId ?? (repo.states.isNotEmpty ? repo.states.first.id : null);
    final stats = drillState != null ? repo.stats(stateId: drillState) : repo.stats();
    final state = drillState != null ? repo.findState(drillState!) : null;
    final agents = drillState != null ? repo.agents(stateId: drillState) : repo.agents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Coordinator'),
        actions: [
          IconButton(onPressed: () => ref.read(sessionProvider.notifier).logout(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          SoftCard(
            color: ApcColors.greenDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.fullName ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                Text('${state?.name ?? 'NW'} · State view', style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: drillState,
            decoration: const InputDecoration(labelText: 'State'),
            items: [for (final s in repo.states) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: (v) => setState(() {
              drillState = v;
              drillLga = null;
              drillWard = null;
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SoftCard(child: _metric('Members', stats.registered, ApcColors.green))),
              const SizedBox(width: 8),
              Expanded(child: SoftCard(child: _metric('LGAs', state?.lgas.length ?? 0, ApcColors.blue))),
              const SizedBox(width: 8),
              Expanded(child: SoftCard(child: _metric('Agents', agents.length, ApcColors.brown))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Geography drill', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (drillWard != null) ...[
            TextButton(
              onPressed: () => setState(() => drillWard = null),
              child: const Text('← Back to wards'),
            ),
            for (final m in repo.members(wardId: drillWard))
              SoftCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${MemberStatus.label(m.status)} · ${MemberCategory.label(m.category)}'),
                ),
              ),
          ] else if (drillLga != null) ...[
            TextButton(
              onPressed: () => setState(() {
                drillLga = null;
                drillWard = null;
              }),
              child: const Text('← Back to LGAs'),
            ),
            for (final w in (repo.findLga(drillLga!)?.wards ?? <WardGeo>[]))
              SoftCard(
                margin: const EdgeInsets.only(bottom: 8),
                onTap: () => setState(() => drillWard = w.id),
                child: Row(
                  children: [
                    Expanded(child: Text(w.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                    Text('${repo.members(wardId: w.id).length}', style: const TextStyle(fontWeight: FontWeight.w800, color: ApcColors.green)),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
          ] else ...[
            for (final l in (state?.lgas ?? <LgaGeo>[]))
              SoftCard(
                margin: const EdgeInsets.only(bottom: 8),
                onTap: () => setState(() => drillLga = l.id),
                child: Row(
                  children: [
                    Expanded(child: Text(l.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                    Text('${repo.members(lgaId: l.id).length} members', style: const TextStyle(color: ApcColors.muted)),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String l, int v, Color c) => Column(
        children: [
          Text('$v', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: c)),
          Text(l, style: const TextStyle(fontSize: 11, color: ApcColors.muted)),
        ],
      );
}
