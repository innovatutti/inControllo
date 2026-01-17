import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_recovery_screen.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  final VoidCallback onSuccess;
  final bool isRecovery;

  const PinScreen({
    super.key,
    required this.isSetup,
    required this.onSuccess,
    this.isRecovery = false,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _enteredPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isSettingSecurity = false;
  String _errorMessage = '';
  
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  String? _selectedQuestion;
  
  final List<String> _securityQuestions = [
    'Qual è il nome del tuo primo animale domestico?',
    'In che città sei nato/a?',
    'Qual è il cognome da nubile di tua madre?',
    'Qual è il nome della tua scuola elementare?',
    'Qual è il tuo cibo preferito?',
    'Qual è il nome del tuo migliore amico d\'infanzia?',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSettingSecurity) {
      return _buildSecurityQuestionSetup();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSetup ? 'Imposta PIN' : 'Inserisci PIN'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                widget.isSetup
                    ? (_isConfirming ? 'Conferma PIN' : 'Crea un PIN a 4 cifre')
                    : 'Inserisci il tuo PIN',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              // Visualizzazione PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final currentPin = _isConfirming ? _confirmPin : _enteredPin;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _errorMessage.isNotEmpty
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        currentPin.length > index ? '●' : '',
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
              if (!widget.isSetup) ...[
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _onForgotPin,
                  child: const Text('PIN dimenticato?'),
                ),
              ],
              const SizedBox(height: 20),
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
          color: Theme.of(context).colorScheme.primaryContainer,
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
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          if (_confirmPin.length == 4) {
            _checkConfirmPin();
          }
        }
      } else {
        if (_enteredPin.length < 4) {
          _enteredPin += number;
          if (_enteredPin.length == 4) {
            if (widget.isSetup) {
              _moveToConfirm();
            } else {
              _checkPin();
            }
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      _errorMessage = '';
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      }
    });
  }

  void _moveToConfirm() {
    setState(() {
      _isConfirming = true;
    });
  }

  Future<void> _checkConfirmPin() async {
    if (_enteredPin == _confirmPin) {
      // PIN confermato, ora chiedi domanda di sicurezza
      setState(() {
        _isSettingSecurity = true;
      });
    } else {
      setState(() {
        _errorMessage = 'I PIN non corrispondono';
        _confirmPin = '';
        _enteredPin = '';
        _isConfirming = false;
      });
    }
  }

  Future<void> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('app_pin');
    
    if (_enteredPin == savedPin) {
      widget.onSuccess();
    } else {
      setState(() {
        _errorMessage = 'PIN errato';
        _enteredPin = '';
      });
    }
  }

  void _onForgotPin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PinRecoveryScreen(onSuccess: widget.onSuccess),
      ),
    );
  }

  Widget _buildSecurityQuestionSetup() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Domanda di Sicurezza'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.help_outline,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Imposta una domanda di sicurezza',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Questa domanda ti permetterà di recuperare l\'accesso se dimentichi il PIN',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                value: _selectedQuestion,
                decoration: const InputDecoration(
                  labelText: 'Seleziona domanda',
                  border: OutlineInputBorder(),
                ),
                items: _securityQuestions.map((question) {
                  return DropdownMenuItem(
                    value: question,
                    child: Text(question, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuestion = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Risposta',
                  border: OutlineInputBorder(),
                  helperText: 'Inserisci una risposta che ricorderai',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _canSaveSecurity() ? _saveSecurityQuestion : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Salva e Continua', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _canSaveSecurity() {
    return _selectedQuestion != null && _answerController.text.trim().isNotEmpty;
  }

  Future<void> _saveSecurityQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_pin', _enteredPin);
    await prefs.setString('security_question', _selectedQuestion!);
    await prefs.setString('security_answer', _answerController.text.trim().toLowerCase());
    widget.onSuccess();
  }
}
