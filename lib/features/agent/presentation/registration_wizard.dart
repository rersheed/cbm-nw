import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';

class RegistrationWizard extends ConsumerStatefulWidget {
  const RegistrationWizard({super.key});
  @override
  ConsumerState<RegistrationWizard> createState() => _RegistrationWizardState();
}

class _RegistrationWizardState extends ConsumerState<RegistrationWizard> {
  int step = 0;
  bool busy = false;
  bool photoTaken = false;
  bool idUploaded = false;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final occupationCtrl = TextEditingController();
  final educationCtrl = TextEditingController();
  String gender = 'male';
  DateTime? dob = DateTime(1998, 5, 12);

  String? stateId;
  String? lgaId;
  String? wardId;
  String? communityId;
  String category = MemberCategory.youth;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final states = repo.states;
    stateId ??= states.isNotEmpty ? states.first.id : null;
    final state = stateId != null ? repo.findState(stateId!) : null;
    final lgas = state?.lgas ?? [];
    if (lgaId == null && lgas.isNotEmpty) lgaId = lgas.first.id;
    final lga = lgaId != null ? repo.findLga(lgaId!) : null;
    final wards = lga?.wards ?? [];
    if (wardId == null && wards.isNotEmpty) wardId = wards.first.id;
    final ward = wardId != null ? repo.findWard(wardId!) : null;
    final communities = ward?.communities ?? [];
    if (communityId == null && communities.isNotEmpty) communityId = communities.first.id;

    final titles = ['Personal', 'Location', 'Category', 'Photo', 'Review'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Register · Step ${step + 1}/5'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(repositoryProvider).saveDraft('reg_draft', {
                'fullName': nameCtrl.text,
                'phone': phoneCtrl.text,
                'step': step,
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Draft saved offline (Hive)')),
                );
              }
            },
            child: const Text('Save draft'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: Row(
              children: [
                for (var i = 0; i < 5; i++)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 5,
                      decoration: BoxDecoration(
                        color: i <= step ? ApcColors.green : ApcColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(titles[step], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              children: [
                if (step == 0) ...[
                  FormSectionCard(
                    title: 'Personal information',
                    icon: Icons.person_outline,
                    child: Column(
                      children: [
                        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
                        const SizedBox(height: 10),
                        TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: gender,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: const [
                            DropdownMenuItem(value: 'male', child: Text('Male')),
                            DropdownMenuItem(value: 'female', child: Text('Female')),
                            DropdownMenuItem(value: 'other', child: Text('Other')),
                          ],
                          onChanged: (v) => setState(() => gender = v ?? 'male'),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Date of birth: ${dob?.toIso8601String().split('T').first ?? '—'}'),
                          trailing: const Icon(Icons.calendar_today_outlined),
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                              initialDate: dob ?? DateTime(1995),
                            );
                            if (d != null) setState(() => dob = d);
                          },
                        ),
                        TextField(controller: occupationCtrl, decoration: const InputDecoration(labelText: 'Occupation')),
                        const SizedBox(height: 10),
                        TextField(controller: educationCtrl, decoration: const InputDecoration(labelText: 'Education')),
                      ],
                    ),
                  ),
                ],
                if (step == 1) ...[
                  FormSectionCard(
                    title: 'Location (NW)',
                    icon: Icons.map_outlined,
                    accent: ApcColors.brown,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: stateId,
                          decoration: const InputDecoration(labelText: 'State'),
                          items: [for (final s in states) DropdownMenuItem(value: s.id, child: Text(s.name))],
                          onChanged: (v) => setState(() {
                            stateId = v;
                            lgaId = null;
                            wardId = null;
                            communityId = null;
                          }),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: lgaId,
                          decoration: const InputDecoration(labelText: 'LGA'),
                          items: [for (final l in lgas) DropdownMenuItem(value: l.id, child: Text(l.name))],
                          onChanged: (v) => setState(() {
                            lgaId = v;
                            wardId = null;
                            communityId = null;
                          }),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: wardId,
                          decoration: const InputDecoration(labelText: 'Ward'),
                          items: [for (final w in wards) DropdownMenuItem(value: w.id, child: Text(w.name))],
                          onChanged: (v) => setState(() {
                            wardId = v;
                            communityId = null;
                          }),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: communityId,
                          decoration: const InputDecoration(labelText: 'Community'),
                          items: [for (final c in communities) DropdownMenuItem(value: c.id, child: Text(c.name))],
                          onChanged: (v) => setState(() => communityId = v),
                        ),
                      ],
                    ),
                  ),
                ],
                if (step == 2) ...[
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final c in MemberCategory.all)
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 56) / 2,
                          child: SoftCard(
                            color: category == c ? ApcColors.greenSoft : null,
                            onTap: () => setState(() => category = c),
                            child: Column(
                              children: [
                                Icon(
                                  _catIcon(c),
                                  color: category == c ? ApcColors.green : ApcColors.muted,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  MemberCategory.label(c),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: category == c ? ApcColors.green : ApcColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                if (step == 3) ...[
                  SoftCard(
                    child: Column(
                      children: [
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ApcColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ApcColors.border),
                          ),
                          child: photoTaken
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, color: ApcColors.green, size: 48),
                                    Text('Photo captured (stub)', style: TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_outlined, size: 48, color: ApcColors.muted),
                                    Text('Camera stub', style: TextStyle(color: ApcColors.muted)),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 12),
                        GradientCtaButton(
                          label: photoTaken ? 'Retake photo' : 'Capture photo',
                          icon: Icons.photo_camera_outlined,
                          onPressed: () => setState(() => photoTaken = true),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => setState(() => idUploaded = !idUploaded),
                          icon: Icon(idUploaded ? Icons.check : Icons.upload_file_outlined),
                          label: Text(idUploaded ? 'ID uploaded (optional)' : 'Upload ID (optional)'),
                        ),
                      ],
                    ),
                  ),
                ],
                if (step == 4) ...[
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('Name', nameCtrl.text),
                        _kv('Phone', phoneCtrl.text),
                        _kv('Gender', gender),
                        _kv('DOB', dob?.toIso8601String().split('T').first ?? '—'),
                        _kv('Occupation', occupationCtrl.text),
                        _kv('Education', educationCtrl.text),
                        _kv('Category', MemberCategory.label(category)),
                        _kv('State', state?.name ?? '—'),
                        _kv('LGA', lga?.name ?? '—'),
                        _kv('Ward', ward?.name ?? '—'),
                        _kv('Community', communities.where((c) => c.id == communityId).map((c) => c.name).firstOrNull ?? '—'),
                        _kv('Photo', photoTaken ? 'Captured' : 'Missing'),
                        _kv('ID', idUploaded ? 'Uploaded' : 'Not provided'),
                        const SizedBox(height: 12),
                        ApprovalTimeline(currentStatus: 'pending', compact: true),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => step--),
                      child: const Text('Back'),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: GradientCtaButton(
                    label: step == 4 ? 'Submit' : 'Next',
                    busy: busy,
                    onPressed: () async {
                      if (step < 4) {
                        if (step == 0 && nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter full name')),
                          );
                          return;
                        }
                        setState(() => step++);
                        return;
                      }
                      setState(() => busy = true);
                      final community = communities.where((c) => c.id == communityId).firstOrNull;
                      final member = Member(
                        id: const Uuid().v4(),
                        fullName: nameCtrl.text.trim(),
                        gender: gender,
                        dateOfBirth: dob,
                        phone: phoneCtrl.text.trim(),
                        occupation: occupationCtrl.text.trim(),
                        education: educationCtrl.text.trim(),
                        category: category,
                        status: MemberStatus.pending,
                        stateId: stateId,
                        lgaId: lgaId,
                        wardId: wardId,
                        communityId: communityId,
                        photoUrl: photoTaken ? 'stub://photo' : null,
                        idDocumentUrl: idUploaded ? 'stub://id' : null,
                        createdAt: DateTime.now(),
                        stateName: state?.name,
                        lgaName: lga?.name,
                        wardName: ward?.name,
                        communityName: community?.name,
                      );
                      final saved = await ref.read(repositoryProvider).submitMember(member);
                      if (mounted) {
                        setState(() => busy = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Submitted ${saved.fullName} — pending approval')),
                        );
                        context.pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _catIcon(String c) => switch (c) {
        MemberCategory.youth => Icons.sports_soccer_outlined,
        MemberCategory.women => Icons.woman_outlined,
        MemberCategory.student => Icons.school_outlined,
        MemberCategory.professional => Icons.work_outline,
        MemberCategory.business => Icons.storefront_outlined,
        MemberCategory.volunteer => Icons.volunteer_activism_outlined,
        MemberCategory.communityLeader => Icons.diversity_3_outlined,
        _ => Icons.category_outlined,
      };

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text(k, style: const TextStyle(color: ApcColors.muted, fontWeight: FontWeight.w600))),
            Expanded(child: Text(v.isEmpty ? '—' : v, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );
}
