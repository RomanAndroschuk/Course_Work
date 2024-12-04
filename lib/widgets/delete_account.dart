import 'db.dart';
import 'package:flutter/material.dart';

class DeleteAccount extends StatelessWidget {
  DeleteAccount({super.key});

  late String _password, _email;

  final DatabaseService _databaseService = DatabaseService.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              

              // Label
              const Text(
                'Delete Account',
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
                onChanged: (email) {
                  _email = email;
                },
                validator: (email) {
                  if (email == null || email.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegExp = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegExp.hasMatch(email)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              // Password field
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password:',
                  border: OutlineInputBorder(),
                ),
                onChanged: (password) => _password = password,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              // Reset button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool canDelete = await _deleteUser();

                      showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            title: Text(canDelete ? 'Success!' : 'Error!'),
                            content: Text(canDelete
                                ? 'User is removed!'
                                : 'Something went wrong!'),
                            actions: [
                              MaterialButton(
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  if (canDelete) {
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
                  child: const Text("Delete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  )                ),
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

  Future<bool> _deleteUser() async {
    final user = await _databaseService.getUserByEmail(_email);

    if (user != null) {
      await _databaseService.deleteUserByEmail(_email);
      return true;
    }
    return false;
  }
}
