import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Self Service Portal',
      theme: AppTheme.lightTheme(),
      routerConfig: AppRouter.config,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ColoredBox(
        color: AppTheme.tealSurface,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: child!,
          ),
        ),
      ),
    );
  }
}
