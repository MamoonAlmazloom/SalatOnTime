import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../home/views/home_screen.dart';
import '../view_models/onboarding_view_model.dart';
import 'mosque_map_step.dart';
import 'offsets_step.dart';
import 'travel_step.dart';
import 'welcome_step.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageController = PageController();
  int _step = 0;
  static const _stepCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context)!;
    await widget.viewModel.finish(l10n.mosqueNameDefault);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.welcomeTitle,
      l10n.mosqueStepTitle,
      l10n.travelStepTitle,
      l10n.offsetsStepTitle,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_step]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / _stepCount),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            WelcomeStep(viewModel: widget.viewModel),
            MosqueMapStep(viewModel: widget.viewModel),
            TravelStep(viewModel: widget.viewModel),
            OffsetsStep(viewModel: widget.viewModel),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_step > 0)
                TextButton(
                  onPressed: () => _goTo(_step - 1),
                  child: Text(l10n.stepBack),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _step < _stepCount - 1
                    ? () => _goTo(_step + 1)
                    : _finish,
                child: Text(
                  _step < _stepCount - 1 ? l10n.stepNext : l10n.stepFinish,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
