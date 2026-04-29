import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  String _currency = 'USD';
  String _locale = 'en_US';
  bool _enableLock = false;
  bool _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      _SlideData(
        title: 'Track debt without the data-entry drag',
        body:
            'Import screenshots, receipts, and statements, then verify smart suggestions in seconds.',
      ),
      _SlideData(
        title: 'Stay private by default',
        body:
            'On-device OCR is always local. Cloud AI parsing only happens when you explicitly allow it.',
      ),
      _SlideData(
        title: 'Choose a payoff path that fits real life',
        body:
            'Compare avalanche, snowball, and custom strategies with realistic monthly tradeoffs.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length + 2,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    if (index < slides.length) {
                      final slide = slides[index];
                      return _IntroSlide(slide: slide);
                    }
                    if (index == slides.length) {
                      return _ModeSetup(
                        currency: _currency,
                        locale: _locale,
                        onCurrencyChanged: (value) =>
                            setState(() => _currency = value),
                        onLocaleChanged: (value) =>
                            setState(() => _locale = value),
                      );
                    }
                    return _SecuritySetup(
                      enableLock: _enableLock,
                      onChanged: (value) => setState(() => _enableLock = value),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length + 2,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _page == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                      ),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _saving
                        ? null
                        : _page == slides.length + 1
                        ? _finish
                        : _next,
                    child: Text(
                      _saving
                          ? 'Saving...'
                          : _page == slides.length + 1
                          ? 'Enter app'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final repository = ref.read(preferencesRepositoryProvider);
    final current = await repository.loadPreferences();
    if (_enableLock) {
      final authResult = await ref
          .read(appSecurityCoordinatorProvider.notifier)
          .unlock();
      if (!authResult.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authResult.message ??
                    'Authentication is required before app lock can be enabled.',
              ),
            ),
          );
          setState(() => _saving = false);
        }
        return;
      }
    }
    await repository.savePreferences(
      current.copyWith(
        onboardingCompleted: true,
        currencyCode: _currency,
        localeCode: _locale,
        appLockEnabled: _enableLock,
      ),
    );
    if (mounted) {
      setState(() => _saving = false);
      context.go('/dashboard');
    }
  }
}

class _SlideData {
  const _SlideData({required this.title, required this.body});

  final String title;
  final String body;
}

class _IntroSlide extends StatelessWidget {
  const _IntroSlide({required this.slide});

  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('DEBT DESTROYER', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 20),
        Text(slide.title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 14),
        Text(slide.body, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _ModeSetup extends StatelessWidget {
  const _ModeSetup({
    required this.currency,
    required this.locale,
    required this.onCurrencyChanged,
    required this.onLocaleChanged,
  });

  final String currency;
  final String locale;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Local-first setup',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        const Text(
          'Use local-only mode now. Account mode is intentionally a teaser for future secure sync.',
        ),
        const SizedBox(height: 20),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'local', label: Text('Local only')),
            ButtonSegment(value: 'account', label: Text('Account mode teaser')),
          ],
          selected: const {'local'},
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: currency,
          decoration: const InputDecoration(labelText: 'Currency'),
          items: const [
            DropdownMenuItem(value: 'USD', child: Text('USD')),
            DropdownMenuItem(value: 'EUR', child: Text('EUR')),
            DropdownMenuItem(value: 'GBP', child: Text('GBP')),
            DropdownMenuItem(value: 'BDT', child: Text('BDT')),
          ],
          onChanged: (value) => onCurrencyChanged(value ?? currency),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: locale,
          decoration: const InputDecoration(labelText: 'Region'),
          items: const [
            DropdownMenuItem(value: 'en_US', child: Text('United States')),
            DropdownMenuItem(value: 'en_GB', child: Text('United Kingdom')),
            DropdownMenuItem(value: 'en_BD', child: Text('Bangladesh')),
          ],
          onChanged: (value) => onLocaleChanged(value ?? locale),
        ),
      ],
    );
  }
}

class _SecuritySetup extends StatelessWidget {
  const _SecuritySetup({required this.enableLock, required this.onChanged});

  final bool enableLock;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Security choices',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        const Text(
          'Biometric lock is optional and can be changed later in Settings. Balances stay visible by default.',
        ),
        const SizedBox(height: 20),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: enableLock,
          onChanged: onChanged,
          title: const Text('Enable biometric or device-auth lock'),
          subtitle: const Text(
            'You can still use the app offline with local storage only.',
          ),
        ),
        const SizedBox(height: 12),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.sync_lock_outlined),
          title: Text('Account mode is coming later'),
          subtitle: Text(
            'No bank sync or backend account is required for this MVP.',
          ),
        ),
      ],
    );
  }
}
