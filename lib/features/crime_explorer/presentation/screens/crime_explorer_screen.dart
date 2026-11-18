import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:street_level_crime_explorer/core/widgets/message_panel.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/presentation/cubit/crime_cubit.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/presentation/cubit/crime_state.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/presentation/widgets/result_card.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/presentation/widgets/month_picker_dialog.dart';
import 'package:street_level_crime_explorer/core/theme/app_colors.dart';
import 'package:street_level_crime_explorer/core/theme/app_theme.dart';
import 'package:street_level_crime_explorer/core/theme/app_typography.dart';

class CrimeExplorerScreen extends StatefulWidget {
  const CrimeExplorerScreen({super.key});

  @override
  State<CrimeExplorerScreen> createState() => _CrimeExplorerScreenState();
}

class _CrimeExplorerScreenState extends State<CrimeExplorerScreen> {
  final _postcodeController = TextEditingController();
  static const _monthsAvailable = 36;
  YearMonth? _latestMonth;
  YearMonth? _selectedMonth;
  String? _postcodeError;

  @override
  void initState() {
    super.initState();
    _loadMonths();
  }

  @override
  void dispose() {
    _postcodeController.dispose();
    super.dispose();
  }

  Future<void> _loadMonths() async {
    final latest = await context.read<CrimeCubit>().latestMonth();
    if (!mounted) return;
    setState(() {
      _latestMonth = latest;
      _selectedMonth = latest;
    });
  }

  void _submit() {
    final postcode = _postcodeController.text.trim();
    final month = _selectedMonth;
    if (postcode.isEmpty) {
      setState(() => _postcodeError = 'Enter a UK postcode');
      return;
    }
    if (month == null) return;
    setState(() => _postcodeError = null);
    context.read<CrimeCubit>().search(postcode, month);
  }

  void _clear() {
    _postcodeController.clear();
    setState(() {
      _postcodeError = null;
      _selectedMonth = _latestMonth;
    });
    context.read<CrimeCubit>().reset();
  }

  static const _examples = ['SW1A 1AA', 'CF10 1EP', 'BT1 5GS'];

  void _useExample(String postcode) {
    _postcodeController.text = postcode;
    _submit();
  }

  Widget _buildIntro() {
    return Column(
      children: [
        Text('Try an example', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final example in _examples)
              ActionChip(
                avatar: const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.teal,
                ),
                label: Text(example),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.teal),
                shape: const StadiumBorder(),
                labelStyle: AppTypography.bodyBold.copyWith(color: AppColors.teal),
                onPressed:
                _latestMonth == null ? null : () => _useExample(example),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Covers England, Wales and Northern Ireland. Scotland is not covered.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'See what has been reported near you',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Search a postcode in England, Wales or Northern Ireland to see '
                    'incidents reported to police within 1 mile.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(CrimeState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Find incidents near a postcode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _postcodeController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Postcode',
                hintText: 'e.g. SW1A 1AA',
                prefixIcon: const Icon(Icons.location_on_outlined),
                errorText: _postcodeError,
              ),
            ),
            const SizedBox(height: 16),
            _buildMonthPicker(),
            if (_latestMonth != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      Icons.update,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Data available up to ${_latestMonth!.label}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _latestMonth == null ? null : _submit,
              icon: state is CrimeLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.travel_explore),
              label: const Text('Search'),
            ),
            if (state is! CrimeInitial) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.close),
                label: const Text('Clear'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.tealBright.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.tealBright,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Street Watch',
              style: AppTypography.subheading.copyWith(fontWeight: AppTypography.bold),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<CrimeCubit, CrimeState>(
          builder: (context, state) => Column(
            children: [
              _buildHero(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSearchCard(state),
                        const SizedBox(height: 24),
                        _buildBody(context, state),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthPicker() {
    final latest = _latestMonth;
    final selected = _selectedMonth;
    if (latest == null || selected == null) {
      return const LinearProgressIndicator();
    }
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showMonthPicker(
          context: context,
          selected: selected,
          earliest: latest.lastMonths(_monthsAvailable).last,
          latest: latest,
        );
        if (picked != null && mounted) setState(() => _selectedMonth = picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Choose a month',
          suffixIcon: Icon(Icons.calendar_month),
        ),
        child: Text(selected.label),
      ),
    );
  }

  /// Sealed state: the compiler makes sure every state is handled.
  Widget _buildBody(BuildContext context, CrimeState state) {
    return switch (state) {
      CrimeInitial() => _buildIntro(),
      CrimeLoading() => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      CrimeLoaded(:final summary) => ResultsCard(summary: summary),
      CrimeNoData(:final location, :final month) => MessagePanel(
        icon: Icons.info_outline,
        title: 'No data returned',
          message: 'The police data has no incidents for '
              '${location.postcode} in ${month.label}. This does not mean '
              'nothing happened: the month may not be published yet, or the '
              'area may not be covered.'
              '${location.isScotland ? ' Police data for Scotland is not available '
              'here: this tool covers England, Wales and Northern Ireland.' : ''}',
      ),
      CrimePostcodeNotFound() => const MessagePanel(
        icon: Icons.search_off,
        title: 'Postcode not found',
        message: 'We could not find that postcode. Check it and try again.',
      ),
      CrimeFailed(:final failure) => MessagePanel(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        message: failure.message,
        onRetry: failure.isRetryable
            ? () => context.read<CrimeCubit>().retry()
            : null,
      ),
    };
  }
}