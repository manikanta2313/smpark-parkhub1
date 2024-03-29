
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smartparkin1/settings_page.dart';

import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _userNameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late String? _image;

  bool _isPasswordObscured = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _userNameController = TextEditingController();
    _passwordController = TextEditingController();
    _mobileController = TextEditingController();
    _emailController = TextEditingController();
    _image = 'https://img.freepik.com/premium-vector/avatar-flat-icon-human-white-glyph-blue-background_822686-239.jpg';


    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      getDocId(_currentUser!.email!);
    }
  }

  Future<void> getDocId(String userEmail) async {
    try {
      QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userDocs.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userDocs.docs.first;
        setState(() {
          _firstNameController.text = userDoc['firstName'];
          _lastNameController.text = userDoc['lastName'];
          _passwordController.text = userDoc['password'];
          _userNameController.text = userDoc['userName'].toString();
          _emailController.text = userDoc['email'];
          _mobileController.text = userDoc['mobileNumber'];
          _image = userDoc['profilePicture'];

        });
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
  }



  Widget _buildEditItem(String title, TextEditingController controller) {
    return EditItem(
      title: "",
      widget: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: false,
              style: const TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                labelText: title,
                labelStyle: const TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordItem(String title, TextEditingController controller) {
    return EditItem(
      title: "",
      widget: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: _isPasswordObscured,
              enabled: false,
              style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: title,
                labelStyle: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isPasswordObscured
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordObscured = !_isPasswordObscured;
              });
            },
          ),
        ],
      ),
    );
  }

  void _showLargerImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent, // Set a transparent background
          content: SizedBox(
            width: 200,
            height: 200,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5), // Adjust the opacity as needed
                  shape: BoxShape.circle,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: "user_photo",
                      child: Material(
                        color: Colors.transparent,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.white, // Add a background color
                          foregroundColor: Colors.blue, // Add a border color
                          child: CircleAvatar(
                            radius: 98, // Adjust the inner circle size to add a border effect
                            backgroundImage: NetworkImage(_image!),

                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ),
          ),
        );
      },
    );
  }





  @override
  Widget build(BuildContext context) {
    _image ??= 'https://img.freepik.com/premium-vector/avatar-flat-icon-human-white-glyph-blue-background_822686-239.jpg';
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        // Return true to allow back navigation, return false to prevent it
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue.shade900,
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              icon: const Icon(Ionicons.chevron_back_outline, color: Colors.white),
            ),
            leadingWidth: 80,
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        userName: _userNameController.text,
                        mobile: _mobileController.text,
                        email: _emailController.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text("Edit"),
              ),
              const SizedBox(width: 30,)
            ],
          ),
          body: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade900, Colors.blue.shade500],
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 30,),
                            GestureDetector(
                              onTap: _showLargerImage,
                              child: Hero(
                                tag: "user_photo",
                                child: Material(
                                  color: Colors.transparent,
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.white, // Add a background color
                                    foregroundColor: Colors.blue, // Add a border color
                                    child: CircleAvatar(
                                      radius: 68, // Adjust the inner circle size to add a border effect
                                      backgroundImage: _image != null ? NetworkImage(_image!) : const AssetImage('assets/images/avatar3.png') as ImageProvider,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20), // Add some horizontal space here
                          ],
                        ),

                      ],
                    ),
                  )
              ),
              Positioned(
                top: 200.0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildEditItem("First Name", _firstNameController),
                        _buildEditItem("Last Name", _lastNameController),
                        _buildEditItem("User Name", _userNameController),
                        _buildEditItem("Email", _emailController),
                        _buildEditItem("Mobile", _mobileController),
                        _buildPasswordItem("Password", _passwordController),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    );

  }
}


class EditItem extends StatelessWidget {
  final String title;
  final Widget widget;

  const EditItem({
    super.key,
    required this.title,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        Align(
          alignment: Alignment.center,
          child: widget,
        ),

      ],
    );
  }
}



