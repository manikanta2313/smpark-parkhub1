// edit_profile_page.dart

// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'profile_page.dart';

class EditProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String userName;
  final String mobile;
  final String email;
  const EditProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.mobile,
    required this.email,
  });


  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  // Add controllers for editing profile information
  late TextEditingController _editedFirstNameController;
  late TextEditingController _editedLastNameController;
  late TextEditingController _editedUserNameController;
  late TextEditingController _editedMobileController;
  late String? _image;
  // ... add other controllers as needed

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values
    // You can use the existing controllers from the ProfilePageState
    _editedFirstNameController = TextEditingController(text: widget.firstName);
    _editedLastNameController = TextEditingController(text: widget.lastName);
    _editedUserNameController = TextEditingController(text: widget.userName);
    _editedMobileController = TextEditingController(text: widget.mobile);
    _image = 'https://img.freepik.com/premium-vector/avatar-flat-icon-human-white-glyph-blue-background_822686-239.jpg';

    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      getDocId(_currentUser!.email!);
    }
  }



  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _currentUser;

  Future<void> getDocId(String userEmail) async {
    try {
      QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userDocs.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userDocs.docs.first;
        setState(() {
          _image = userDoc['profilePicture'];

        });
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
  }


  final _formKey = GlobalKey<FormState>();

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

  File? _pickedImage;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (error) {
      print('Error picking image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking image. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  Future<void> _updateUserProfile() async {
    try {
      // If a new image is picked, upload it to Firestore Storage
      String? imageUrl;
      if (_pickedImage != null) {
        // Upload image to Firestore Storage
        final String imagePath = 'user_profile_pictures/${widget.email}/${DateTime.now()}.png';
        final Reference storageReference = FirebaseStorage.instance.ref().child(imagePath);
        final UploadTask uploadTask = storageReference.putFile(_pickedImage!);
        await uploadTask.whenComplete(() async {
          imageUrl = await storageReference.getDownloadURL();
        });

      }

      // Update user document in Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.email)
          .update({
        'firstName': _editedFirstNameController.text,
        'lastName': _editedLastNameController.text,
        'userName': _editedUserNameController.text,
        'mobileNumber': _editedMobileController.text,
        'profilePicture': imageUrl, // Store the image URL in Firestore
        // ... add other fields as needed
      });
      setState(() {
        _image = imageUrl!;
      });
      // Notify the user that the information was saved successfully
      showSnackBar(context, 'Profile information saved successfully!');
    } catch (error) {
      // Handle the error
      print('Error updating user information: $error');
      showSnackBar(context, 'Failed to save profile information. Please try again.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        // Return true to allow back navigation, return false to prevent it
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage())
              );
            },
            icon: const Icon(Ionicons.chevron_back_outline, color: Colors.white),
          ),
          leadingWidth: 80,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade900, Colors.blue.shade500],
              ),
            ),
          ),
          title: const Text(
            "Edit Profile",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            key: _formKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Example: Edit first name
              // Example: Edit first name
              EditItem(
                title: "",
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Hero(
                        tag: "user_photo",
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            //border: Border.all(color: Colors.blueAccent.shade100, width: 10),
                            image: DecorationImage(
                              image: _pickedImage != null
                                  ? FileImage(_pickedImage!)
                                  : _image != null
                                  ? NetworkImage(_image!)
                                  : const AssetImage('assets/placeholder_image.jpg') as ImageProvider, // Provide the path to a placeholder image
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: const Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned(
                                  right: -3,
                                  bottom: 8,
                                  child:
                                  Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 50,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Text(
                      'Upload Image',
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              TextField(
                scrollPadding: const EdgeInsets.all(20),
                controller: _editedFirstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  labelStyle: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 20),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle_outlined),
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                ),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              // Example: Edit last name
              TextField(
                controller: _editedLastNameController,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                  labelStyle: TextStyle(color: Colors.blue,fontSize: 20,fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle_outlined),
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                ),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              // Example: Edit first name
              TextField(
                controller: _editedUserNameController,
                decoration: const InputDecoration(
                  labelText: "User Name",
                  labelStyle: TextStyle(color: Colors.blue,fontSize: 20,fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                ),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              // Example: Edit first name
              TextFormField(
                controller: _editedMobileController,
                decoration: const InputDecoration(
                  labelText: "Mobile",
                  labelStyle: TextStyle(color: Colors.blue,fontSize: 20,fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.mobile_friendly),
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                ),
                style: const TextStyle(fontSize: 20),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (value.length < 10) {
                    return 'Please enter a valid mobile number';
                  }
                  return null;
                },
              ),

              // ... add other fields for editing
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _updateUserProfile();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
