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
          SizedBox(height: spacing.xLarge),
          buildActionRow(context),
          const Spacer(),
        ],
      );
    }

    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildAvatar(context),
              buildIdentityBlock(
                context,
                textAlign: TextAlign.start,
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
              SizedBox(height: spacing.large),
              buildDisplayOnlyControls(context),
            ],
          ),
        ),
        const Spacer(),
        buildActionRow(context),
      ],
    );
  }
}
