import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers.dart';
import 'features/auth/lock_screen.dart';
import 'features/home/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final storage = StorageService();
  await storage.init();

  final notifications = NotificationService();
  await notifications.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
      ],
      child: const ChelebanApp(),
    ),
  );
}

class ChelebanApp extends ConsumerWidget {
  const ChelebanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    ThemeMode themeMode;
    switch (settings.themeMode) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    final locale = settings.locale == 'en'
        ? const Locale('en', 'US')
        : const Locale('fa', 'IR');

    return MaterialApp(
      title: 'چله‌بان',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: settings.locale == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: child!,
        );
      },
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _authenticated = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final settings = ref.read(settingsProvider);
    if (!settings.lockEnabled) {
      setState(() {
        _authenticated = true;
        _checking = false;
      });
      return;
    }
    setState(() => _checking = false);
  }

  void _onSuccess() {
    setState(() => _authenticated = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        backgroundColor: AppColors.militaryBlack,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.militaryGreen),
        ),
      );
    }

    if (!_authenticated) {
      return LockScreen(onAuthenticated: _onSuccess);
    }

    return const HomeShell();
  }
}
