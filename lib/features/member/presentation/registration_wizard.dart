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
  bool voterCardUploaded = false;
  bool consent = false;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final occupationCtrl = TextEditingController();
  final vinCtrl = TextEditingController();
  String gender = 'male';
  DateTime? dob = DateTime(1998, 5, 12);
  bool isRegisteredVoter = true;

  String? stateId;
  String? lgaId;
  String? wardId;
  String? pollingUnitId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = ref.read(sessionProvider);
      if (u != null) {
        nameCtrl.text = u.fullName;
        phoneCtrl.text = u.phone;
        emailCtrl.text = u.email ?? '';
      }
    });
  }

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
    final pus = ward?.pollingUnits ?? [];
    if (pollingUnitId == null && pus.isNotEmpty) pollingUnitId = pus.first.id;
    final pu = pollingUnitId != null ? repo.findPollingUnit(pollingUnitId!) : null;

    const titles = ['Personal', 'Location', 'Voter', 'Photo', 'Review'];

    return Scaffold(
      appBar: AppBar(title: Text('Register · Step ${step + 1}/5')),
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
                if (step == 0)
                  FormSectionCard(
                    title: 'Personal information',
                    icon: Icons.person_outline,
                    child: Column(
                      children: [
                        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          key: ValueKey('gender-$gender'),
                          initialValue: gender,
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
                        TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
                        const SizedBox(height: 10),
                        TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email (optional)')),
                        const SizedBox(height: 10),
                        TextField(controller: occupationCtrl, decoration: const InputDecoration(labelText: 'Occupation')),
                      ],
                    ),
                  ),
                if (step == 1)
                  FormSectionCard(
                    title: 'Location (NW)',
                    icon: Icons.map_outlined,
                    accent: ApcColors.brown,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey('state-$stateId'),
                          initialValue: stateId,
                          decoration: const InputDecoration(labelText: 'State'),
                          items: [for (final s in states) DropdownMenuItem(value: s.id, child: Text(s.name))],
                          onChanged: (v) => setState(() {
                            stateId = v;
                            lgaId = null;
                            wardId = null;
                            pollingUnitId = null;
                          }),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          key: ValueKey('lga-$lgaId'),
                          initialValue: lgaId,
                          decoration: const InputDecoration(labelText: 'LGA'),
                          items: [for (final l in lgas) DropdownMenuItem(value: l.id, child: Text(l.name))],
                          onChanged: (v) => setState(() {
                            lgaId = v;
                            wardId = null;
                            pollingUnitId = null;
                          }),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          key: ValueKey('ward-$wardId'),
                          initialValue: wardId,
                          decoration: const InputDecoration(labelText: 'Ward'),
                          items: [for (final w in wards) DropdownMenuItem(value: w.id, child: Text(w.name))],
                          onChanged: (v) => setState(() {
                            wardId = v;
                            pollingUnitId = null;
                          }),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          key: ValueKey('pu-$pollingUnitId'),
                          initialValue: pollingUnitId,
                          decoration: const InputDecoration(labelText: 'Polling Unit'),
                          items: [for (final p in pus) DropdownMenuItem(value: p.id, child: Text(p.name))],
                          onChanged: (v) => setState(() => pollingUnitId = v),
                        ),
                      ],
                    ),
                  ),
                if (step == 2)
                  FormSectionCard(
                    title: 'Voter registration',
                    icon: Icons.how_to_vote_outlined,
                    accent: ApcColors.blue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Are you a registered voter?', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                selected: isRegisteredVoter,
                                label: const Text('Yes'),
                                selectedColor: ApcColors.green,
                                labelStyle: TextStyle(
                                  color: isRegisteredVoter ? Colors.white : ApcColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                                onSelected: (_) => setState(() => isRegisteredVoter = true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                selected: !isRegisteredVoter,
                                label: const Text('No'),
                                selectedColor: ApcColors.green,
                                labelStyle: TextStyle(
                                  color: !isRegisteredVoter ? Colors.white : ApcColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                                onSelected: (_) => setState(() {
                                  isRegisteredVoter = false;
                                  vinCtrl.clear();
                                  voterCardUploaded = false;
                                }),
                              ),
                            ),
                          ],
                        ),
                        if (isRegisteredVoter) ...[
                          const SizedBox(height: 14),
                          TextField(controller: vinCtrl, decoration: const InputDecoration(labelText: 'VIN (Voter Identification Number)')),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () => setState(() => voterCardUploaded = !voterCardUploaded),
                            icon: Icon(voterCardUploaded ? Icons.check : Icons.upload_file_outlined),
                            label: Text(voterCardUploaded ? 'Voter card uploaded (stub)' : 'Upload voter card (optional stub)'),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'VIN and voter card are visible to admins only — never on your public membership card or QR.',
                            style: TextStyle(fontSize: 12, color: ApcColors.muted),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (step == 3)
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
                                    Text('Camera / upload stub', style: TextStyle(color: ApcColors.muted)),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 12),
                        GradientCtaButton(
                          label: photoTaken ? 'Retake photo' : 'Capture / upload photo',
                          icon: Icons.photo_camera_outlined,
                          onPressed: () => setState(() => photoTaken = true),
                        ),
                      ],
                    ),
                  ),
                if (step == 4) ...[
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('Name', nameCtrl.text),
                        _kv('Gender', gender),
                        _kv('DOB', dob?.toIso8601String().split('T').first ?? '—'),
                        _kv('Phone', phoneCtrl.text),
                        _kv('Email', emailCtrl.text),
                        _kv('Occupation', occupationCtrl.text),
                        _kv('State', state?.name ?? '—'),
                        _kv('LGA', lga?.name ?? '—'),
                        _kv('Ward', ward?.name ?? '—'),
                        _kv('Polling Unit', pu?.name ?? '—'),
                        _kv('Registered voter', isRegisteredVoter ? 'Yes' : 'No'),
                        if (isRegisteredVoter) ...[
                          _kv('VIN', vinCtrl.text),
                          _kv('Voter card', voterCardUploaded ? 'Uploaded (admin only)' : 'Not provided'),
                        ],
                        _kv('Photo', photoTaken ? 'Captured' : 'Missing'),
                      ],
                    ),
                  ),
                  SoftCard(
                    child: CheckboxListTile(
                      value: consent,
                      onChanged: (v) => setState(() => consent = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(AppConstants.consentNotice, style: TextStyle(fontSize: 13, height: 1.35)),
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
                        if (step == 0 && (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter full name and phone')),
                          );
                          return;
                        }
                        if (step == 2 && isRegisteredVoter && vinCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter VIN or choose No for registered voter')),
                          );
                          return;
                        }
                        setState(() => step++);
                        return;
                      }
                      if (!consent) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please accept the consent notice')),
                        );
                        return;
                      }
                      setState(() => busy = true);
                      final member = Member(
                        id: const Uuid().v4(),
                        fullName: nameCtrl.text.trim(),
                        gender: gender,
                        dateOfBirth: dob,
                        phone: phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                        occupation: occupationCtrl.text.trim(),
                        status: MemberStatus.pending,
                        stateId: stateId,
                        lgaId: lgaId,
                        wardId: wardId,
                        pollingUnitId: pollingUnitId,
                        isRegisteredVoter: isRegisteredVoter,
                        vin: isRegisteredVoter ? vinCtrl.text.trim() : null,
                        voterCardUrl: isRegisteredVoter && voterCardUploaded ? 'stub://voter-card' : null,
                        photoUrl: photoTaken ? 'stub://photo' : null,
                        createdAt: DateTime.now(),
                        stateName: state?.name,
                        lgaName: lga?.name,
                        wardName: ward?.name,
                        pollingUnitName: pu?.name,
                      );
                      await ref.read(repositoryProvider).submitMember(member);
                      if (!mounted) return;
                      setState(() => busy = false);
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Submitted — status Pending')),
                      );
                      context.go('/member');
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

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(width: 120, child: Text(k, style: const TextStyle(color: ApcColors.muted, fontWeight: FontWeight.w600))),
            Expanded(child: Text(v.isEmpty ? '—' : v, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );
}
