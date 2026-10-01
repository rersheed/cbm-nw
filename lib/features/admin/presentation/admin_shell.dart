import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final pages = [
      const _SituationTab(),
      const _MembersTab(),
      const _AgentsTab(),
      const _OrgTreeTab(),
      const _ReportsTab(),
      const _CommsTab(),
    ];
    final labels = ['Situation', 'Members', 'Agents', 'Org', 'Reports', 'Comms'];
    final icons = [
      Icons.monitor_heart_outlined,
      Icons.table_chart_outlined,
      Icons.support_agent_outlined,
      Icons.account_tree_outlined,
      Icons.insights_outlined,
      Icons.campaign_outlined,
    ];

    final rail = NavigationRail(
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      labelType: NavigationRailLabelType.all,
      backgroundColor: ApcColors.white,
      destinations: [
        for (var i = 0; i < labels.length; i++)
          NavigationRailDestination(icon: Icon(icons[i]), label: Text(labels[i])),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(AppConstants.cityBoyLogo, height: 32),
            const SizedBox(width: 10),
            const Text('Situation Room · NW'),
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
                rail,
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

class _SituationTab extends ConsumerWidget {
  const _SituationTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final s = repo.stats();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _big('Members', s.registered, ApcColors.green),
            _big('States', s.states, ApcColors.blue),
            _big('Agents', s.agents, ApcColors.brown),
            _big('Approved', s.approved, ApcColors.gold),
            _big('Pending', s.pending, ApcColors.blue),
            _big('Rejected', s.rejected, ApcColors.red),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Growth by state', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 10),
        SoftCard(
          child: Column(
            children: [
              for (final st in repo.states)
                Builder(builder: (_) {
                  final n = repo.members(stateId: st.id).length;
                  final maxN = repo.states
                      .map((x) => repo.members(stateId: x.id).length)
                      .fold<int>(1, (a, b) => a > b ? a : b);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(st.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                          Text('$n'),
                        ]),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: n / maxN,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(6),
                          color: ApcColors.green,
                          backgroundColor: ApcColors.surface,
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _big(String l, int v, Color c) => SizedBox(
        width: 160,
        child: SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$v', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: c)),
              Text(l, style: const TextStyle(color: ApcColors.muted, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _MembersTab extends ConsumerWidget {
  const _MembersTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(repositoryProvider).members();
    return LayoutBuilder(builder: (context, c) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SoftCard(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('State')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Phone')),
              ],
              rows: [
                for (final m in members)
                  DataRow(cells: [
                    DataCell(Text(m.fullName)),
                    DataCell(Text(m.memberCode ?? '—')),
                    DataCell(Text(MemberCategory.label(m.category))),
                    DataCell(Text(m.stateName ?? '—')),
                    DataCell(Text(MemberStatus.label(m.status))),
                    DataCell(Text(m.phone ?? '—')),
                  ]),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _AgentsTab extends ConsumerWidget {
  const _AgentsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final agents = repo.demoUsers.where((u) => u.role == AppRoles.registrationAgent).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final a in agents)
          SoftCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: ApcColors.greenSoft, child: Text(a.fullName.characters.first)),
              title: Text(a.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${a.phone} · ${repo.findState(a.stateId ?? '')?.name ?? '—'}'),
              trailing: Chip(
                label: Text('${repo.members(registeredBy: a.id).length} regs'),
                backgroundColor: ApcColors.greenSoft,
              ),
            ),
          ),
      ],
    );
  }
}

class _OrgTreeTab extends ConsumerWidget {
  const _OrgTreeTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(repositoryProvider).demoUsers;
    final byRole = <String, List<DemoUser>>{};
    for (final u in users) {
      byRole.putIfAbsent(u.role, () => []).add(u);
    }
    final order = [
      AppRoles.admin,
      AppRoles.stateCoordinator,
      AppRoles.lgaCoordinator,
      AppRoles.wardCoordinator,
      AppRoles.registrationAgent,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final role in order)
          SoftCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppRoles.label(role), style: const TextStyle(fontWeight: FontWeight.w900, color: ApcColors.green)),
                const SizedBox(height: 8),
                for (final u in byRole[role] ?? <DemoUser>[])
                  Padding(
                    padding: EdgeInsets.only(left: order.indexOf(role) * 8.0, bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 18, color: ApcColors.muted),
                        const SizedBox(width: 8),
                        Text('${u.fullName} · ${u.phone}'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final all = repo.members();
    final byCat = <String, int>{};
    final byGender = <String, int>{};
    final byState = <String, int>{};
    for (final m in all) {
      byCat[m.category] = (byCat[m.category] ?? 0) + 1;
      byGender[m.gender ?? 'unknown'] = (byGender[m.gender ?? 'unknown'] ?? 0) + 1;
      byState[m.stateName ?? '?'] = (byState[m.stateName ?? '?'] ?? 0) + 1;
    }
    final wardRank = <({String name, int n})>[];
    for (final st in repo.states) {
      for (final l in st.lgas) {
        for (final w in l.wards) {
          wardRank.add((name: '${w.name} (${st.code})', n: repo.members(wardId: w.id).length));
        }
      }
    }
    wardRank.sort((a, b) => b.n.compareTo(a.n));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Membership by category', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in byCat.entries)
              SoftCard(
                child: Text('${MemberCategory.label(e.key)}: ${e.value}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('State comparison', style: TextStyle(fontWeight: FontWeight.w800)),
        SoftCard(
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              for (final e in byState.entries)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.key),
                  trailing: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Ward ranking (top 10)', style: TextStyle(fontWeight: FontWeight.w800)),
        SoftCard(
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              for (final w in wardRank.take(10))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(w.name),
                  trailing: Text('${w.n}', style: const TextStyle(fontWeight: FontWeight.w900, color: ApcColors.green)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Age / Gender', style: TextStyle(fontWeight: FontWeight.w800)),
        SoftCard(
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in byGender.entries) Text('${e.key}: ${e.value}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Avg age (approx): ${_avgAge(all)?.toStringAsFixed(0) ?? '—'}',
                style: const TextStyle(color: ApcColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double? _avgAge(List<Member> all) {
    final ages = all.map((m) => m.age).whereType<int>().toList();
    if (ages.isEmpty) return null;
    return ages.reduce((a, b) => a + b) / ages.length;
  }
}

class _CommsTab extends ConsumerStatefulWidget {
  const _CommsTab();
  @override
  ConsumerState<_CommsTab> createState() => _CommsTabState();
}

class _CommsTabState extends ConsumerState<_CommsTab> {
  String audience = 'all';
  final body = TextEditingController();
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(repositoryProvider).messages();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Send message (demo)', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final a in ['all', 'agents', 'coordinators', 'members'])
                RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(a[0].toUpperCase() + a.substring(1)),
                  value: a,
                  groupValue: audience,
                  onChanged: (v) => setState(() => audience = v ?? 'all'),
                ),
              TextField(
                controller: body,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Message', alignLabelWithHint: true),
              ),
              const SizedBox(height: 12),
              GradientCtaButton(
                label: 'Send',
                busy: busy,
                icon: Icons.send_rounded,
                onPressed: () async {
                  if (body.text.trim().isEmpty) return;
                  setState(() => busy = true);
                  await ref.read(repositoryProvider).sendMessage(
                        audienceScope: audience,
                        body: body.text.trim(),
                      );
                  body.clear();
                  if (mounted) {
                    setState(() => busy = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message sent (local/demo)')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Outbox', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (messages.isEmpty) const SoftCard(child: Text('No messages yet', style: TextStyle(color: ApcColors.muted))),
        for (final m in messages)
          SoftCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.audienceScope, style: const TextStyle(fontWeight: FontWeight.w800, color: ApcColors.green)),
                Text(m.body),
                Text(
                  m.createdAt.toLocal().toString().split('.').first,
                  style: const TextStyle(fontSize: 11, color: ApcColors.muted),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
