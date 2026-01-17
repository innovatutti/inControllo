import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinRecoveryScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const PinRecoveryScreen({
    super.key,
    required this.onSuccess,
  });

  @override
  State<PinRecoveryScreen> createState() => _PinRecoveryScreenState();
}

class _PinRecoveryScreenState extends State<PinRecoveryScreen> {
  final _answerController = TextEditingController();
  String _securityQuestion = '';
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityQuestion();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadSecurityQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _securityQuestion = prefs.getString('security_question') ?? '';
      _isLoading = false;
    });
  }

  Future<void> _verifyAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAnswer = prefs.getString('security_answer') ?? '';
    
    if (_answerController.text.trim().toLowerCase() == savedAnswer.toLowerCase()) {
      // Risposta corretta - mostra dialogo per impostare nuovo PIN
      _showResetPinDialog();
    } else {
      setState(() {
        _errorMessage = 'Risposta errata';
        _answerController.clear();
      });
    }
  }

  void _showResetPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ResetPinDialog(
        onPinReset: () {
          Navigator.of(context).pop();
          widget.onSuccess();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recupero PIN'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.help_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            const Text(
              'Rispondi alla tua domanda di sicurezza',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _securityQuestion,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: 'Risposta',
                border: const OutlineInputBorder(),
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                setState(() {
                  _errorMessage = '';
                });
              },
              onSubmitted: (_) => _verifyAnswer(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _answerController.text.isEmpty ? null : _verifyAnswer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Verifica', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetPinDialog extends StatefulWidget {
  final VoidCallback onPinReset;

  const _ResetPinDialog({required this.onPinReset});

  @override
  State<_ResetPinDialog> createState() => _ResetPinDialogState();
}

class _ResetPinDialogState extends State<_ResetPinDialog> {
  String _newPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isConfirming ? 'Conferma nuovo PIN' : 'Nuovo PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isConfirming
                ? 'Inserisci nuovamente il PIN'
                : 'Inserisci un nuovo PIN a 4 cifre',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Visualizzazione PIN
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final currentPin = _isConfirming ? _confirmPin : _newPin;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _errorMessage.isNotEmpty
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    currentPin.length > index ? '●' : '',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              );
            }),
          ),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),
          // Tastierino numerico
          _buildNumPad(),
        ],
      ),
    );
  }

  Widget _buildNumPad() {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          for (var row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', 'del']
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((key) {
                  if (key.isEmpty) {
                    return const SizedBox(width: 50, height: 50);
                  }
                  return _buildKey(key);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    return InkWell(
      onTap: () => key == 'del' ? _onDelete() : _onNumber(key),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: key == 'del'
              ? Colors.grey.shade300
              : Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Center(
          child: key == 'del'
              ? const Icon(Icons.backspace_outlined, size: 20)
              : Text(
                  key,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  void _onNumber(String number) {
    setState(() {
      _errorMessage = '';
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          if (_confirmPin.length == 4) {
            _checkConfirm();
          }
        }
      } else {
        if (_newPin.length < 4) {
          _newPin += number;
          if (_newPin.length == 4) {
            setState(() {
              _isConfirming = true;
            });
          }
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      _errorMessage = '';
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_newPin.isNotEmpty) {
          _newPin = _newPin.substring(0, _newPin.length - 1);
        }
      }
    });
  }

  Future<void> _checkConfirm() async {
    if (_newPin == _confirmPin) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_pin', _newPin);
      widget.onPinReset();
    } else {
      setState(() {
        _errorMessage = 'I PIN non corrispondono';
        _confirmPin = '';
        _newPin = '';
        _isConfirming = false;
      });
    }
  }
}
