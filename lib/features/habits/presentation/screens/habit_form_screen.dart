import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/notifications/notification_permission_cubit.dart';
import '../../../../core/notifications/notification_prompt_sheet.dart';
import '../../../../core/notifications/notifications_blocked_banner.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_numbers.dart';
import '../../../../core/widgets/athar_confirm_dialog.dart';
import '../../../../core/widgets/athar_icon.dart';
import '../cubit/habit_form_cubit.dart';
import '../cubit/habit_form_state.dart';
import '../widgets/habit_form/color_picker.dart';
import '../widgets/habit_form/habit_form_metrics.dart';
import '../widgets/habit_form/habit_name_field.dart';
import '../widgets/habit_form/habit_preview_card.dart';
import '../widgets/habit_form/icon_picker.dart';
import '../widgets/habit_form/reminder_row.dart';
import '../widgets/habit_form/reminder_time_sheet.dart';

/// Add / Edit Habit as a route page. On phone it slides in full screen with
/// the iOS-style swipe back from the start edge; on tablet and wide it fades
/// in as a centred dialog over the page below.
Page<void> habitFormPage({required LocalKey key, required Widget child}) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      opaque: false,
      transitionDuration: AtharMotion.pageTransition,
      reverseTransitionDuration: AtharMotion.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final layout = AtharBreakpoints.of(MediaQuery.sizeOf(context).width);
        if (layout == AtharLayout.phone) {
          // The Cupertino transition plus its back-swipe detector. The swipe
          // is off while PopScope blocks the pop (unsaved changes); then
          // _DiscardSwipeArea takes over.
          return CupertinoRouteTransitionMixin.buildPageTransitions(
            ModalRoute.of(context)! as PageRoute<Object?>,
            context,
            animation,
            secondaryAnimation,
            child,
          );
        }
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AtharMotion.pageTransitionCurve,
          ),
          child: child,
        );
      },
    );

/// Add Habit / Edit Habit (design/screens.md · 05). Needs a started
/// [HabitFormCubit] and a [NotificationPermissionCubit] above it.
class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({super.key});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _name = TextEditingController();
  final _nameFocus = FocusNode();

  /// The field is filled once, when the form is ready (edit mode loads
  /// first).
  bool _nameLoaded = false;

  /// Tablet and wide: the dialog scales in with the route.
  Animation<double>? _dialogScale;

  HabitFormCubit get _cubit => context.read<HabitFormCubit>();

  @override
  void initState() {
    super.initState();
    _loadName(_cubit.state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (_dialogScale == null && animation != null) {
      _dialogScale = Tween(begin: HabitFormMetrics.dialogScaleFrom, end: 1.0)
          .animate(
            CurvedAnimation(
              parent: animation,
              curve: AtharMotion.dialogInCurve,
            ),
          );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _loadName(HabitFormState state) {
    if (_nameLoaded || state.status == HabitFormStatus.loading) return;
    _nameLoaded = true;
    _name.text = state.name;
  }

  /// Back, close, the scrim and the system back gesture all come here.
  Future<void> _close() async {
    if (_cubit.state.hasUnsavedChanges && !await _confirmDiscard()) return;
    if (mounted) _leave();
  }

  /// Back to where the form was opened from (which reloads its habits), or
  /// Home after a deep link. Popping rather than `go` lets the opener's
  /// `push` complete.
  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<bool> _confirmDiscard() => showAtharConfirmDialog(
    context,
    iconName: 'warn',
    title: context.tr('habitForm.discard.title'),
    body: context.tr('habitForm.discard.body'),
    cancelLabel: context.tr('habitForm.discard.cancel'),
    confirmLabel: context.tr('habitForm.discard.confirm'),
  );

  Future<void> _delete() async {
    final state = _cubit.state;
    final body = state.currentStreak == 0
        ? context.tr('deleteDialog.bodyNoStreak')
        : context.plural(
            'deleteDialog.body',
            state.currentStreak,
            format: LocalizedNumbers.formatter(context.locale),
          );
    final confirmed = await showAtharConfirmDialog(
      context,
      iconName: 'trash',
      title: context.tr(
        'deleteDialog.title',
        namedArgs: {'name': state.initial?.name ?? state.values.name},
      ),
      body: body,
      cancelLabel: context.tr('deleteDialog.cancel'),
      confirmLabel: context.tr('deleteDialog.confirm'),
    );
    if (confirmed && mounted) await _cubit.delete();
  }

  Future<void> _save() async {
    _nameFocus.unfocus();
    await _cubit.save();
  }

  Future<void> _showIconSheet() {
    final state = _cubit.state;
    _nameFocus.unfocus();
    return showIconPickerSheet(
      context,
      selected: state.iconKey,
      accent: AtharColors.of(context).accent(state.colorKey),
      onSelected: _cubit.iconSelected,
    );
  }

  /// Turning a reminder on asks for notifications first, the first time.
  Future<void> _toggleReminder(bool enabled) async {
    _nameFocus.unfocus();
    if (enabled && !await allowReminders(context)) return;
    if (mounted) _cubit.reminderToggled(enabled);
  }

  Future<void> _showTimeSheet() async {
    _nameFocus.unfocus();
    final time = await showReminderTimeSheet(
      context,
      initial: _cubit.state.reminderTime,
    );
    if (time == null || !mounted) return;
    // Setting a time turns the reminder on.
    if (!_cubit.state.reminderEnabled && !await allowReminders(context)) {
      return;
    }
    if (mounted) _cubit.reminderTimeSet(time);
  }

  void _showSaveFailed() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.tr('habitForm.saveFailed'))),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HabitFormCubit, HabitFormState>(
          listenWhen: (previous, next) => previous.status != next.status,
          listener: (context, state) {
            _loadName(state);
            switch (state.status) {
              case HabitFormStatus.saved ||
                  HabitFormStatus.deleted ||
                  HabitFormStatus.notFound:
                _leave();
              case HabitFormStatus.loading ||
                  HabitFormStatus.editing ||
                  HabitFormStatus.saving:
                break;
            }
          },
        ),
        BlocListener<HabitFormCubit, HabitFormState>(
          listenWhen: (previous, next) =>
              next.failedSaves > previous.failedSaves,
          listener: (context, state) => _showSaveFailed(),
        ),
      ],
      child: BlocBuilder<HabitFormCubit, HabitFormState>(
        builder: (context, state) {
          final layout = AtharBreakpoints.of(MediaQuery.sizeOf(context).width);
          return PopScope(
            canPop: !state.hasUnsavedChanges,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _close();
            },
            child: layout == AtharLayout.phone
                ? _buildPhone(state)
                : _buildDialog(state),
          );
        },
      ),
    );
  }

  Widget _buildPhone(HabitFormState state) {
    final colors = AtharColors.of(context);
    final padding = MediaQuery.paddingOf(context);
    final page = Scaffold(
      backgroundColor: colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: padding.top + HabitFormMetrics.topPadding),
          _AppBar(
            state: state,
            isDialog: false,
            inset: HabitFormMetrics.appBarInset,
            onClose: _close,
            onDelete: _delete,
          ),
          Expanded(child: _buildBody(state, AtharSizes.gutterPhone)),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AtharSizes.gutterPhone,
              HabitFormMetrics.saveTopGap,
              AtharSizes.gutterPhone,
              HabitFormMetrics.bottomPadding + padding.bottom,
            ),
            child: _SaveButton(state: state, onPressed: _save),
          ),
        ],
      ),
    );
    if (!state.hasUnsavedChanges) return page;
    return Stack(
      children: [
        page,
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width:
              HabitFormMetrics.backSwipeEdge +
              (Directionality.of(context) == TextDirection.rtl
                  ? padding.right
                  : padding.left),
          child: _DiscardSwipeArea(onSwipe: _close),
        ),
      ],
    );
  }

  Widget _buildDialog(HabitFormState state) {
    final colors = AtharColors.of(context);
    final scale = _dialogScale;
    const gutter = HabitFormMetrics.dialogPadding;
    Widget dialog = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AtharSizes.sheetMaxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: AtharRadii.dialogRadius,
          boxShadow: AtharShadows.raised(Theme.of(context).brightness),
        ),
        child: ClipRRect(
          borderRadius: AtharRadii.dialogRadius,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: HabitFormMetrics.dialogPadding / 2),
              _AppBar(
                state: state,
                isDialog: true,
                inset:
                    gutter -
                    (AtharSizes.minTapTarget - HabitFormMetrics.appBarIcon) / 2,
                onClose: _close,
                onDelete: _delete,
              ),
              Flexible(child: _buildBody(state, gutter)),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  gutter,
                  HabitFormMetrics.saveTopGap,
                  gutter,
                  gutter,
                ),
                child: _SaveButton(state: state, onPressed: _save),
              ),
            ],
          ),
        ),
      ),
    );
    if (scale != null) dialog = ScaleTransition(scale: scale, child: dialog);

    return Scaffold(
      backgroundColor: colors.scrim,
      body: Stack(
        children: [
          Positioned.fill(
            child: ModalBarrier(
              onDismiss: _close,
              semanticsLabel: MaterialLocalizations.of(context)
                  .modalBarrierDismissLabel,
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(
                  HabitFormMetrics.dialogMargin,
                ),
                child: dialog,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(HabitFormState state, double gutter) {
    if (state.status == HabitFormStatus.loading ||
        state.status == HabitFormStatus.notFound) {
      return const Padding(
        padding: EdgeInsetsDirectional.all(AtharSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final colors = AtharColors.of(context);
    final accent = colors.accent(state.colorKey);
    EdgeInsetsDirectional sides() =>
        EdgeInsetsDirectional.symmetric(horizontal: gutter);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsetsDirectional.only(
        top: HabitFormMetrics.appBarGap,
        bottom: AtharSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: sides(),
            child: HabitPreviewCard(
              name: state.values.name,
              iconKey: state.iconKey,
              accent: accent,
              currentStreak: state.isEdit ? state.currentStreak : null,
            ),
          ),
          const SizedBox(height: HabitFormMetrics.nameTop),
          Padding(
            padding: sides(),
            child: HabitNameField(
              controller: _name,
              focusNode: _nameFocus,
              length: state.nameLength,
              error: state.nameError,
              shakeTrigger: state.rejectedSaves,
              onChanged: _cubit.nameChanged,
            ),
          ),
          const SizedBox(height: HabitFormMetrics.iconHeaderTop),
          IconPickerRow(
            selected: state.iconKey,
            accent: accent,
            gutter: gutter,
            onSelected: _cubit.iconSelected,
            onMore: _showIconSheet,
          ),
          const SizedBox(height: HabitFormMetrics.sectionTop),
          Padding(
            padding: sides(),
            child: ColorPickerGrid(
              selected: state.colorKey,
              onSelected: _cubit.colorSelected,
            ),
          ),
          const SizedBox(height: HabitFormMetrics.reminderTop),
          Padding(
            padding: sides(),
            child: ReminderRow(
              enabled: state.reminderEnabled,
              time: state.reminderTime,
              onToggled: _toggleReminder,
              onTap: _showTimeSheet,
            ),
          ),
          if (state.reminderEnabled)
            BlocBuilder<NotificationPermissionCubit, NotificationPermission>(
              builder: (context, permission) =>
                  permission == NotificationPermission.denied
                  ? Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        gutter,
                        HabitFormMetrics.blockedBannerTop,
                        gutter,
                        0,
                      ),
                      child: NotificationsBlockedBanner(
                        onOpenSettings: context
                            .read<NotificationPermissionCubit>()
                            .openSystemSettings,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

/// A swipe from the start edge while there are unsaved changes. The route's
/// own back swipe is off then (it would pop without asking), so this one asks
/// to discard first, like the back button.
class _DiscardSwipeArea extends StatefulWidget {
  const _DiscardSwipeArea({required this.onSwipe});

  final VoidCallback onSwipe;

  @override
  State<_DiscardSwipeArea> createState() => _DiscardSwipeAreaState();
}

class _DiscardSwipeAreaState extends State<_DiscardSwipeArea> {
  double _distance = 0;
  bool _fired = false;

  void _onUpdate(DragUpdateDetails details) {
    if (_fired) return;
    // Toward the end edge: right in English, left in Arabic.
    final sign = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    _distance += details.delta.dx * sign;
    if (_distance >= HabitFormMetrics.backSwipeTrigger) {
      _fired = true;
      widget.onSwipe();
    }
  }

  void _reset() {
    _distance = 0;
    _fired = false;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    dragStartBehavior: DragStartBehavior.down,
    onHorizontalDragStart: (_) => _reset(),
    onHorizontalDragUpdate: _onUpdate,
    onHorizontalDragEnd: (_) => _reset(),
    onHorizontalDragCancel: _reset,
  );
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.state,
    required this.isDialog,
    required this.inset,
    required this.onClose,
    required this.onDelete,
  });

  final HabitFormState state;

  /// Tablet and wide show a close button instead of back.
  final bool isDialog;
  final double inset;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final material = MaterialLocalizations.of(context);
    final canDelete = state.isEdit && state.status == HabitFormStatus.editing;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: inset),
      child: SizedBox(
        height: HabitFormMetrics.appBarHeight,
        child: Row(
          children: [
            IconButton(
              tooltip: isDialog
                  ? material.closeButtonTooltip
                  : material.backButtonTooltip,
              onPressed: onClose,
              icon: AtharIcon.ui(
                isDialog ? 'close' : 'back',
                size: HabitFormMetrics.appBarIcon,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: HabitFormMetrics.appBarTitleGap),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  context.tr(
                    state.isEdit ? 'habitForm.editTitle' : 'habitForm.addTitle',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.appBarTitle.copyWith(color: colors.textPrimary),
                ),
              ),
            ),
            if (state.isEdit)
              IconButton(
                tooltip: context.tr('habitForm.delete'),
                onPressed: canDelete ? onDelete : null,
                icon: AtharIcon.ui(
                  'trash',
                  size: HabitFormMetrics.appBarIcon,
                  color: colors.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.state, required this.onPressed});

  final HabitFormState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: state.canSubmit ? onPressed : null,
    child: Text(
      context.tr(state.isEdit ? 'habitForm.saveChanges' : 'habitForm.save'),
    ),
  );
}
