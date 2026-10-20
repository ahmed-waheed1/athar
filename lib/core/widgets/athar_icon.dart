import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/athar_assets.dart';

/// An Athar outline icon tinted with [color] (defaults to the ambient IconTheme color).
class AtharIcon extends StatelessWidget {
  const AtharIcon(
    this.assetPath, {
    super.key,
    this.size = 24,
    this.color,
    this.mirrorInRtl = false,
    this.semanticLabel,
  });

  /// UI icon by name (e.g. 'back'); mirrors in RTL when the spec marks it directional.
  AtharIcon.ui(
    String name, {
    Key? key,
    double size = 24,
    Color? color,
    String? semanticLabel,
  }) : this(
         AtharAssets.uiIcon(name),
         key: key,
         size: size,
         color: color,
         mirrorInRtl: AtharAssets.directionalUiIcons.contains(name),
         semanticLabel: semanticLabel,
       );

  /// Habit icon by its stored id. Habit icons never mirror.
  AtharIcon.habit(
    String name, {
    Key? key,
    double size = 24,
    Color? color,
    String? semanticLabel,
  }) : this(
         AtharAssets.habitIcon(name),
         key: key,
         size: size,
         color: color,
         semanticLabel: semanticLabel,
       );

  final String assetPath;
  final double size;
  final Color? color;
  final bool mirrorInRtl;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color!;
    final icon = SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
    if (!mirrorInRtl) return icon;
    return Transform.flip(
      flipX: Directionality.of(context) == TextDirection.rtl,
      child: icon,
    );
  }
}
