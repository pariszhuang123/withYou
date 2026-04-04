import 'package:flutter/material.dart';

import '../contracts/call_flow_contracts.dart';
import '../contracts/commerce_contracts.dart';
import '../l10n/app_localizations.dart';
import '../theme/design_tokens.dart';
import '../widgets/themed_components.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({
    required this.premiumAccessContract,
    required this.focusedScenario,
    super.key,
  });

  final PremiumAccessContract premiumAccessContract;
  final Scenario? focusedScenario;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final localizations = AppLocalizations.of(context)!;
    final benefits = _orderedBenefits(widget.focusedScenario);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.paywallTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.large),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ThemedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localizations.paywallHeadline,
                          style: theme.textTheme.headlineMedium,
                        ),
                        SizedBox(height: spacing.small),
                        Text(
                          localizations.paywallBody,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.large),
                  for (final benefit in benefits) ...[
                    ThemedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            benefit.title,
                            style: theme.textTheme.titleLarge,
                          ),
                          SizedBox(height: spacing.xSmall),
                          Text(benefit.body, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.medium),
                  ],
                  ThemedButton(
                    onPressed: _busy ? null : _purchase,
                    semanticLabel: localizations.upgradeToPremium,
                    child: Text(localizations.upgradeToPremium),
                  ),
                  SizedBox(height: spacing.small),
                  ThemedButton(
                    onPressed: _busy ? null : _restore,
                    semanticLabel: localizations.paywallRestore,
                    variant: ThemedButtonVariant.secondary,
                    child: Text(localizations.paywallRestore),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _purchase() async {
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
    });
    await widget.premiumAccessContract.recordPurchase();
    if (!mounted) {
      return;
    }
    navigator.pop(true);
  }

  Future<void> _restore() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
    });
    await widget.premiumAccessContract.restorePurchases();
    final accessState = await widget.premiumAccessContract.getAccessState();
    if (!mounted) {
      return;
    }

    if (accessState == PremiumAccessState.active) {
      navigator.pop(true);
      return;
    }

    setState(() {
      _busy = false;
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.paywallRestoreFailed),
      ),
    );
  }

  List<_PaywallBenefit> _orderedBenefits(Scenario? focusedScenario) {
    final benefits = <_PaywallBenefit>[
      _benefitForScenario(Scenario.socialPull),
      _benefitForScenario(Scenario.exitPressure),
      _PaywallBenefit(
        key: 'widget',
        title: AppLocalizations.of(context)!.paywallBenefitWidgetTitle,
        body: AppLocalizations.of(context)!.paywallBenefitWidgetBody,
      ),
    ];

    if (focusedScenario == null) {
      return benefits;
    }

    final focusKey = focusedScenario.name;
    benefits.sort((left, right) {
      if (left.key == focusKey) {
        return -1;
      }
      if (right.key == focusKey) {
        return 1;
      }
      return 0;
    });
    return benefits;
  }

  _PaywallBenefit _benefitForScenario(Scenario scenario) {
    final localizations = AppLocalizations.of(context)!;
    return switch (scenario) {
      Scenario.presence => _PaywallBenefit(
        key: 'presence',
        title: localizations.scenarioPresence,
        body: localizations.paywallBenefitPresenceBody,
      ),
      Scenario.socialPull => _PaywallBenefit(
        key: 'socialPull',
        title: localizations.paywallBenefitSocialPullTitle,
        body: localizations.paywallBenefitSocialPullBody,
      ),
      Scenario.exitPressure => _PaywallBenefit(
        key: 'exitPressure',
        title: localizations.paywallBenefitExitPressureTitle,
        body: localizations.paywallBenefitExitPressureBody,
      ),
    };
  }
}

class _PaywallBenefit {
  const _PaywallBenefit({
    required this.key,
    required this.title,
    required this.body,
  });

  final String key;
  final String title;
  final String body;
}
