import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum ThemedButtonSize { regular, homeTrigger, callAction }

class ThemedButton extends StatelessWidget {
  const ThemedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.size = ThemedButtonSize.regular,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final ThemedButtonSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    final sizes = theme.appSizes;
    final accessibility = theme.accessibility;

    final targetSize = switch (size) {
      ThemedButtonSize.regular => accessibility.minTouchTarget,
      ThemedButtonSize.homeTrigger => sizes.homeTriggerSize,
      ThemedButtonSize.callAction => sizes.callActionSize,
    };

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        minimumSize: Size.square(targetSize),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizes.cornerRadius),
          side: BorderSide(color: colors.borderSubtle),
        ),
      ),
      child: child,
    );

    if (semanticLabel == null) {
      return button;
    }

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: button,
    );
  }
}

class ThemedCard extends StatelessWidget {
  const ThemedCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;

    return Card(
      color: theme.appColors.surfaceSecondary,
      child: Padding(padding: EdgeInsets.all(spacing.medium), child: child),
    );
  }
}
