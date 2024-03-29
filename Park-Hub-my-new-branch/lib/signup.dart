// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'signin.dart';
import 'package:logger/logger.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  SignUpWidgetState createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final _formKey = GlobalKey<FormState>();
  final Logger logger = Logger();
  bool _isPasswordVisible = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildLogo(),
                _buildHeaderText(),
                _buildNameFields(),
                const SizedBox(height: 10),
                _buildUserNameField(),
                const SizedBox(height: 10),
                _buildEmailField(),
                const SizedBox(height: 10),
                _buildPhoneNumberField(),
                const SizedBox(height: 10),
                _buildPasswordField(),
                const SizedBox(height: 10),
                _buildConfirmPasswordField(),
                const SizedBox(height: 10),
                _buildSignUpButton(),
                const SizedBox(height: 10),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section 1: UI Components

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/img.jpg',
      width: 318.0,
      height: 150.0,
    );
  }

  Widget _buildHeaderText() {
    return const Column(
      children: [
        Text(
          'Welcome',
          style: TextStyle(
            fontSize: 40.0,
            fontFamily: 'bangers',
          ),
        ),
        Text(
          "Let's create your account",
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextFormField(
            controller: _firstNameController,
            labelText: 'First Name',
            prefixIcon: Icons.account_circle_outlined,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: _buildTextFormField(
            controller: _lastNameController,
            labelText: 'Last Name',
            prefixIcon: Icons.account_circle_outlined,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserNameField() {
    return _buildTextFormField(
      controller: _userNameController,
      labelText: 'User Name',
      prefixIcon: Icons.account_circle,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a user name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return _buildTextFormField(
      controller: _emailController,
      labelText: 'Email',
      prefixIcon: Icons.alternate_email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        } else if (!RegExp(r'^[\w\-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneNumberField() {
    return _buildTextFormField(
      controller: _phoneNumberController,
      labelText: 'Mobile Number',
      prefixIcon: Icons.mobile_friendly,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        else if (value.length < 10 ) {
          return ' Please enter valid mobile number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildPasswordTextFormField(
      controller: _passwordController,
      labelText: 'Password',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        } else if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
          return 'Password must contain at least one capital letter';
        } else if (!RegExp(r'(?=.*[!@#$%^&*()_+{}|<>?])').hasMatch(value)){
          return 'Password must contain at least one symbol';
        }else if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
          return 'Password must contain at least one number';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildPasswordTextFormField(
      controller: _confirmPasswordController,
      labelText: 'Confirm Password',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        } else if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        } else if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () {
        _signUp(context);

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 100.0),
      ),
      child: const Text(
        "Register",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(5.0),
      ),
      child: const Text(
        'Already have an account? LOGIN',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  // Section 2: Helper Methods

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(prefixIcon),
      ),
      style: const TextStyle(fontSize: 20.0),
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildPasswordTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    autovalidateMode = AutovalidateMode.onUserInteraction,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: labelText,
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
      validator: validator,
      textCapitalization: TextCapitalization.words,
      autovalidateMode: autovalidateMode,
    );
  }

  // Section 3: Firebase Authentication and Database Operations

  Future<void> checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    if (user?.emailVerified ?? false) {
      logger.i('Email is verified');
    } else {
      logger.i('Email is not verified');
    }
  }

  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    await user?.sendEmailVerification();

    logger.i('Verification email sent to ${user?.email}');
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() == _confirmPasswordController.text.trim();
  }


  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await user.reload();
        checkEmailVerification();
      }
    });
  }


  @override
  void initState() {
    super.initState();
    _listenToAuthChanges();
  }


  Future<void> _signUp(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        if (passwordConfirmed()) {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          // Send email verification
          await userCredential.user?.sendEmailVerification();

          // Show a dialog for email verification
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Verify Email'),
                content: Text('A verification email has been sent to "${userCredential.user?.email}". Please verify your email before signing in, Within 3 minutes.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );

          // Continue listening to authentication state changes
          _listenToAuthChanges();

        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(context,'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(
            context, 'The account already exists for that email.');
      }
    } catch (e) {
       showSnackBar(context, 'An error occurred during sign-up.');
    }

    // Check if the email is verified before adding user details to Firestore
    await _checkAndAddUserDetails();
  }

  Future<void> _checkAndAddUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    if (user?.emailVerified ?? false) {
      // Email is verified, add user details to Firestore
      await addUserDetails(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _userNameController.text.trim(),
        _emailController.text.trim(),
        _phoneNumberController.text.trim(),
        _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    } else {
      // Email is not verified, wait for 5 minutes before showing the message
      await Future.delayed(const Duration(minutes: 3));

      user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified ?? false) {
        // Email is verified after waiting, add user details to Firestore
        await addUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _userNameController.text.trim(),
          _emailController.text.trim(),
          _phoneNumberController.text.trim(),
          _passwordController.text.trim(),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      } else {
        // Email is still not verified, you can handle this case as needed

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('   Email not Verified',),
              actions: [
                const SizedBox(height:20,),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      user?.sendEmailVerification();
                    },
                    child: const Text('Resend Verification Email'),
                  ),
                )
              ],
            );
          },
        );

      }
    }
  }

  Future<void> addUserDetails( String firstName, String lastName, String userName, String email, dynamic mobileNumber, String password) async {
    await FirebaseFirestore.instance.collection('Users').doc(email).set({
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'email': email,
      'mobileNumber': mobileNumber,
      'password': password,
    });
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