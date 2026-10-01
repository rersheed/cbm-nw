import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class ApprovalListScreen extends ConsumerWidget {
  const ApprovalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dataTickProvider);
    final repo = ref.watch(repositoryProvider);
    final pending = repo.members(status: MemberStatus.pending);

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: pending.isEmpty
          ? const Center(child: Text('No pending members'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              itemBuilder: (_, i) {
                final m = pending[i];
                return SoftCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        '${MemberCategory.label(m.category)} · ${m.lgaName ?? ''} · ${m.wardName ?? ''}',
                        style: const TextStyle(color: ApcColors.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ApprovalTimeline(currentStatus: m.status, compact: true),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await repo.rejectMember(m.id, reason: 'Failed verification');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Rejected ${m.fullName}')),
                                  );
                                }
                              },
                              child: const Text('Reject', style: TextStyle(color: ApcColors.red)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                final updated = await repo.approveMember(m.id, note: 'Ward approved');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Approved · ${updated.memberCode}')),
                                  );
                                }
                              },
                              child: const Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
