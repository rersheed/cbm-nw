import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class AgentDashboard extends ConsumerStatefulWidget {
  const AgentDashboard({super.key});
  @override
  ConsumerState<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends ConsumerState<AgentDashboard> {
  int nav = 0;

  @override
  Widget build(BuildContext context) {
    ref.watch(dataTickProvider);
    final user = ref.watch(sessionProvider);
    final repo = ref.watch(repositoryProvider);
    final connected = ref.watch(connectionConnectedProvider);
    final connLabel = ref.watch(connectionStatusProvider);
    final stats = repo.stats(registeredBy: user?.id);
    final myMembers = repo.members(registeredBy: user?.id);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                children: [
                  Row(
                    children: [
                      Image.asset(AppConstants.cityBoyLogo, height: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.fullName.split(' ').first ?? 'Agent'}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                            Text(
                              AppRoles.label(user?.role ?? ''),
                              style: const TextStyle(color: ApcColors.muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ConnectionStatusChip(connected: connected, label: connLabel),
                      IconButton(
                        onPressed: () => ref.read(sessionProvider.notifier).logout(),
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    color: ApcColors.green,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.zoneLabel,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Field Registration',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${stats.registered} members · ${stats.pending} pending',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.badge_outlined, color: Colors.white, size: 42),
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
                    childAspectRatio: 1.45,
                    children: [
                      _StatTile('Registered', stats.registered, ApcColors.green, Icons.people_alt_outlined),
                      _StatTile('Pending', stats.pending, ApcColors.blue, Icons.hourglass_top_rounded),
                      _StatTile('Approved', stats.approved, ApcColors.brown, Icons.verified_outlined),
                      _StatTile('Rejected', stats.rejected, ApcColors.red, Icons.cancel_outlined),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GradientCtaButton(
                    label: 'Register New Member',
                    icon: Icons.person_add_alt_1_rounded,
                    onPressed: () => context.push('/agent/register'),
                  ),
                  const SizedBox(height: 20),
                  const Text('Recent registrations', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  if (myMembers.isEmpty)
                    const SoftCard(child: Text('No members yet — start registering.', style: TextStyle(color: ApcColors.muted))),
                  for (final m in myMembers.take(8))
                    SoftCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      onTap: m.status == MemberStatus.approved
                          ? () => context.push('/agent/card/${m.id}')
                          : null,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: ApcColors.greenSoft,
                            child: Text(m.fullName.characters.first, style: const TextStyle(color: ApcColors.green, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(
                                  '${MemberCategory.label(m.category)} · ${MemberStatus.label(m.status)}',
                                  style: const TextStyle(fontSize: 12, color: ApcColors.muted),
                                ),
                              ],
                            ),
                          ),
                          if (m.status == MemberStatus.approved)
                            const Icon(Icons.qr_code_2_rounded, color: ApcColors.green),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            FloatingPillNav(
              index: nav,
              onChanged: (i) {
                setState(() => nav = i);
                if (i == 1) context.push('/agent/register');
              },
              items: const [
                (icon: Icons.home_rounded, label: 'Home'),
                (icon: Icons.person_add_alt_1_rounded, label: 'Register'),
                (icon: Icons.badge_outlined, label: 'Cards'),
                (icon: Icons.settings_outlined, label: 'More'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.value, this.color, this.icon);
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text('$value', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: ApcColors.muted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
