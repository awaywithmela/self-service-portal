import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class SetupInstruction extends StatefulWidget {
  final int number;
  final String title;
  final String description;
  final String details;
  final bool isComplete;
  final ValueChanged<bool>? onCompleteChanged;

  const SetupInstruction({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.details,
    this.isComplete = false,
    this.onCompleteChanged,
  });

  @override
  State<SetupInstruction> createState() => _SetupInstructionState();
}

class _SetupInstructionState extends State<SetupInstruction> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.isComplete ? const Color(0xFFF3FBF6) : Colors.white,
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
                      color: widget.isComplete
                          ? const Color(0xFF2E9D5C)
                          : AppTheme.primaryTeal.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: widget.isComplete
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 28)
                          : Text(
                              '${widget.number}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
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
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Checkbox(
                        value: widget.isComplete,
                        onChanged: widget.onCompleteChanged == null
                            ? null
                            : (value) => widget.onCompleteChanged!(value!),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                    ],
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                              height: 1.8,
                            ),
                      ),
                    ),
                    if (widget.onCompleteChanged != null) ...[
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              widget.onCompleteChanged!(!widget.isComplete),
                          icon: Icon(widget.isComplete
                              ? Icons.undo_rounded
                              : Icons.check_rounded),
                          label: Text(widget.isComplete
                              ? 'Mark as not done'
                              : 'Mark step done'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
