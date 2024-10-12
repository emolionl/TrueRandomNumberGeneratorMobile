import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trng/pages/ble_page.dart';
import 'package:trng/pages/dashboard_page.dart';
import 'package:trng/pages/researches/classic_trng/database_debug_page.dart';
import 'package:trng/pages/login_page.dart';
import 'package:trng/pages/register_page.dart';
import 'package:trng/pages/researches/classic_trng/session_list_page.dart';
import 'package:trng/providers/auth_provider.dart';
import 'package:trng/pages/home_page.dart';
import 'package:trng/pages/researches/classic_trng/classic_trng.dart';
import 'package:trng/pages/users_page.dart';
import 'package:trng/providers/database_provider.dart';
import 'package:trng/providers/serial_comm_provider.dart';
import 'package:trng/providers/test_provider.dart';
import 'pages/trng_page.dart';
import 'package:trng/pages/settings_page.dart';
import 'package:trng/widgets/auth_guard.dart';
import 'package:trng/widgets/responsive_scaffold.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/ble_provider.dart';
import 'package:trng/pages/connections_device_test.dart';
import 'package:trng/helpers/database_helper.dart' as helpers;

BleProvider? bleProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  // Initialize SQLite for Windows
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
    ),
  );

  // Initialize DatabaseHelper
  final dbHelper = helpers.DatabaseHelper.instance;
  await dbHelper.initDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SerialCommProvider()),
        Provider<helpers.DatabaseHelper>.value(value: dbHelper),
        ChangeNotifierProvider(create: (_) => TestProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BleProvider()),
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
      title: 'ESP32 Serial Communication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return ResponsiveScaffold(
            title: 'Home',
            body: authProvider.user != null ? const DashboardPage() : const HomePage(),
          );
        },
      ),
      routes: {
        '/users':                     (context) => const ResponsiveScaffold(title: 'Users', body: AuthGuard(child: UsersPage())),
        '/register':                  (context) => const ResponsiveScaffold(title: 'Register', body: RegisterPage()),
        '/login':                     (context) => const ResponsiveScaffold(title: 'Login', body: LoginPage()),
        '/settings':                  (context) => const ResponsiveScaffold(title: 'Settings', body: AuthGuard(child: SettingsPage())),
        '/dashboard':                 (context) => const ResponsiveScaffold(title: 'Dashboard', body: AuthGuard(child: DashboardPage())),
        //classic True Random Number Generator
        '/classic_trng':              (context) => const ResponsiveScaffold(title: 'Classic Trng', body: AuthGuard(child: ClassicTrng())),
        '/database_debug':            (context) => const ResponsiveScaffold(title: 'Database Debug', body: AuthGuard(child: DatabaseDebugPage())),
        '/classic_trng_sessions': (context) =>  ResponsiveScaffold(title: 'All Sessions', body: AuthGuard(child: SessionListPage())),
        //bluetooth connection
        '/ble':                       (context) => const ResponsiveScaffold(title: 'Bluetooth Connection', body: BlePage()),
        '/connection_device-test':    (context) => const ResponsiveScaffold(title: 'Connection device test', body: ConnectionDeviceTest()),
        
        '/trng':                      (context) => const ResponsiveScaffold(title: 'TRNG', body: AuthGuard(child: TrngPage())),
        
      },
    );
  }
}