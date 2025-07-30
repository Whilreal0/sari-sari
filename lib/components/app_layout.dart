import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        
        final shouldPop = await _onWillPop(context);
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
      ),
    );
  }
} 
