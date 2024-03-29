import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartparkin1/MapsPage.dart';
import 'package:smartparkin1/barrier_page.dart';
import 'settings_page.dart';
import 'mybookings.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  late TextEditingController _userNameController;
  late String? _image;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
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
          _userNameController.text = userDoc['userName'].toString();
          _image = userDoc['profilePicture'];
        });
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        // Return true to allow back navigation, return false to prevent it
        return false;
      },
      child: Scaffold(
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
                      const SizedBox(height: 60),
                      Row(
                        children: [
                          const SizedBox(width: 30,),
                          Hero(
                            tag: "user_photo",
                            child: Material(
                              color: Colors.transparent,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white, // Add a background color
                                foregroundColor: Colors.blue, // Add a border color
                                child: CircleAvatar(
                                  radius: 48, // Adjust the inner circle size to add a border effect
                                  backgroundImage: _image != null ? NetworkImage(_image!) : const AssetImage('assets/images/avatar3.png') as ImageProvider,


                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20), // Add some horizontal space here
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hello,',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                              ),

                              const SizedBox(height: 5), // Add some vertical space between "Hello" and the name
                              Text(
                                '    ${_userNameController.text}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                            ],
                          ),
                        ],
                      ),

                    ],
                  ),
                )
            ),
            // White Container with Rounded Edges
            Positioned(
              top: 200.0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                      ),
                      buildGestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MapsPage()),
                          );
                        },
                        imageAsset: 'assets/images/ReserveParkingSpace.jpg',
                        title: 'Reserve a parking space',
                        trailingIcon: Icons.arrow_forward_ios_rounded,
                      ),
                      buildGestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MyBookingsPage()),
                          );
                        },
                        imageAsset: 'assets/images/MyBookings.png',
                        title: 'My Bookings',
                        trailingIcon: Icons.arrow_forward_ios_rounded,
                      ),
                      buildGestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsPage()),
                          );
                        },
                        imageAsset: 'assets/images/settingsIcon.png',
                        title: 'Settings',
                        trailingIcon: Icons.arrow_forward_ios_sharp,
                      ),
                      buildGestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Barrier()),
                          );
                        },
                        imageAsset: 'assets/images/parklio.jpg',
                        title: 'Animation',
                        trailingIcon: Icons.arrow_forward_ios_sharp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildGestureDetector({
    required VoidCallback onTap,
    required String imageAsset,
    required String title,
    required IconData trailingIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 3.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 4,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              imageAsset,
              width: 100,
              height: 100.0,
            ),
            ListTile(
              title: Text(title),
              trailing: Icon(trailingIcon),
            ),
          ],
        ),
      ),
    );
  }
}
