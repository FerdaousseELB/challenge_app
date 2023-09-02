import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_gerant.dart';
import '../../service/login_gerant_service.dart';

class LoginGerantPage extends StatefulWidget {
  @override
  _LoginGerantPageState createState() => _LoginGerantPageState();
}

class _LoginGerantPageState extends State<LoginGerantPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérant Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter email and password.';
        });
        return;
      }

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final User? user = userCredential.user;
        if (user != null) {
          final String? token = await user.getIdToken();
          if (token != null) {
            final bool isGerant = await LoginGerantService.isUserGerant(email, token);
            if (isGerant) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeGerantPage(token: token)));
            } else {
              setState(() {
                _errorMessage = 'Vous n\'avez pas l\'autorisation d\'accéder à cette application en tant que gérant.';
              });
            }
          }
        }



      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _errorMessage = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _errorMessage = 'Wrong password provided for that user.';
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${e.message}';
        });
      }
    }
  }
}
