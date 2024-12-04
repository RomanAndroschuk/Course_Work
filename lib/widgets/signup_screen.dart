import 'db.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String _name, _password, _email;
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
            children: <Widget>[
              

              // Title label
              const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24.0),

              // Name field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onChanged: (name) => _name = name,
              ),
              const SizedBox(height: 16.0),

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
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                onChanged: (password) => _password = password,
              ),
              const SizedBox(height: 24.0),

              // Sign up button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      bool isUserAdded = await _addUser();
                      showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            title: Text(isUserAdded ? 'Success!' : 'Email Used'),
                            content: Text(
                              isUserAdded
                                  ? 'Account created successfully!'
                                  : 'This email is already used!',
                            ),
                            actions: [
                              MaterialButton(
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  if (isUserAdded) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text(
                                  "OK",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text("Sign up"),
                ),
              ),
              const SizedBox(height: 16.0),

              // Back button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _addUser() async {
    final user = await _databaseService.getUserByEmail(_email);
    
    if (user != null) {
      return false;
    }
    await _databaseService.addUser(_name, _password, _email);
    return true;
  }
}
