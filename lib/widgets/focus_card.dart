import 'package:flutter/material.dart';
import '../theme/styles.dart';

class FocusCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;

  const FocusCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppStyles.cardRadius),
        boxShadow: AppStyles.softShadow,
      ),
      child: child,
    );
  }
}
