import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import '../features/contacts/contacts_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Edge-to-edge system bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return MaterialApp(
      title: 'Contact Keeper',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // or ThemeMode.system
      home: const _MobileFrame(child: ContactsPage()),
    );
  }
}

class _MobileFrame extends StatelessWidget {
  const _MobileFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      body: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(blurRadius: 40, spreadRadius: -8, offset: Offset(0, 20), color: Color(0x55000000)),
              BoxShadow(blurRadius: 12, spreadRadius: -6, offset: Offset(0, 2), color: Color(0x33000000)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 900),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
