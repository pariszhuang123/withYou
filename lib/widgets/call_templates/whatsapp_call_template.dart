import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import 'call_template_widget.dart';

class WhatsappCallTemplate extends CallTemplateWidget {
  const WhatsappCallTemplate({
    required super.spec,
    required super.visualState,
    required super.callerName,
    required super.callDuration,
    required super.onAccept,
    required super.onDecline,
    required super.onEnd,
    super.showAvatar,
    super.key,
  });

  @override
  Widget buildBody(BuildContext context) {
    final spacing = Theme.of(context).appSpacing;

    return Column(
      children: [
        const Spacer(),
        buildAvatar(context),
        buildIdentityBlock(context, textAlign: TextAlign.center),
        SizedBox(height: spacing.medium),
        buildDisplayOnlyControls(context),
        const Spacer(),
        SizedBox(height: spacing.large),
        buildActionRow(context),
        SizedBox(height: spacing.large),
      ],
    );
  }
}
