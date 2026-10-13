import 'package:flutter/material.dart';

enum CalculatorButtonKind {
  number,
  utility,
  operator,
  equals,
}

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = CalculatorButtonKind.number,
  });

  final String label;
  final VoidCallback onPressed;
  final CalculatorButtonKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (backgroundColor, foregroundColor) = switch (kind) {
      CalculatorButtonKind.number =>
        (colors.surfaceContainerHighest, colors.onSurface),
      CalculatorButtonKind.utility =>
        (colors.surfaceContainerHigh, colors.onSurface),
      CalculatorButtonKind.operator =>
        (colors.secondaryContainer, colors.onSecondaryContainer),
      CalculatorButtonKind.equals => (colors.primary, colors.onPrimary),
    };

    return Semantics(
      button: true,
      label: 'Botão $label',
      child: SizedBox.expand(
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: kind == CalculatorButtonKind.number ? 25 : 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
