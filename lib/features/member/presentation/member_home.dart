import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class MemberHome extends ConsumerWidget {
  const MemberHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dataTickProvider);
    final user = ref.watch(sessionProvider);
    final repo = ref.watch(repositoryProvider);
    final member = repo.memberForCurrentUser();
    final connected = ref.watch(connectionConnectedProvider);
    final connLabel = ref.watch(connectionStatusProvider);

    Color statusColor(String? s) => switch (s) {
          MemberStatus.approved => ApcColors.green,
          MemberStatus.pending => ApcColors.blue,
          MemberStatus.rejected => ApcColors.red,
          _ => ApcColors.muted,
        };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Row(
              children: [
                Image.asset(AppConstants.cityBoyLogo, height: 40),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CBM-NW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      Text(AppConstants.zoneLabel, style: TextStyle(color: ApcColors.muted, fontSize: 12)),
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
            const SizedBox(height: 18),
            SoftCard(
              color: ApcColors.greenSoft,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: ApcColors.green,
                    child: Text(
                      (user?.fullName ?? 'M').characters.first.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? 'Member', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        Text(user?.phone ?? '', style: const TextStyle(color: ApcColors.muted)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor(member?.status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            MemberStatus.label(member?.status ?? MemberStatus.none),
                            style: TextStyle(
                              color: statusColor(member?.status),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (member == null) ...[
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Complete membership registration', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                      '5 steps: Personal → Location → Voter → Photo → Review. After submit your status will be Pending until an admin approves.',
                      style: TextStyle(color: ApcColors.muted, height: 1.35),
                    ),
                    const SizedBox(height: 14),
                    GradientCtaButton(
                      label: 'Start registration',
                      icon: Icons.how_to_reg_rounded,
                      onPressed: () => context.push('/member/register'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.status == MemberStatus.approved
                          ? 'You are an approved City Boy NW member'
                          : member.status == MemberStatus.pending
                              ? 'Application under review'
                              : 'Application was rejected',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    if (member.membershipNumber != null) ...[
                      const SizedBox(height: 6),
                      Text(member.membershipNumber!, style: const TextStyle(fontWeight: FontWeight.w800, color: ApcColors.brown)),
                    ],
                    if (member.rejectionReason != null) ...[
                      const SizedBox(height: 8),
                      Text('Reason: ${member.rejectionReason}', style: const TextStyle(color: ApcColors.red)),
                    ],
                    const SizedBox(height: 12),
                    ApprovalTimeline(currentStatus: member.status, compact: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (member.status == MemberStatus.approved)
                    SizedBox(
                      width: (MediaQuery.sizeOf(context).width - 46) / 2,
                      child: ActionGridTile(
                        icon: Icons.badge_outlined,
                        label: 'Membership card',
                        color: ApcColors.green,
                        onTap: () => context.push('/member/card/${member.id}'),
                      ),
                    ),
                  SizedBox(
                    width: (MediaQuery.sizeOf(context).width - 46) / 2,
                    child: ActionGridTile(
                      icon: Icons.person_outline,
                      label: 'Edit profile',
                      color: ApcColors.brown,
                      onTap: () => context.push('/member/profile'),
                    ),
                  ),
                  if (member.status == MemberStatus.rejected)
                    SizedBox(
                      width: (MediaQuery.sizeOf(context).width - 46) / 2,
                      child: ActionGridTile(
                        icon: Icons.refresh_rounded,
                        label: 'Re-apply',
                        color: ApcColors.blue,
                        onTap: () => context.push('/member/register'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
