import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Thin wrapper around Scaffold that applies consistent safe-area + padding.
/// Use for most content screens; use raw Scaffold only when you need
/// edge-to-edge layouts (e.g., video backgrounds).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding = const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
    this.safeArea = true,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsets padding;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: body);
    if (safeArea) content = SafeArea(child: content);

    return Scaffold(
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}