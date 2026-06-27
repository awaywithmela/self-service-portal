import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class AuthButton extends StatefulWidget {
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (hovering) => setState(() => _isHovering = hovering),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: BoxDecoration(
            color: _isHovering ? AppTheme.tealSurface : Colors.white,
            border: Border.all(
              color: _isHovering ? AppTheme.primaryTeal : AppTheme.tealMuted,
              width: _isHovering ? 2.5 : 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovering
                ? [BoxShadow(color: AppTheme.primaryTeal.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 6))]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isHovering
                      ? AppTheme.primaryTeal.withValues(alpha: 0.18)
                      : AppTheme.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, size: 42, color: AppTheme.primaryTeal),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 22,
                  color: _isHovering ? AppTheme.primaryTeal : AppTheme.tealLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
