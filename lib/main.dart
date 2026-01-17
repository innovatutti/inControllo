import 'package:flutter/material.dart';
import 'package:parental_control/screens/app_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parental_control/screens/pin_screen.dart';
import 'package:parental_control/screens/install_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'inControllo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/install_verification': (context) => const InstallVerificationScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _hasPIN = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPIN();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Quando l'app torna in foreground, richiedi il PIN
    if (state == AppLifecycleState.resumed && _isAuthenticated) {
      setState(() {
        _isAuthenticated = false;
      });
    }
  }

  Future<void> _checkPIN() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPIN = prefs.getString('app_pin');
    setState(() {
      _hasPIN = savedPIN != null && savedPIN.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthenticated) {
      return PinScreen(
        isSetup: !_hasPIN,
        onSuccess: () {
          setState(() {
            _isAuthenticated = true;
          });
        },
      );
    }

    return const AppListScreen();
  }
}
