import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/athar_assets.dart';
import '../theme/athar_colors.dart';
import '../theme/athar_spacing.dart';
import 'athar_icon.dart';

/// Top-level navigation: a NavigationBar on phone, a NavigationRail on the
/// start side on tablet and wide.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinations = [
    (icon: 'today', label: 'nav.today'),
    (icon: 'calendar', label: 'nav.history'),
    (icon: 'settings', label: 'nav.settings'),
  ];

  /// Smallest bar height left after the bottom inset is taken out of the 84.
  static const _minNavBarHeight = 64.0;
  static const _railMarkPadding = 10.0;

  void _select(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final layout = AtharBreakpoints.of(MediaQuery.sizeOf(context).width);

    if (layout == AtharLayout.phone) {
      final bottomInset = MediaQuery.paddingOf(context).bottom;
      final barHeight = AtharSizes.navBarHeight - bottomInset;
      return Scaffold(
        body: shell,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: BorderDirectional(top: BorderSide(color: colors.divider)),
          ),
          child: NavigationBar(
            height: barHeight < _minNavBarHeight ? _minNavBarHeight : barHeight,
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _select,
            indicatorShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(AtharRadii.navPill),
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationDestination(
                  icon: AtharIcon.ui(d.icon, color: colors.textTertiary),
                  selectedIcon: AtharIcon.ui(
                    d.icon,
                    color: colors.onPrimaryContainer,
                  ),
                  label: d.label.tr(),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: BorderDirectional(end: BorderSide(color: colors.divider)),
            ),
            child: NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -1,
              indicatorShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(AtharRadii.navPill),
                ),
              ),
              leading: Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: AtharSpacing.md,
                  bottom: AtharSpacing.xl,
                ),
                child: _RailMark(padding: _railMarkPadding),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: AtharIcon.ui(d.icon, color: colors.textTertiary),
                    selectedIcon: AtharIcon.ui(
                      d.icon,
                      color: colors.onPrimaryContainer,
                    ),
                    label: Text(d.label.tr()),
                  ),
              ],
            ),
          ),
          Expanded(child: shell),
        ],
      ),
    );
  }
}

/// The app mark (44) at the top of the rail. Never mirrors.
class _RailMark extends StatelessWidget {
  const _RailMark({required this.padding});

  final double padding;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: AtharSizes.iconTile,
      height: AtharSizes.iconTile,
      padding: EdgeInsetsDirectional.all(padding),
      decoration: BoxDecoration(
        color: isDark ? colors.primaryContainer : colors.primary,
        borderRadius: AtharRadii.chipRadius,
      ),
      child: SvgPicture.asset(
        isDark ? AtharAssets.brandMarkDark : AtharAssets.brandMarkWhite,
        semanticsLabel: 'app.name'.tr(),
      ),
    );
  }
}
