import 'package:flutter/material.dart';

import '../../contracts/call_flow_contracts.dart';
import '../../theme/design_tokens.dart';
import '../themed_components.dart';

enum CallScreenVisualState { ringing, inCall }

abstract class CallTemplateWidget extends StatelessWidget {
  const CallTemplateWidget({
    required this.spec,
    required this.visualState,
    required this.callerName,
    required this.callDuration,
    required this.onAccept,
    required this.onDecline,
    required this.onEnd,
    this.avatarLabel = 'Caller avatar',
    super.key,
  });

  final CallTemplateSpec spec;
  final CallScreenVisualState visualState;
  final String callerName;
  final Duration callDuration;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onEnd;
  final String avatarLabel;

  bool get isRinging => visualState == CallScreenVisualState.ringing;

  @protected
  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = spec.palette;
    final spacing = theme.appSpacing;
    final background = isRinging
        ? palette.ringingBackground
        : palette.inCallBackground;

    return Material(
      color: background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.large,
              vertical: spacing.medium,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(child: buildBody(context)),
            ),
          ),
        ),
      ),
    );
  }

  @protected
  Widget buildAvatar(BuildContext context, {double size = 120}) {
    final theme = Theme.of(context);
    final palette = spec.palette;
    final spacing = theme.appSpacing;
    final motion = theme.appMotion;

    final avatar = ExcludeSemantics(
      child: ThemedAvatarPlaceholder(
        size: size,
        iconColor: palette.textPrimary,
        ringColor: palette.acceptAction,
        surfaceColor: theme.callTheme.surface,
      ),
    );

    return Semantics(
      label: avatarLabel,
      image: true,
      child: AnimatedScale(
        scale: isRinging && spec.supportsAvatarPulse ? 1.03 : 1,
        duration: context.accessibleMotionDuration(
          isRinging
              ? motion.avatarPulse
              : theme.accessibility.reduceMotionDuration,
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: spacing.medium),
          child: avatar,
        ),
      ),
    );
  }

  @protected
  Widget buildIdentityBlock(
    BuildContext context, {
    required TextAlign textAlign,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final palette = spec.palette;
    final spacing = Theme.of(context).appSpacing;
    final subtitle = isRinging
        ? spec.localizedVoiceCallLabel
        : _formatDuration(callDuration);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          callerName,
          textAlign: textAlign,
          style: textTheme.headlineLarge?.copyWith(color: palette.textPrimary),
        ),
        SizedBox(height: spacing.small),
        Text(
          subtitle,
          textAlign: textAlign,
          style: textTheme.bodyLarge?.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }

  @protected
  Widget buildActionRow(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;

    if (isRinging) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CallActionButton(
            label: 'Decline',
            semanticLabel: 'Decline support call',
            icon: Icons.call_end,
            backgroundColor: spec.palette.declineAction,
            foregroundColor: theme.callTheme.onDeclineAction,
            onPressed: onDecline,
            focusOrder: 1,
          ),
          SizedBox(width: spacing.medium),
          CallActionButton(
            label: 'Accept',
            semanticLabel: 'Accept support call',
            icon: Icons.call,
            backgroundColor: spec.palette.acceptAction,
            foregroundColor: theme.callTheme.onAcceptAction,
            onPressed: onAccept,
            focusOrder: 2,
          ),
        ],
      );
    }

    return Center(
      child: CallActionButton(
        label: 'End',
        semanticLabel: 'End support call',
        icon: Icons.call_end,
        backgroundColor: spec.palette.declineAction,
        foregroundColor: theme.callTheme.onDeclineAction,
        onPressed: onEnd,
        focusOrder: 1,
      ),
    );
  }

  @protected
  Widget buildDisplayOnlyControls(BuildContext context) {
    if (spec.displayOnlyControls.isEmpty) {
      return const SizedBox.shrink();
    }

    final spacing = Theme.of(context).appSpacing;
    final palette = spec.palette;

    return IgnorePointer(
      child: ExcludeSemantics(
        child: Wrap(
          spacing: spacing.small,
          runSpacing: spacing.small,
          alignment: WrapAlignment.center,
          children: spec.displayOnlyControls
              .map(
                (control) => ThemedDisplayChip(
                  label: control,
                  textColor: palette.textSecondary,
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
