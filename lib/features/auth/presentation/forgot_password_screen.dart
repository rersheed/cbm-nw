import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final phone = TextEditingController();
  bool sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'Enter your registered phone number. Demo mode will pretend to send an OTP.',
            style: TextStyle(color: ApcColors.muted),
          ),
          const SizedBox(height: 18),
          SoftCard(
            child: TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ),
          const SizedBox(height: 18),
          GradientCtaButton(
            label: sent ? 'OTP Sent (demo)' : 'Send Reset OTP',
            icon: Icons.sms_outlined,
            onPressed: () {
              setState(() => sent = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demo OTP: 123456')),
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () => context.pop(), child: const Text('Back to login')),
        ],
      ),
    );
  }
}
