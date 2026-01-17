import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallVerificationScreen extends StatefulWidget {
  const InstallVerificationScreen({super.key});

  @override
  State<InstallVerificationScreen> createState() => _InstallVerificationScreenState();
}

class _InstallVerificationScreenState extends State<InstallVerificationScreen> {
  static const platform = MethodChannel('com.incontrollo.parental_control_v2/install_verification');
  
  String _enteredPin = '';
  String _errorMessage = '';
  String _packageName = '';

  @override
  void initState() {
    super.initState();
    _getPackageName();
  }

  Future<void> _getPackageName() async {
    try {
      final name = await platform.invokeMethod('getPackageName');
      setState(() {
        _packageName = name ?? 'Nuova app';
      });
    } catch (e) {
      setState(() {
        _packageName = 'Nuova app';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('Installazione rilevata'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.red.shade700,
              ),
              const SizedBox(height: 32),
              Text(
                'È stata installata una nuova app',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _packageName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Inserisci il PIN per autorizzare',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              // Visualizzazione PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _errorMessage.isNotEmpty ? Colors.red : Colors.red.shade700,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _enteredPin.length > index ? '●' : '',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  );
                }),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
              const SizedBox(height: 48),
              // Tastierino numerico
              _buildNumPad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumPad() {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumButton('1'),
              _buildNumButton('2'),
              _buildNumButton('3'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumButton('4'),
              _buildNumButton('5'),
              _buildNumButton('6'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumButton('7'),
              _buildNumButton('8'),
              _buildNumButton('9'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80),
              _buildNumButton('0'),
              _buildDeleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumButton(String number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.shade100,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _onDeletePressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined, size: 28),
        ),
      ),
    );
  }

  void _onNumberPressed(String number) {
    setState(() {
      _errorMessage = '';
      if (_enteredPin.length < 4) {
        _enteredPin += number;
        if (_enteredPin.length == 4) {
          _checkPin();
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      _errorMessage = '';
      if (_enteredPin.isNotEmpty) {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      }
    });
  }

  Future<void> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('app_pin');
    
    if (_enteredPin == savedPin) {
      // PIN corretto
      await platform.invokeMethod('allowInstall');
    } else {
      setState(() {
        _errorMessage = 'PIN errato - Installazione negata';
        _enteredPin = '';
      });
      
      // Attendi 2 secondi e blocca l'installazione
      await Future.delayed(const Duration(seconds: 2));
      await platform.invokeMethod('denyInstall');
    }
  }
}
