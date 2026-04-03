import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/call_flow_cubit.dart';
import '../contracts/call_flow_contracts.dart';
import '../widgets/call_templates/call_template_renderer.dart';
import '../widgets/call_templates/call_template_widget.dart';

class CallFlowScreen extends StatelessWidget {
  const CallFlowScreen({
    required this.appName,
    required this.callTemplateContract,
    super.key,
  });

  final String appName;
  final CallTemplateContract callTemplateContract;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocBuilder<CallFlowCubit, CallFlowState>(
        builder: (context, state) {
          final locale = Localizations.localeOf(context);
          final spec = callTemplateContract.resolve(
            locale,
            Theme.of(context).platform,
          );

          return Scaffold(
            body: CallTemplateRenderer(
              spec: spec,
              visualState: state.flowState == FakeCallState.ringing
                  ? CallScreenVisualState.ringing
                  : CallScreenVisualState.inCall,
              callerName: state.callerName ?? appName,
              callDuration: state.callDuration,
              showAvatar: false,
              onAccept: () => context.read<CallFlowCubit>().accept(),
              onDecline: () => context.read<CallFlowCubit>().decline(),
              onEnd: () => context.read<CallFlowCubit>().end(),
            ),
          );
        },
      ),
    );
  }
}
