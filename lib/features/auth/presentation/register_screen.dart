import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          SoftCard(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email (optional)', prefixIcon: Icon(Icons.email_outlined)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GradientCtaButton(
            label: 'Register & continue',
            busy: busy,
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and phone are required')),
                );
                return;
              }
              setState(() => busy = true);
              final user = await ref.read(repositoryProvider).registerMemberAccount(
                    fullName: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                  );
              await ref.read(sessionProvider.notifier).login(user);
              if (mounted) setState(() => busy = false);
            },
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () => context.go('/login'), child: const Text('Already have an account? Login')),
        ],
      ),
    );
  }
}
