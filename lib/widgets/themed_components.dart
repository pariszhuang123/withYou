import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/design_tokens.dart';

enum ThemedButtonSize { regular, homeTrigger, callAction }

enum ThemedIconButtonSize { regular, callAction }

class ThemedHeroActionButton extends StatelessWidget {
  const ThemedHeroActionButton({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback? onPressed;
  final String semanticLabel;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final colors = theme.appColors;
    final sizes = theme.appSizes;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: Size(double.infinity, sizes.homeTriggerSize * 2.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sizes.cardRadius),
              side: BorderSide(color: colors.borderSubtle),
            ),
            padding: EdgeInsets.all(spacing.large),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              SizedBox(height: spacing.small),
              Text(title, style: theme.textTheme.titleLarge),
              SizedBox(height: spacing.xSmall),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final sizes = theme.appSizes;

    return Card(
      color: theme.appColors.surfaceSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizes.cardRadius),
      ),
      child: Padding(padding: EdgeInsets.all(spacing.medium), child: child),
    );
  }
}

class ThemedSurfacePanel extends StatelessWidget {
  const ThemedSurfacePanel({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
  });

  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final sizes = theme.appSizes;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.appColors.surfaceCritical,
        borderRadius: BorderRadius.circular(sizes.cornerRadius),
        border: Border.all(color: theme.appColors.borderSubtle),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(spacing.medium),
        child: child,
      ),
    );
  }
}

class ThemedAvatarPlaceholder extends StatelessWidget {
  const ThemedAvatarPlaceholder({
    super.key,
    required this.size,
    required this.iconColor,
    required this.ringColor,
    required this.surfaceColor,
  });

  final double size;
  final Color iconColor;
  final Color ringColor;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: surfaceColor,
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 3),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.person_outline, size: size * 0.46, color: iconColor),
    );
  }
}

class ThemedDisplayChip extends StatelessWidget {
  const ThemedDisplayChip({
    super.key,
    required this.label,
    required this.textColor,
  });

  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: textColor),
      ),
      backgroundColor: Theme.of(context).callTheme.surface,
      side: BorderSide(color: Theme.of(context).appColors.borderSubtle),
    );
  }
}

class ThemedIconButton extends StatelessWidget {
  const ThemedIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.tooltip,
    this.size = ThemedIconButtonSize.regular,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final String? tooltip;
  final ThemedIconButtonSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetSize = switch (size) {
      ThemedIconButtonSize.regular => theme.accessibility.minTouchTarget,
      ThemedIconButtonSize.callAction => theme.appSizes.callActionSize,
    };

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: IconButton(
        tooltip: tooltip ?? semanticLabel,
        onPressed: onPressed,
        constraints: BoxConstraints.tightFor(
          width: targetSize,
          height: targetSize,
        ),
        icon: Icon(icon),
      ),
    );
  }
}

class CallActionButton extends StatelessWidget {
  const CallActionButton({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    required this.focusOrder,
    this.showLabel = true,
  });

  final String label;
  final String semanticLabel;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final double focusOrder;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final size = Theme.of(context).appSizes.callActionSize;
    final spacing = Theme.of(context).appSpacing;

    return FocusTraversalOrder(
      order: NumericFocusOrder(focusOrder),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: semanticLabel,
            button: true,
            child: SizedBox(
              width: size,
              height: size,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                  minimumSize: Size.square(size),
                ),
                onPressed: onPressed,
                child: Icon(icon),
              ),
            ),
          ),
          if (showLabel) ...[
            SizedBox(height: spacing.small),
            ExcludeSemantics(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).callTheme.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64, this.animated = false});

  final double size;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = theme.appMotion;

    final logo = Semantics(
      label: 'withYou app logo',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset('assets/logos/app_logo.svg'),
      ),
    );

    if (!animated) {
      return logo;
    }

    return AnimatedScale(
      scale: 1.03,
      duration: context.accessibleMotionDuration(motion.avatarPulse),
      child: logo,
    );
  }
}
