import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/language_provider.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
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
    return MaterialApp(
      title: 'Spares Hub',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
      routes: {
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return ResetPasswordScreen(email: email);
        },
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.user == null) {
      return const AuthHomeScreen();
    }

    // Initialize notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final np = Provider.of<NotificationProvider>(context, listen: false);
      if (!np.isConnected) {
        np.init(authProvider.user!.roles.first);
      }
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
