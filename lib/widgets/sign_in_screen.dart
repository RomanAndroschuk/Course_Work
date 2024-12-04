import 'package:flutter/material.dart';
import 'db.dart';
import 'delete_account.dart';
import 'signup_screen.dart';
import 'calculator.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late String _email, _password;
  late int _userId;
  final DatabaseService _databaseService = DatabaseService.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            
            children: <Widget>[
              
              
              // Label
              const Text(
                'Log in',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24.0),

              // Email field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                onChanged: (email) => _email = email,
              ),
              const SizedBox(height: 16.0),
              
              // Password field
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onChanged: (password) => _password = password,
              ),
              const SizedBox(height: 16.0),

              
              
              // Sign up button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: const Text("Sign up"),
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Login and Reset Password buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            bool userVerified = await verifyUser();
                            if (userVerified) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Calculator(userId: _userId)),
                              );
                            } else {
                              _showErrorDialog(context, 'Incorrect email or password!');
                            }
                          }
                        },
                        child: const Text("Log in"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  
                  // Delete Password button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  DeleteAccount()),
                          );
                        },
                        child: const Text("Delete account",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                        
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> verifyUser() async {
    final user = await _databaseService.getUserByEmail(_email);
    if (user != null && user['password'] == _password) {
      _userId = user['id'];
      return true;
    }
    return false;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Error!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: const TextStyle(color: Colors.red)),
              MaterialButton(
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
