import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'note_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box? _pinBox;
  Box? _noteBox;
  TextEditingController _pinController = TextEditingController();

  String _enteredPin = '';
  bool _authenticated = false;
  bool _isCreatingPin = false;

  @override
  void initState() {
    super.initState();
    _initializeBoxes();
  }

  Future<void> _initializeBoxes() async {
    await Hive.initFlutter();
    _pinBox = await Hive.openBox('pinBox');
    _noteBox = await Hive.openBox('noteBox');
    _checkAuthentication();
  }

  void _checkAuthentication() {
    String? storedPin = _pinBox!.get('pin');
    print('Stored PIN: $storedPin');

    if (storedPin == null || storedPin.isEmpty) {
      setState(() {
        _isCreatingPin = true;
      });
    } else {
      setState(() {
        _isCreatingPin = false;
      });
    }
  }

  void _createPin() {
    if (_enteredPin.length == 6) {
      _pinBox!.put('pin', _enteredPin);
      setState(() {
        _authenticated = true;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NoteHome()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('PIN must be 6 digits'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _authenticate() {
    String? storedPin = _pinBox!.get('pin');
    if (storedPin == _enteredPin) {
      setState(() {
        _authenticated = true;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NoteHome()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Incorrect PIN'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pinScreen(),
      ),
    );
  }

  Widget _pinScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isCreatingPin ? 'Create your PIN' : 'Enter your PIN',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        PinPad(
          onPinChanged: (pin) {
            setState(() {
              _enteredPin = pin;
            });
          },
          onSubmit: _isCreatingPin ? _createPin : _authenticate,
        ),
      ],
    );
  }
}

class PinPad extends StatefulWidget {
  final Function(String) onPinChanged;
  final VoidCallback onSubmit;

  const PinPad({
    Key? key,
    required this.onPinChanged,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _PinPadState createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _pin = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              _pin.padRight(6, '_'),
              style: const TextStyle(fontSize: 24, fontFamily: 'Courier'),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PinButton(onPressed: () => _onKeyPressed('1'), text: '1'),
              PinButton(onPressed: () => _onKeyPressed('2'), text: '2'),
              PinButton(onPressed: () => _onKeyPressed('3'), text: '3'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PinButton(onPressed: () => _onKeyPressed('4'), text: '4'),
              PinButton(onPressed: () => _onKeyPressed('5'), text: '5'),
              PinButton(onPressed: () => _onKeyPressed('6'), text: '6'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PinButton(onPressed: () => _onKeyPressed('7'), text: '7'),
              PinButton(onPressed: () => _onKeyPressed('8'), text: '8'),
              PinButton(onPressed: () => _onKeyPressed('9'), text: '9'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 60),
              PinButton(onPressed: () => _onKeyPressed('0'), text: '0'),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _onDeletePressed,
                icon: const Icon(Icons.backspace),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.onSubmit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _onKeyPressed(String key) {
    if (_pin.length < 6) {
      setState(() {
        _pin += key;
      });
      widget.onPinChanged(_pin);
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
      widget.onPinChanged(_pin);
    }
  }
}

class PinButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const PinButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: 24),
      ),
      color: Colors.blue,
      textColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    );
  }
}
