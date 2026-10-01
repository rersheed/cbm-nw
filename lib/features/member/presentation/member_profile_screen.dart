import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class MemberProfileScreen extends ConsumerStatefulWidget {
  const MemberProfileScreen({super.key});
  @override
  ConsumerState<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends ConsumerState<MemberProfileScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final occupationCtrl = TextEditingController();
  bool busy = false;
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(dataTickProvider);
    final member = ref.watch(repositoryProvider).memberForCurrentUser();
    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Complete registration first')),
      );
    }
    if (!loaded) {
      nameCtrl.text = member.fullName;
      phoneCtrl.text = member.phone ?? '';
      emailCtrl.text = member.email ?? '';
      occupationCtrl.text = member.occupation ?? '';
      loaded = true;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Update profile')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          SoftCard(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 10),
                TextField(controller: occupationCtrl, decoration: const InputDecoration(labelText: 'Occupation')),
                const SizedBox(height: 8),
                const Text(
                  'Location, VIN, and voter details cannot be changed here. Contact an admin if needed.',
                  style: TextStyle(fontSize: 12, color: ApcColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GradientCtaButton(
            label: 'Save changes',
            busy: busy,
            icon: Icons.save_outlined,
            onPressed: () async {
              setState(() => busy = true);
              await ref.read(repositoryProvider).updateMemberProfile(
                    member.id,
                    fullName: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                    occupation: occupationCtrl.text.trim(),
                  );
              if (mounted) {
                setState(() => busy = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
              }
            },
          ),
        ],
      ),
    );
  }
}
