import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'home_page.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Box? _pinBox;
  TextEditingController _pinController = TextEditingController();
  TextEditingController _confirmPinController = TextEditingController();
  String _newPin = '';
  String _confirmPin = '';

  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _pinBox = await Hive.openBox('pinBox');
  }

  void _updatePin() {
    if (_newPin.length == 6 && _newPin == _confirmPin) {
      _pinBox!.put('pin', _newPin);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PINs do not match or are not 6 digits long')),
      );
    }
  }

  void _deletePin() {
    _pinBox!.delete('pin');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PIN deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF000633),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Color(0xFF000633),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Edit PIN'),
                        content: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _pinController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    InputDecoration(labelText: 'Enter new PIN'),
                                onChanged: (value) {
                                  setState(() {
                                    _newPin = value;
                                  });
                                },
                                maxLength: 6,
                                obscureText: true,
                              ),
                              TextField(
                                controller: _confirmPinController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: 'Confirm new PIN'),
                                onChanged: (value) {
                                  setState(() {
                                    _confirmPin = value;
                                  });
                                },
                                maxLength: 6,
                                obscureText: true,
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _updatePin,
                                child: Text('Update PIN'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text('Edit PIN'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deletePin,
                child: Text('Delete PIN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
