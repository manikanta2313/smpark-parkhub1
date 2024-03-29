import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:smartparkin1/dateandtime.dart';
import 'package:smartparkin1/slot.dart';

class VehicleDetailsPage extends StatefulWidget {
  final double amountToPass;
  final String lotName;
  final DateTime reserved;
  final int hours;
  final String lotId;
  const VehicleDetailsPage({super.key, required this.amountToPass, required this.lotName,required this.reserved,required this.hours,required this.lotId});

  @override
  State<VehicleDetailsPage> createState() => VehicleDetailsPageState();
}

class VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final Logger logger = Logger();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> userVehicleDetails = [];

  String? vehicleType;
  String vehicleNumber = '';
  String licenseNumber = '';

  @override
  void initState() {
    super.initState();
    // Load user's vehicle details when the widget is first created
    loadUserVehicleDetails();
  }

  List<String> vehicleTypes = ['Car', 'Motorcycle', 'Truck', 'Auto'];

  // Function to add vehicle details to Firestore
  Future<void> addVehicleDetails(
      String vehicleType, String vehicleNumber, String licenseNumber) async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Use user.email as the document name
        String email = user.email ?? "";
        String documentName = sanitizeEmail(email);

        // Reference to the user's document
        DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('Vehicle Details').doc(documentName);

        // Add vehicle details to a subcollection named 'vehicleNumber'
        await userDocRef.collection('Vehicles').doc(vehicleNumber).set({
          'vehicleType': vehicleType,
          'vehicleNumber': vehicleNumber,
          'licenseNumber': licenseNumber,
        });

        // Log success or handle further logic
        logger.i('Vehicle details added successfully for user: $documentName');
      } else {
        // Handle the case where the user is not signed in
        logger.e('User not signed in. Cannot add vehicle details.');
      }
    } catch (e) {
      // Handle errors
      logger.e('Error adding vehicle details: $e');
    }
  }

  // Function to load user's vehicle details from Firestore
  Future<void> loadUserVehicleDetails() async {
    try {
      List<Map<String, dynamic>> details = await _getUserVehicleDetails();
      setState(() {
        userVehicleDetails.clear();
        userVehicleDetails.addAll(details); // Append new details to the existing list
      });
    } catch (e) {
      // Handle errors
      logger.i('Error loading user vehicle details: $e');
    }
  }

  // Function to get user's vehicle details from Firestore
  Future<List<Map<String, dynamic>>> _getUserVehicleDetails() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Use user.email as the document name
      String email = user.email ?? "";
      String documentName = sanitizeEmail(email);

      // Reference to the user's document
      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('Vehicle Details').doc(documentName);

      // Get all documents within the 'Vehicles' subcollection
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await userDocRef.collection('Vehicles').get(); // Use the correct subcollection name

      // Extract data from documents
      List<Map<String, dynamic>> vehicleDetailsList = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        // Fetch the details from each document
        Map<String, dynamic> vehicleDetails = doc.data();
        vehicleDetailsList.add(vehicleDetails);
      }

      return vehicleDetailsList;
    } else {
      throw Exception('User not signed in');
    }
  }

  // Function to sanitize email for Firestore document name
  String sanitizeEmail(String email) {
    // Replace special characters and use a hash function if needed
    return email.replaceAll(RegExp(r'[^\w\s]+'), '');
  }


  // Function to show bottom sheet for entering new vehicle details
  void _showVehicleDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const Text(
                    'Enter Vehicle Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildVehicleTypeDropdown(),
                  const SizedBox(height: 16),
                  _buildVehicleNumberField(),
                  const SizedBox(height: 16),
                  _buildLicenseNumberField(),
                  const SizedBox(height: 16),
                  _buildSaveButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to build the dropdown for vehicle types
  Widget _buildVehicleTypeDropdown() {
    return DropdownButtonFormField(
      value: vehicleType,
      items: vehicleTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            type,
            style: const TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          vehicleType = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Vehicle Type',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a vehicle type';
        }
        return null;
      },
    );
  }

  // Function to build the vehicle number text field
  Widget _buildVehicleNumberField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Vehicle Number',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      onChanged: (value) {
        setState(() {
          vehicleNumber = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter vehicle number';
        }
        return null;
      },
    );
  }

  // Function to build the license number text field
  Widget _buildLicenseNumberField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'License Number',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      onChanged: (value) {
        setState(() {
          licenseNumber = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter license number';
        }
        return null;
      },
    );
  }

  // Function to build the save button
  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              addVehicleDetails(vehicleType!, vehicleNumber, licenseNumber);
              Navigator.pop(context);
              loadUserVehicleDetails();
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 20,
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DateAndTime(lotName: '', lotId: '')),
        );
        // Return true to allow back navigation, return false to prevent it
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DateAndTime(lotName: '',lotId: '',),
                ),
              );
            },
            icon: const Icon(Ionicons.chevron_back_outline,color: Colors.white,),
          ),
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
            "Vehicle Details",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildYourVehiclesButton(),
              // Display containers for each saved vehicle
              for (Map<String, dynamic> vehicleDetails in userVehicleDetails)
                _buildVehicleCard(vehicleDetails),
              const SizedBox(height: 40,),
              _buildNewVehicleCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build the "Your Vehicles" button
  Widget _buildYourVehiclesButton() {
    return TextButton(
      onPressed: () {},
      child: const Text(
        'Your Vehicles',
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Function to build the vehicle card
  Widget _buildVehicleCard(Map<String, dynamic> vehicleDetails) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      color: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SelectSlotPage(
                    amountToPass: widget.amountToPass,
                    selectedVehicleType: vehicleDetails['vehicleType'] ?? 'car',
                    selectedVehicleNumber: vehicleDetails['vehicleNumber'],
                    reserved: widget.reserved,
                    lotName: widget.lotName,
                    hours: widget.hours,
                    lotId: widget.lotId,
                  )
              )
          );
        },
        child: ListTile(
          title: Text(
            'Vehicle Type: ${vehicleDetails['vehicleType']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle Number: ${vehicleDetails['vehicleNumber']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'License Number: ${vehicleDetails['licenseNumber']}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Function to build the "New Vehicle?" card
  Widget _buildNewVehicleCard() {
    return GestureDetector(
      onTap: () {
        _showVehicleDetailsBottomSheet(context);
      },
      child: Card(
        margin: const EdgeInsets.all(10.0),
        color: Colors.blueGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const ListTile(
          title: Text(
            'New Vehicle?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
