import 'package:flutter/material.dart';

/// A compact "- value +" numeric stepper.
class StepperRow extends StatelessWidget {
  const StepperRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.unit,
    this.big = false,
    this.min = 0,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String? unit;
  final bool big;

  /// Lowest selectable value (steppers like the hijri adjustment go negative).
  final int min;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle =
        big ? theme.textTheme.displaySmall : theme.textTheme.titleLarge;

    return Row(
      mainAxisSize: big ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          big ? MainAxisAlignment.center : MainAxisAlignment.end,
      children: [
        IconButton.filledTonal(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            unit == null ? '$value' : '$value ${unit!}',
            style: valueStyle,
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
