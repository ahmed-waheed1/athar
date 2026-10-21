import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/debug/debug_tools_sheet.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_numbers.dart';
import '../../../../core/widgets/athar_confirm_dialog.dart';
import '../../../../core/widgets/athar_icon.dart';
import '../../../../core/widgets/dashed_border.dart';
import '../cubit/habit_details_cubit.dart';
import '../cubit/habits_cubit.dart';
import '../cubit/habits_state.dart';
import '../widgets/all_habits_heatmap_card.dart';
import '../widgets/check_in_toast.dart';
import '../widgets/habit_card.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/home_header.dart';
import '../widgets/home_metrics.dart';
import '../widgets/milestone/milestone_dialog.dart';
import '../widgets/overview_panel.dart';
import '../widgets/progress_card.dart';
import 'habit_details_screen.dart';

/// Home / Today (design/screens.md · 03).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.createDetailsCubit});

  /// Wide layout: the cubit behind the selected habit's details panel.
  final HabitDetailsCubit Function() createDetailsCubit;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppLifecycleListener _lifecycle;

  /// Habits whose swipe actions are showing (for the "Swipe for options" hint).
  final _openSwipes = <String>{};

  /// Wide layout: the habit shown in the end panel.
  String? _selectedId;

  HabitsCubit get _cubit => context.read<HabitsCubit>();

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => _cubit.refreshIfDayChanged(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _toggle(HabitItem item) async {
    final messenger = ScaffoldMessenger.of(context);
    final cubit = _cubit;
    final result = await cubit.toggleToday(item.habit.id);
    if (result == null || !mounted) return;
    if (!result.isDone) {
      messenger.hideCurrentSnackBar();
      return;
    }
    if (result.milestone case final milestone?) {
      messenger.hideCurrentSnackBar();
      await showMilestoneCelebration(
        context,
        habit: result.habit,
        milestone: milestone,
      );
      return;
    }
    showCheckInToast(
      context,
      streak: result.currentStreak,
      onUndo: () => cubit.toggleToday(result.habit.id),
    );
  }

  Future<void> _push(String location) async {
    await context.push(location);
    // The habits may have changed on the pushed screen.
    if (mounted) await _cubit.load();
  }

  void _add([HabitSuggestion? suggestion]) => _push(
    suggestion == null
        ? AppRoutes.addHabit
        : AppRoutes.addHabitWith(
            name: suggestion.labelKey.tr(),
            iconKey: suggestion.iconKey,
            colorKey: suggestion.colorKey,
          ),
  );

  Future<bool> _confirmDelete(HabitItem item) {
    final body = item.currentStreak == 0
        ? 'deleteDialog.bodyNoStreak'.tr()
        : 'deleteDialog.body'.plural(
            item.currentStreak,
            format: LocalizedNumbers.formatter(context.locale),
          );
    return showAtharConfirmDialog(
      context,
      iconName: 'trash',
      title: 'deleteDialog.title'.tr(namedArgs: {'name': item.habit.name}),
      body: body,
      cancelLabel: 'deleteDialog.cancel'.tr(),
      confirmLabel: 'deleteDialog.confirm'.tr(),
    );
  }

  void _deleted(HabitItem item) {
    if (_selectedId == item.habit.id) setState(() => _selectedId = null);
    _cubit.delete(item.habit.id);
  }

  void _setSwipeOpen(String id, bool isOpen) {
    final changed = isOpen ? _openSwipes.add(id) : _openSwipes.remove(id);
    if (changed) setState(() {});
  }

  VoidCallback? get _debugTools => kDebugMode
      ? () => showDebugToolsSheet(context, onChanged: () => _cubit.load())
      : null;

  Widget _card(HabitItem item, AtharLayout layout) => HabitCard(
    key: ValueKey(item.habit.id),
    item: item,
    layout: layout,
    isSelected: layout == AtharLayout.wide && _selectedId == item.habit.id,
    onToggle: () => _toggle(item),
    onEdit: () => _push(AppRoutes.editHabit(item.habit.id)),
    confirmDelete: () => _confirmDelete(item),
    onDeleted: () => _deleted(item),
    onSwipeOpenChanged: (open) => _setSwipeOpen(item.habit.id, open),
    onTap: layout == AtharLayout.wide
        ? () => setState(
            () => _selectedId = _selectedId == item.habit.id
                ? null
                : item.habit.id,
          )
        : () => _push(AppRoutes.habitDetails(item.habit.id)),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitsCubit, HabitsState>(
      listener: (context, state) {
        if (state is! HabitsLoaded) return;
        final ids = {for (final h in state.habits) h.habit.id};
        _openSwipes.retainWhere(ids.contains);
        if (_selectedId != null && !ids.contains(_selectedId)) {
          setState(() => _selectedId = null);
        }
      },
      builder: (context, state) => switch (state) {
        HabitsLoading() => const Center(child: CircularProgressIndicator()),
        HabitsError() => _ErrorView(onRetry: _cubit.load),
        HabitsLoaded() => _buildLoaded(state),
      },
    );
  }

  Widget _buildLoaded(HabitsLoaded state) {
    // Same breakpoint as AppShell: the window width, not this pane's.
    final layout = AtharBreakpoints.of(MediaQuery.sizeOf(context).width);
    if (state.habits.isEmpty) return _buildEmpty(layout);
    return SlidableAutoCloseBehavior(
      child: switch (layout) {
        AtharLayout.phone => _buildPhone(state),
        AtharLayout.tablet => _buildTablet(state),
        AtharLayout.wide => _buildWide(state),
      },
    );
  }

  Widget _header(AtharLayout layout, {bool showAdd = true}) => HomeHeader(
    now: DateTime.now(),
    layout: layout,
    onAdd: showAdd ? _add : null,
    onLongPress: _debugTools,
  );

  Widget _buildEmpty(AtharLayout layout) {
    final top = MediaQuery.paddingOf(context).top;
    final isPhone = layout == AtharLayout.phone;
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        AtharSpacing.gutter(layout),
        top + (isPhone ? HomeMetrics.topPadding : HomeMetrics.tabletTopPadding),
        AtharSpacing.gutter(layout),
        AtharSpacing.xxl,
      ),
      children: [
        _header(layout, showAdd: false),
        const SizedBox(height: AtharSpacing.xxxl),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HomeMetrics.emptyMaxWidth,
            ),
            child: HomeEmptyState(onCreate: _add, onSuggestion: _add),
          ),
        ),
      ],
    );
  }

  Widget _buildPhone(HabitsLoaded state) {
    final top = MediaQuery.paddingOf(context).top;
    const layout = AtharLayout.phone;
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        AtharSizes.gutterPhone,
        top + HomeMetrics.topPadding,
        AtharSizes.gutterPhone,
        AtharSpacing.md,
      ),
      children: [
        _header(layout),
        const SizedBox(height: HomeMetrics.sectionGap),
        ProgressCard(progress: state.progress, layout: layout),
        const SizedBox(height: AtharSpacing.xl),
        _SectionHeader(showHint: _openSwipes.isNotEmpty),
        const SizedBox(height: HomeMetrics.sectionGap),
        for (final (index, item) in state.habits.indexed) ...[
          if (index > 0) const SizedBox(height: HomeMetrics.listGap),
          _card(item, layout),
        ],
      ],
    );
  }

  Widget _buildTablet(HabitsLoaded state) {
    final top = MediaQuery.paddingOf(context).top;
    const layout = AtharLayout.tablet;
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        AtharSizes.gutterTablet,
        top + HomeMetrics.tabletTopPadding,
        AtharSizes.gutterTablet,
        AtharSpacing.xxl,
      ),
      children: [
        _header(layout),
        const SizedBox(height: AtharSpacing.xl),
        ProgressCard(progress: state.progress, layout: layout),
        const SizedBox(height: AtharSpacing.xl),
        _SectionHeader(showHint: _openSwipes.isNotEmpty),
        const SizedBox(height: AtharSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth =
                (constraints.maxWidth - HomeMetrics.tabletGridGap) / 2;
            return Wrap(
              spacing: HomeMetrics.tabletGridGap,
              runSpacing: HomeMetrics.tabletGridGap,
              children: [
                for (final item in state.habits)
                  SizedBox(width: itemWidth, child: _card(item, layout)),
                SizedBox(
                  width: itemWidth,
                  child: _AddHabitTile(onPressed: _add),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AtharSpacing.xl),
        AllHabitsHeatmapCard(
          dailyRatios: state.overview.dailyRatios,
          today: state.today,
          layout: layout,
        ),
      ],
    );
  }

  Widget _buildWide(HabitsLoaded state) {
    final colors = AtharColors.of(context);
    final top = MediaQuery.paddingOf(context).top;
    const layout = AtharLayout.wide;
    final selected = state.habits
        .where((h) => h.habit.id == _selectedId)
        .firstOrNull;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: AtharSizes.wideListWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: BorderDirectional(end: BorderSide(color: colors.divider)),
            ),
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                HomeMetrics.wideListPaddingH,
                top + HomeMetrics.wideListPaddingTop,
                HomeMetrics.wideListPaddingH,
                HomeMetrics.wideListPaddingTop,
              ),
              children: [
                _header(layout),
                const SizedBox(height: AtharSpacing.lg),
                ProgressCard(progress: state.progress, layout: layout),
                const SizedBox(height: AtharSpacing.lg),
                for (final (index, item) in state.habits.indexed) ...[
                  if (index > 0) const SizedBox(height: HomeMetrics.listGap),
                  _card(item, layout),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: selected == null
              ? Padding(
                  padding: EdgeInsetsDirectional.only(top: top),
                  child: OverviewPanel(state: state),
                )
              : HabitDetailsPanel(
                  key: ValueKey(selected.habit.id),
                  habit: selected.habit,
                  createCubit: widget.createDetailsCubit,
                  onEdit: () => _push(AppRoutes.editHabit(selected.habit.id)),
                ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.showHint});

  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: HomeMetrics.sectionTitleInset,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                'home.todaysHabits'.tr(),
                style: text.sectionTitle.copyWith(color: colors.textPrimary),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: showHint ? 1 : 0,
            duration: AtharMotion.toastIn,
            child: Text(
              'home.swipeHint'.tr(),
              style: text.caption.copyWith(color: colors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tablet grid: the dashed "Add habit" card in the last cell.
class _AddHabitTile extends StatelessWidget {
  const _AddHabitTile({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return DashedBorder(
      color: colors.divider,
      strokeWidth: HomeMetrics.dashedBorder,
      radius: AtharRadii.card,
      dashLength: HomeMetrics.dashLength,
      gapLength: HomeMetrics.dashGap,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AtharRadii.cardRadius,
          onTap: onPressed,
          child: SizedBox(
            // Same height as a one-line habit card.
            height: AtharSizes.checkButton + 2 * HomeMetrics.cardPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AtharIcon.ui(
                  'plus',
                  size: HomeMetrics.buttonIcon,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: AtharSpacing.xs),
                Text(
                  'home.addHabit'.tr(),
                  style: text.button.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
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
              'home.error.title'.tr(),
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
              child: Text('home.error.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
