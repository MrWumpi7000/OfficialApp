import 'package:flutter/material.dart';
import 'custom_bottom_app_bar.dart';

class BaseScaffold extends StatelessWidget {
  final GlobalKey<CustomBottomAppBarState>? bottomBarKey;
  final int currentIndex;
  final Widget child;

  const BaseScaffold({
    required this.child,
    required this.currentIndex,
    this.bottomBarKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: child,
      bottomNavigationBar: CustomBottomAppBar(
        key: bottomBarKey,
        currentIndex: currentIndex,
      ),
    );
  }
}