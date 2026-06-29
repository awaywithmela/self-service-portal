import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class SetupInstruction extends StatefulWidget {
  final int number;
  final String title;
  final String description;
  final String details;

  const SetupInstruction({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.details,
  });

  @override
  State<SetupInstruction> createState() => _SetupInstructionState();
}

class _SetupInstructionState extends State<SetupInstruction> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.number}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step-by-Step Instructions:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.tealSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.tealMuted),
                      ),
                      child: SelectableText(
                        widget.details.trim(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: 'monospace',
                              height: 1.8,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
