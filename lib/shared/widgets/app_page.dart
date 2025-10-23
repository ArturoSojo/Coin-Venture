import 'package:flutter/material.dart';

import '../styles/app_spacing.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.children,
    this.spacing = AppSpacing.lg,
    this.scrollable = true,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _withSpacing(children, spacing),
    );

    if (!scrollable) {
      return column;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: column,
    );
  }

  List<Widget> _withSpacing(List<Widget> children, double spacing) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i != children.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }
}
