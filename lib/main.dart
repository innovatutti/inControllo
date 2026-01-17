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
  DateTime? _lastPausedTime;

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
    if (state == AppLifecycleState.paused) {
      // App va in background - salva il tempo
      _lastPausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _isAuthenticated) {
      // App torna in foreground - richiedi PIN se sono passati più di 30 secondi
      if (_lastPausedTime != null) {
        final timeDiff = DateTime.now().difference(_lastPausedTime!);
        if (timeDiff.inSeconds > 30) {
          setState(() {
            _isAuthenticated = false;
          });
        }
      }
    }
  }

  Future<void> _checkPIN() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPIN = prefs.getString('app_pin');
    print('Verifica PIN: ${savedPIN != null ? "PIN trovato" : "PIN non trovato"}');
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
