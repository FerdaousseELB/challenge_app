import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_vendeur.dart';
import '../../service/login_vendeur_service.dart';

class LoginVendeurPage extends StatefulWidget {
  @override
  _LoginVendeurPageState createState() => _LoginVendeurPageState();
}

class _LoginVendeurPageState extends State<LoginVendeurPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendeur Login'),
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

      final User? user = userCredential.user;

      if (user != null) {
        final String? token = await user.getIdToken();

        if (token != null) {
          final bool isVendeur = await LoginVendeurService.isUserVendeur(email, token);
          if (isVendeur) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeVendeurPage(token: token)));
          } else {
            setState(() {
              _errorMessage = 'Vous n\'avez pas l\'autorisation d\'accéder à cette application en tant que vendeur.';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Token is null.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }
}
