import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? drawer;

  const AppLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: actions,
      ),
      drawer: drawer,
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: body,
      ),
    );
  }
} 