import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import 'call_template_widget.dart';

class AndroidNativeCallTemplate extends CallTemplateWidget {
  const AndroidNativeCallTemplate({
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

    if (isRinging) {
      return Column(
        children: [
          const Spacer(),
          buildAvatar(context),
          buildIdentityBlock(context, textAlign: TextAlign.center),
          SizedBox(height: spacing.large),
          buildDisplayOnlyControls(context),
          const Spacer(),
          SizedBox(height: spacing.large),
          buildActionRow(context),
          SizedBox(height: spacing.large),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildIdentityBlock(
          context,
          textAlign: TextAlign.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        SizedBox(height: spacing.xLarge),
        buildDisplayOnlyControls(context),
        const Spacer(),
        Center(child: buildActionRow(context)),
      ],
    );
  }
}
