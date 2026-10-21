import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/widgets/athar_icon.dart';
import '../../domain/entities/habit.dart';
import '../cubit/habit_details_cubit.dart';
import '../cubit/habit_details_state.dart';
import '../widgets/habit_appearance.dart';
import '../widgets/habit_details/details_header.dart';
import '../widgets/habit_details/habit_details_metrics.dart';
import '../widgets/habit_details/habit_heatmap_card.dart';
import '../widgets/habit_details/month_calendar_card.dart';
import '../widgets/habit_details/stat_tiles.dart';
import '../widgets/habit_details/streak_hero.dart';
import '../widgets/habit_details/this_month_card.dart';

/// Habit Details as a route (design/screens.md · 06). Needs a
/// [HabitDetailsCubit] above it that is loading the habit.
class HabitDetailsScreen extends StatelessWidget {
  const HabitDetailsScreen({super.key});

  /// Back to Home (which reloads its habits), or straight to Home after a
  /// deep link.
  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _edit(BuildContext context, Habit habit) async {
    final cubit = context.read<HabitDetailsCubit>();
    await context.push(AppRoutes.editHabit(habit.id));
    // Saved or deleted there: show the update, or leave if it's gone.
    if (!cubit.isClosed) await cubit.reload();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    return BlocConsumer<HabitDetailsCubit, HabitDetailsState>(
      listenWhen: (previous, next) => next is HabitDetailsNotFound,
      listener: (context, state) => _leave(context),
      builder: (context, state) => Scaffold(
        backgroundColor: colors.background,
        body: HabitDetailsBody(
          state: state,
          onBack: () => _leave(context),
          onEdit: (habit) => _edit(context, habit),
        ),
      ),
    );
  }
}

/// Wide layout: Details in Home's end panel for the selected habit. Reloads
/// whenever Home hands it a changed [habit] (checked in, edited).
class HabitDetailsPanel extends StatefulWidget {
  const HabitDetailsPanel({
    super.key,
    required this.habit,
    required this.createCubit,
    required this.onEdit,
  });

  final Habit habit;
  final HabitDetailsCubit Function() createCubit;
  final VoidCallback onEdit;

  @override
  State<HabitDetailsPanel> createState() => _HabitDetailsPanelState();
}

class _HabitDetailsPanelState extends State<HabitDetailsPanel> {
  late final HabitDetailsCubit _cubit = widget.createCubit()
    ..load(widget.habit.id);

  @override
  void didUpdateWidget(HabitDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habit != oldWidget.habit) _cubit.load(widget.habit.id);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: BlocBuilder<HabitDetailsCubit, HabitDetailsState>(
      builder: (context, state) => HabitDetailsBody(
        state: state,
        onEdit: (_) => widget.onEdit(),
        layout: AtharLayout.wide,
      ),
    ),
  );
}

/// The Details content for [state], laid out for the window width (or
/// [layout] when given). Month navigation goes to the [HabitDetailsCubit]
/// above.
class HabitDetailsBody extends StatelessWidget {
  const HabitDetailsBody({
    super.key,
    required this.state,
    required this.onEdit,
    this.onBack,
    this.layout,
  });

  final HabitDetailsState state;
  final ValueChanged<Habit> onEdit;

  /// Null in the wide panel, which has no back button.
  final VoidCallback? onBack;
  final AtharLayout? layout;

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    return switch (state) {
      HabitDetailsLoading() || HabitDetailsNotFound() => const Center(
        child: CircularProgressIndicator(),
      ),
      HabitDetailsError() => _ErrorView(
        onRetry: context.read<HabitDetailsCubit>().reload,
      ),
      HabitDetailsLoaded() => _Loaded(
        state: state,
        layout: layout ?? AtharBreakpoints.of(MediaQuery.sizeOf(context).width),
        onBack: onBack,
        onEdit: () => onEdit(state.habit),
      ),
    };
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.state,
    required this.layout,
    required this.onBack,
    required this.onEdit,
  });

  final HabitDetailsLoaded state;
  final AtharLayout layout;
  final VoidCallback? onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HabitDetailsCubit>();
    final accent = state.habit.accentIn(context);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    final hero = StreakHero(stats: state.stats, accent: accent, layout: layout);
    final stats = StatTiles(stats: state.stats);
    final heatmap = HabitHeatmapCard(
      habit: state.habit,
      today: state.today,
      accent: accent,
      layout: layout,
    );
    final calendar = MonthCalendarCard(
      habit: state.habit,
      today: state.today,
      month: state.month,
      accent: accent,
      layout: layout,
      onPrevious: state.canShowPreviousMonth ? cubit.showPreviousMonth : null,
      onNext: state.canShowNextMonth ? cubit.showNextMonth : null,
    );
    final header = DetailsHeader(habit: state.habit, today: state.today);
    const gap = SizedBox(height: HabitDetailsMetrics.sectionGap);
    const columnGap = SizedBox(width: HabitDetailsMetrics.columnGap);

    if (layout == AtharLayout.phone) {
      const gutter = AtharSizes.gutterPhone;
      Widget padded(Widget child) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: gutter),
        child: child,
      );
      return ListView(
        padding: EdgeInsetsDirectional.only(
          top: top + HabitDetailsMetrics.topPadding,
          bottom: bottom + AtharSpacing.xxl,
        ),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: gutter - HabitDetailsMetrics.topBarInset,
            ),
            child: DetailsTopBar(
              onBack: onBack ?? () => Navigator.of(context).maybePop(),
              onEdit: onEdit,
            ),
          ),
          gap,
          padded(header),
          gap,
          padded(hero),
          gap,
          padded(stats),
          gap,
          padded(heatmap),
          gap,
          padded(calendar),
        ],
      );
    }

    final headerRow = Row(
      children: [
        if (onBack case final back?) ...[
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: back,
            icon: AtharIcon.ui(
              'back',
              size: HabitDetailsMetrics.topBarIcon,
              color: AtharColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(width: AtharSpacing.xs),
        ],
        Expanded(child: header),
        const SizedBox(width: AtharSpacing.md),
        DetailsEditButton(onPressed: onEdit),
      ],
    );
    final heroAndStats = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [hero, gap, stats],
    );

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        AtharSizes.gutterTablet,
        top + AtharSpacing.xxl,
        AtharSizes.gutterTablet,
        bottom + AtharSpacing.xxl,
      ),
      children: [
        headerRow,
        const SizedBox(height: AtharSpacing.xl),
        if (layout == AtharLayout.tablet) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: heroAndStats),
                columnGap,
                Expanded(
                  child: ThisMonthCard(
                    progress: state.stats.thisMonth,
                    accent: accent,
                  ),
                ),
              ],
            ),
          ),
          gap,
          heatmap,
          gap,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: HabitDetailsMetrics.calendarMaxWidthTablet,
              ),
              child: calendar,
            ),
          ),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: heroAndStats),
              columnGap,
              Expanded(child: calendar),
            ],
          ),
          gap,
          heatmap,
        ],
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AtharSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AtharIcon.ui('warn', size: AtharSpacing.xxl, color: colors.error),
            const SizedBox(height: AtharSpacing.md),
            Text(
              'details.error'.tr(),
              textAlign: TextAlign.center,
              style: text.progressTitle.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AtharSpacing.lg),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AtharSizes.buttonHeight),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AtharSpacing.xxl,
                ),
              ),
              child: Text('details.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
