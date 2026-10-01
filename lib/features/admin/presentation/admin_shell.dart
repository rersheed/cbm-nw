import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});
  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    ref.watch(dataTickProvider);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = const [_DashboardTab(), _MembersTab(), _PendingTab()];
    final labels = ['Dashboard', 'Members', 'Pending'];
    final icons = [Icons.dashboard_outlined, Icons.people_outline, Icons.pending_actions_outlined];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(AppConstants.cityBoyLogo, height: 32),
            const SizedBox(width: 10),
            const Flexible(child: Text('Admin · CBM-NW', overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ApcColors.brown.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: const Text('Admin', style: TextStyle(color: ApcColors.brown, fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ],
        ),
        actions: [
          ConnectionStatusChip(
            connected: ref.watch(connectionConnectedProvider),
            label: ref.watch(connectionStatusProvider),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: () => ref.read(sessionProvider.notifier).logout(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: tab,
                  onDestinationSelected: (i) => setState(() => tab = i),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: ApcColors.white,
                  destinations: [
                    for (var i = 0; i < labels.length; i++)
                      NavigationRailDestination(icon: Icon(icons[i]), label: Text(labels[i])),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[tab]),
              ],
            )
          : Column(
              children: [
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      for (var i = 0; i < labels.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: ChoiceChip(
                            selected: tab == i,
                            label: Text(labels[i]),
                            onSelected: (_) => setState(() => tab = i),
                            selectedColor: ApcColors.green,
                            labelStyle: TextStyle(
                              color: tab == i ? Colors.white : ApcColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: pages[tab]),
              ],
            ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final s = repo.stats();
    final all = repo.members();
    final byGender = <String, int>{};
    final byOccupation = <String, int>{};
    final byAge = <String, int>{'18-24': 0, '25-34': 0, '35-44': 0, '45+': 0, 'Unknown': 0};
    final byDay = <String, int>{};
    for (final m in all) {
      byGender[m.gender ?? 'unknown'] = (byGender[m.gender ?? 'unknown'] ?? 0) + 1;
      final occ = (m.occupation?.isNotEmpty == true) ? m.occupation! : 'Unspecified';
      byOccupation[occ] = (byOccupation[occ] ?? 0) + 1;
      final a = m.age;
      if (a == null) {
        byAge['Unknown'] = byAge['Unknown']! + 1;
      } else if (a < 25) {
        byAge['18-24'] = byAge['18-24']! + 1;
      } else if (a < 35) {
        byAge['25-34'] = byAge['25-34']! + 1;
      } else if (a < 45) {
        byAge['35-44'] = byAge['35-44']! + 1;
      } else {
        byAge['45+'] = byAge['45+']! + 1;
      }
      final day = DateFormat('MMM d').format(m.createdAt);
      byDay[day] = (byDay[day] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _statCard('Total', s.total, ApcColors.green),
            _statCard('Approved', s.approved, ApcColors.gold),
            _statCard('Pending', s.pending, ApcColors.blue),
            _statCard('Rejected', s.rejected, ApcColors.red),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Members by State', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 10),
        SoftCard(child: _barList(repo.states.map((st) => MapEntry(st.name, repo.members(filters: MemberFilters(stateId: st.id)).length)).toList())),
        const SizedBox(height: 14),
        const Text('By LGA (top)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 10),
        SoftCard(
          child: _barList(() {
            final entries = <MapEntry<String, int>>[];
            for (final st in repo.states) {
              for (final l in st.lgas) {
                final n = repo.members(filters: MemberFilters(lgaId: l.id)).length;
                if (n > 0) entries.add(MapEntry('${st.code} · ${l.name}', n));
              }
            }
            entries.sort((a, b) => b.value.compareTo(a.value));
            return entries.take(8).toList();
          }()),
        ),
        const SizedBox(height: 14),
        const Text('By Ward / Polling Unit (sample)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 10),
        SoftCard(
          child: Column(
            children: [
              for (final m in all.take(6))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${m.wardName ?? '—'} · ${m.pollingUnitName ?? '—'}'),
                  trailing: Text(MemberStatus.label(m.status), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _barList(byGender.entries.toList()),
            ]))),
            const SizedBox(width: 12),
            Expanded(child: SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Age bands', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _barList(byAge.entries.toList()),
            ]))),
          ],
        ),
        const SizedBox(height: 14),
        SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Occupation', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _barList(byOccupation.entries.toList()..sort((a, b) => b.value.compareTo(a.value))),
        ])),
        const SizedBox(height: 14),
        SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Registration trend', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _barList(byDay.entries.toList()),
        ])),
      ],
    );
  }

  Widget _statCard(String label, int n, Color c) => SizedBox(
        width: 150,
        child: SoftCard(
          color: c.withValues(alpha: 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$n', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: c)),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: ApcColors.muted)),
            ],
          ),
        ),
      );

  Widget _barList(List<MapEntry<String, int>> entries) {
    final maxN = entries.fold<int>(1, (a, e) => e.value > a ? e.value : a);
    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: e.value / maxN,
                    minHeight: 8,
                    backgroundColor: ApcColors.border,
                    color: ApcColors.green,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MembersTab extends ConsumerStatefulWidget {
  const _MembersTab();
  @override
  ConsumerState<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends ConsumerState<_MembersTab> {
  MemberFilters filters = const MemberFilters();
  final searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final list = repo.members(filters: filters.copyWith(query: searchCtrl.text));
    final states = repo.states;
    final state = filters.stateId != null ? repo.findState(filters.stateId!) : null;
    final lgas = state?.lgas ?? [];
    final lga = filters.lgaId != null ? repo.findLga(filters.lgaId!) : null;
    final wards = lga?.wards ?? [];
    final ward = filters.wardId != null ? repo.findWard(filters.wardId!) : null;
    final pus = ward?.pollingUnits ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: PillSearchField(
            controller: searchCtrl,
            hint: 'Search name, phone, membership no, VIN',
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _filterChip(
                'Status',
                filters.status,
                {
                  null: 'All',
                  MemberStatus.pending: 'Pending',
                  MemberStatus.approved: 'Approved',
                  MemberStatus.rejected: 'Rejected',
                },
                (v) => setState(() => filters = filters.copyWith(status: v, clearStatus: v == null)),
              ),
              const SizedBox(width: 8),
              _filterChip(
                'Gender',
                filters.gender,
                {null: 'All', 'male': 'Male', 'female': 'Female', 'other': 'Other'},
                (v) => setState(() => filters = filters.copyWith(gender: v, clearGender: v == null)),
              ),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: filters.stateId,
                hint: const Text('State'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All states')),
                  for (final s in states) DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => filters = filters.copyWith(
                      stateId: v,
                      clearState: v == null,
                      clearLga: true,
                      clearWard: true,
                      clearPu: true,
                    )),
              ),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: filters.lgaId,
                hint: const Text('LGA'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All LGAs')),
                  for (final l in lgas) DropdownMenuItem(value: l.id, child: Text(l.name)),
                ],
                onChanged: (v) => setState(() => filters = filters.copyWith(
                      lgaId: v,
                      clearLga: v == null,
                      clearWard: true,
                      clearPu: true,
                    )),
              ),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: filters.wardId,
                hint: const Text('Ward'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All wards')),
                  for (final w in wards) DropdownMenuItem(value: w.id, child: Text(w.name)),
                ],
                onChanged: (v) => setState(() => filters = filters.copyWith(
                      wardId: v,
                      clearWard: v == null,
                      clearPu: true,
                    )),
              ),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: filters.pollingUnitId,
                hint: const Text('PU'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All PUs')),
                  for (final p in pus) DropdownMenuItem(value: p.id, child: Text(p.name)),
                ],
                onChanged: (v) => setState(() => filters = filters.copyWith(pollingUnitId: v, clearPu: v == null)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final m = list[i];
              return SoftCard(
                onTap: () => _showDetail(context, m.id),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ApcColors.greenSoft,
                      child: Text(m.fullName.characters.first, style: const TextStyle(fontWeight: FontWeight.w900, color: ApcColors.green)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text(
                            '${m.membershipNumber ?? 'No ID'} · ${m.phone ?? ''} · ${m.stateName ?? ''}',
                            style: const TextStyle(fontSize: 12, color: ApcColors.muted),
                          ),
                        ],
                      ),
                    ),
                    _statusPill(m.status),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String? value, Map<String?, String> options, ValueChanged<String?> onChanged) {
    return PopupMenuButton<String?>(
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final e in options.entries) PopupMenuItem(value: e.key, child: Text(e.value)),
      ],
      child: Chip(
        label: Text('$label: ${options[value] ?? 'All'}'),
        backgroundColor: ApcColors.greenSoft,
      ),
    );
  }
}

class _PendingTab extends ConsumerWidget {
  const _PendingTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final list = repo.members(filters: const MemberFilters(status: MemberStatus.pending));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final m = list[i];
        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                  TextButton(onPressed: () => _showDetail(context, m.id), child: const Text('Detail')),
                ],
              ),
              Text('${m.phone} · ${m.stateName} / ${m.lgaName} / ${m.wardName}', style: const TextStyle(color: ApcColors.muted, fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GradientCtaButton(
                      label: 'Approve',
                      icon: Icons.check_rounded,
                      onPressed: () async {
                        await ref.read(repositoryProvider).approveMember(m.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approved ${m.fullName}')));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final reason = await _askReason(context);
                        if (reason == null || reason.isEmpty) return;
                        await ref.read(repositoryProvider).rejectMember(m.id, reason: reason);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rejected ${m.fullName}')));
                        }
                      },
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _statusPill(String status) {
  final c = switch (status) {
    MemberStatus.approved => ApcColors.green,
    MemberStatus.pending => ApcColors.blue,
    MemberStatus.rejected => ApcColors.red,
    _ => ApcColors.muted,
  };
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadii.pill)),
    child: Text(MemberStatus.label(status), style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 11)),
  );
}

Future<String?> _askReason(BuildContext context) async {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Rejection reason'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Reason'), autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Reject')),
      ],
    ),
  );
}

void _showDetail(BuildContext context, String memberId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: ApcColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _MemberDetailSheet(memberId: memberId),
  );
}

class _MemberDetailSheet extends ConsumerWidget {
  const _MemberDetailSheet({required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dataTickProvider);
    final m = ref.watch(repositoryProvider).findMember(memberId);
    if (m == null) return const SizedBox(height: 200, child: Center(child: Text('Not found')));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ApcColors.border, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20))),
              _statusPill(m.status),
            ],
          ),
          if (m.membershipNumber != null)
            Text(m.membershipNumber!, style: const TextStyle(fontWeight: FontWeight.w800, color: ApcColors.brown)),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('Phone', m.phone ?? '—'),
                _kv('Email', m.email ?? '—'),
                _kv('Gender', m.gender ?? '—'),
                _kv('DOB', m.dateOfBirth?.toIso8601String().split('T').first ?? '—'),
                _kv('Age', '${m.age ?? '—'}'),
                _kv('Occupation', m.occupation ?? '—'),
                _kv('State', m.stateName ?? '—'),
                _kv('LGA', m.lgaName ?? '—'),
                _kv('Ward', m.wardName ?? '—'),
                _kv('Polling Unit', m.pollingUnitName ?? '—'),
                _kv('Registered', DateFormat.yMMMd().format(m.createdAt)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            color: ApcColors.redSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Admin-only voter data', style: TextStyle(fontWeight: FontWeight.w900, color: ApcColors.red)),
                const SizedBox(height: 8),
                _kv('Registered voter', m.isRegisteredVoter ? 'Yes' : 'No'),
                if (m.isRegisteredVoter) ...[
                  _kv('VIN', m.vin ?? '—'),
                  _kv('Voter card', m.voterCardUrl != null ? 'On file (stub)' : 'Not uploaded'),
                ],
              ],
            ),
          ),
          if (m.status == MemberStatus.pending) ...[
            const SizedBox(height: 14),
            GradientCtaButton(
              label: 'Approve member',
              onPressed: () async {
                await ref.read(repositoryProvider).approveMember(m.id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final reason = await _askReason(context);
                if (reason == null || reason.isEmpty) return;
                await ref.read(repositoryProvider).rejectMember(m.id, reason: reason);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Reject with reason'),
            ),
          ],
          if (m.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Text('Rejection reason: ${m.rejectionReason}', style: const TextStyle(color: ApcColors.red, fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(k, style: const TextStyle(color: ApcColors.muted, fontWeight: FontWeight.w600))),
            Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );
}
