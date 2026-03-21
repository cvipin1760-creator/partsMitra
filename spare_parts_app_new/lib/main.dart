import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/login_screen.dart';
import 'screens/retailer_dashboard.dart';
import 'screens/mechanic_dashboard.dart';
import 'screens/wholesaler_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/staff_dashboard.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'utils/constants.dart';
import 'screens/auth_home_screen.dart';
import 'screens/offers_screen.dart';
import 'screens/retailer_orders_screen.dart';
import 'screens/user_settings_screen.dart';
import 'widgets/oem_battery_prompt.dart';
import 'screens/admin_ai_training_report_screen.dart';
import 'screens/thank_you_screen.dart';
import 'screens/pending_approval_screen.dart';

import 'services/notification_service.dart';
import 'utils/app_theme.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  await NotificationService.initialize();
  NotificationService.configureNavigationKey(_navigatorKey);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tprov = Provider.of<ThemeProvider>(context);
    final tm = tprov.themeMode;
    final seed = tprov.seedColor;
    final textScale = tprov.textScale;
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Spares Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightWithSeed(seed),
      darkTheme: AppTheme.darkWithSeed(seed),
      themeMode: tm,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(textScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthWrapper(),
      routes: {
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return ResetPasswordScreen(email: email);
        },
        '/orders': (context) => const RetailerOrdersScreen(),
        '/settings': (context) => const UserSettingsScreen(),
        '/offers': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          String? offerType;
          if (args is Map) {
            final dynamic t = args['offerType'];
            if (t is String) offerType = t;
          }
          return OffersScreen(initialOfferType: offerType);
        },
        '/dashboard/retailer': (context) => const RetailerDashboard(),
        '/dashboard/mechanic': (context) => const MechanicDashboard(),
        '/dashboard/wholesaler': (context) => const WholesalerDashboard(),
        '/dashboard/admin': (context) => const AdminDashboard(),
        '/dashboard/staff': (context) => const StaffDashboard(),
        '/admin/ai-training': (context) => const AdminAITrainingReportScreen(),
        '/thank-you': (context) => const ThankYouScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      return const AuthHomeScreen();
    }

    if (authProvider.user!.status == 'PENDING') {
      return const PendingApprovalScreen();
    }

    // Initialize notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final np = Provider.of<NotificationProvider>(context, listen: false);
      if (!np.isConnected) {
        np.init(authProvider.user!.roles.first, userId: authProvider.user!.id);
      }
      showBatteryOptimizationPromptIfNeeded(context);
      // Ensure topic subscription for all roles and identity remembered for token refresh
      NotificationService.subscribeToTopicsForRoles(authProvider.user!.roles);
      NotificationService.rememberIdentity(
        authProvider.user!.roles.join(','),
        userId: authProvider.user!.id,
      );
    });

    if (authProvider.user!.roles.contains(Constants.roleRetailer)) {
      return const RetailerDashboard();
    } else if (authProvider.user!.roles.contains(Constants.roleMechanic)) {
      return const MechanicDashboard();
    } else if (authProvider.user!.roles.contains(Constants.roleWholesaler)) {
      return const WholesalerDashboard();
    } else if (authProvider.user!.roles.contains(Constants.roleAdmin) ||
        authProvider.user!.roles.contains(Constants.roleSuperManager)) {
      return const AdminDashboard();
    } else if (authProvider.user!.roles.contains(Constants.roleStaff)) {
      return const StaffDashboard();
    } else {
      return const LoginScreen();
    }
  }
}
