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
    this.showAvatar = true,
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
  final bool showAvatar;
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
    if (!showAvatar) {
      return const SizedBox.shrink();
    }

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
        _CallStatusSubtitle(
          label: isRinging
              ? spec.localizedVoiceCallLabel
              : _formatDuration(callDuration),
          isRinging: isRinging,
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
    final motion = theme.appMotion;

    if (isRinging) {
      return AnimatedScale(
        scale: 1.05,
        duration: context.accessibleMotionDuration(motion.avatarPulse),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CallActionButton(
              label: 'Hang',
              semanticLabel: 'Decline support call',
              icon: Icons.call_end,
              backgroundColor: spec.palette.declineAction,
              foregroundColor: theme.callTheme.onDeclineAction,
              onPressed: onDecline,
              focusOrder: 1,
              showLabel: false,
            ),
            SizedBox(width: spacing.medium),
            CallActionButton(
              label: 'Dial',
              semanticLabel: 'Accept support call',
              icon: Icons.call,
              backgroundColor: spec.palette.acceptAction,
              foregroundColor: theme.callTheme.onAcceptAction,
              onPressed: onAccept,
              focusOrder: 2,
              showLabel: false,
            ),
          ],
        ),
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

class _CallStatusSubtitle extends StatelessWidget {
  const _CallStatusSubtitle({
    required this.label,
    required this.isRinging,
    required this.textAlign,
    required this.style,
  });

  final String label;
  final bool isRinging;
  final TextAlign textAlign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (!isRinging) {
      return Text(label, textAlign: textAlign, style: style);
    }

    return _RingingSubtitleText(
      label: label,
      textAlign: textAlign,
      style: style,
    );
  }
}

class _RingingSubtitleText extends StatefulWidget {
  const _RingingSubtitleText({
    required this.label,
    required this.textAlign,
    required this.style,
  });

  final String label;
  final TextAlign textAlign;
  final TextStyle? style;

  @override
  State<_RingingSubtitleText> createState() => _RingingSubtitleTextState();
}

class _RingingSubtitleTextState extends State<_RingingSubtitleText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(
        '${widget.label}...',
        textAlign: widget.textAlign,
        style: widget.style,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final step = (_controller.value * 3).floor() % 3;
        final dots = '.' * (step + 1);
        return Text(
          '${widget.label}$dots',
          textAlign: widget.textAlign,
          style: widget.style,
        );
      },
    );
  }
}
