import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;

  const CustomDivider({
    super.key,
    this.thickness = 1,
    this.indent = 16,
    this.endIndent = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? Theme.of(context).dividerColor,
    );
  }
}
