// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'HomePage.dart';
import 'signin.dart';
import 'theme_provider.dart';
import 'profile_page.dart';
import 'forward_button.dart';
import 'setting_item.dart';
import 'setting_switch.dart';
import 'package:ionicons/ionicons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {

  final Logger logger = Logger();

  void _logout(BuildContext context) async {
    try {
      // Sign out the user
      await FirebaseAuth.instance.signOut();

      // After signing out, navigate to the login page or any other page
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()));
    } catch (e) {
      logger.i('Error during logout: $e');
      // Handle errors, if any, during logout
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.watch<ThemeProvider>().themeMode == ThemeMode.dark;
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
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
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            icon: const Icon(Ionicons.chevron_back_outline,color: Colors.white,),
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
            "Settings",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfilePage())
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset('assets/images/avatar3.png', width: 55, height: 55),
                          const SizedBox(width: 20),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "User",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                          const Spacer(),
                          const ForwardButton()
                        ],
                      ),
                    )
                ),
                const SizedBox(height: 40),
                const Text(
                  "Preferences",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SettingItem(
                  title: "Language",
                  icon: Ionicons.earth,
                  bgColor: Colors.purple.shade100,
                  iconColor: Colors.purple,
                  value: "English",
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                SettingItem(
                  title: "Notifications",
                  icon: Ionicons.notifications,
                  bgColor: Colors.green.shade100,
                  iconColor: Colors.green,
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                SettingSwitch(
                  title: "Dark Mode",
                  icon: Ionicons.moon_sharp,
                  bgColor: Colors.black87,
                  iconColor: Colors.white,
                  value: isDarkMode,
                  onTap: (value) {
                    context.read<ThemeProvider>().setDarkMode(value);
                  },
                ),
                const SizedBox(height: 20),
                SettingItem(
                  title: "Help",
                  icon: Ionicons.help,
                  bgColor: Colors.red.shade100,
                  iconColor: Colors.red,
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text("Logout"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
