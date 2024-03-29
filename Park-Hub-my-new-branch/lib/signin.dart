// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:smartparkin1/HomePage.dart';
import 'signup.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final Logger logger = Logger();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;

  bool _isPasswordVisible = false;
  bool resetPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      resetPassword =true;
      // Display a success message to the user
      showSnackBar(context,'Password reset email sent. Check your inbox.');
    } catch (e) {
      resetPassword = false;
      logger.i('Error sending password reset email: $e');
      showSnackBar(context,'An error occurred. Please try again later.');
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (resetPassword == true){
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          await firestore.collection('Users').doc(_emailController.text).update({
            'password': _passwordController.text,
          });
        }
        // If sign-up is successful, navigate to the SignInPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackBar(context, 'Wrong password provided for that user.');
      } else {
        showSnackBar(context, 'An error occurred during sign-in.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImage(),
                const Text(
                  'Hello there, Welcome Back',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontFamily: 'bangers',
                  ),
                ),
                const Text(
                  'Sign In to continue',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'antic',
                  ),
                ),
                const SizedBox(height: 20.0),
                _buildEmailTextField(),
                const SizedBox(height: 10.0),
                _buildPasswordTextField(),
                const SizedBox(height: 10.0),
                _buildForgotPasswordButton(),
                const SizedBox(height: 10.0),
                _buildLoginButton(),
                const SizedBox(height: 10.0),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      'assets/images/img.jpg',
      height: 227.0,
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.alternate_email_outlined),
      ),
      style: const TextStyle(fontSize: 20.0),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        } else if (!RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          child: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
      style: const TextStyle(fontSize: 20.0),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        } else if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: _resetPassword,
      child: const Text(
        'Forgot Password ?',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: _signInWithEmailAndPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 100.0),
        ),
        child: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignUpWidget()),
        );
      },
      child: const Text(
        'New User? Register',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }



  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blue.shade300, // Adjust the color as needed
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Adjust the radius as needed
        ),
      ),
    );
  }


}
