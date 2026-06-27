import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme.dart';
import '../widgets/auth_button.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                child: Column(
                  children: [
                    Text(
                      'Please select your status to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.lightText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    AuthButton(
                      label: 'New Interviewer',
                      description: 'First time setup and device configuration',
                      icon: Icons.person_add_rounded,
                      onPressed: () => context.go('/new-interviewer'),
                    ),
                    const SizedBox(height: 20),
                    AuthButton(
                      label: 'Existing Interviewer',
                      description: 'Update apps and manage your device',
                      icon: Icons.manage_accounts_rounded,
                      onPressed: () => context.go('/existing-interviewer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32, MediaQuery.of(context).padding.top + 48, 32, 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.tealDark, AppTheme.primaryTeal],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Self Service Portal',
            style: GoogleFonts.nunito(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ipsos Interviewer Hub',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}
