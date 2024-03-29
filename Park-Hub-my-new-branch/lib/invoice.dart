import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:smartparkin1/HomePage.dart';
import 'package:smartparkin1/payment_page.dart';
import 'dart:math';


class InvoicePage extends StatefulWidget {
  final String lot;
  final String slot;
  final int reservedHours;
  final DateTime reservedDate;
  final double totalAmount;
  final String vehicleType;
  final String vehicleNumber;
  final String lotId;

  const InvoicePage({
    super.key,
    required this.lot,
    required this.slot,
    required this.reservedHours,
    required this.reservedDate,
    required this.totalAmount,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.lotId,
  });

  @override
  InvoicePageState createState() => InvoicePageState();
}

class InvoicePageState extends State<InvoicePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _currentUser;
  Logger logger = Logger();

  String customerName = '';
  String mobile = '';
  String invoiceNumber = Random().nextInt(99999999).toString() ;


  @override
  void initState() {
    super.initState();
    customerName = '';
    mobile = '';
    // Fetch user details from Firestore when the screen is initialized
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      getDocId(_currentUser!.email!);
    }
  }

  String sanitizeEmail(String email) {
    // Replace special characters and use a hash function if needed
    return email.replaceAll(RegExp(r'[^\w\s]+'), '');
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
          customerName = userDoc['firstName'] + userDoc['lastName'];
          mobile = userDoc['mobileNumber'];

        });
      }
    } catch (error) {
      logger.i('Error fetching user details: $error');
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PaymentScreen(
            amountToPay: 0.0,
            selectedVehicleType:'',
            selectedVehicleNumber: '',
            hours: 0,
            reserved:DateTime(2004),
            lotName:'',
            slot: '',
            lotId: '',
          ),
          ),
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
                  MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        amountToPay: 0.0,
                        lotName: '',
                        reserved: DateTime(2004),
                        hours: 0,
                        selectedVehicleType: '',
                        selectedVehicleNumber: '',
                        slot: '',
                        lotId: '',
                      )
                  ),
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
              "Invoice",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.indigo.shade200, Colors.indigo.shade100],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 5,
                    shadowColor: Colors.black,
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice #$invoiceNumber',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                              style: const TextStyle(fontSize: 16, color: Colors.blueAccent,fontWeight: FontWeight.bold),
                            ),const SizedBox(height: 10),
                            Text(
                              'Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
                              style: const TextStyle(fontSize: 16, color: Colors.blueAccent,fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            buildInvoiceDetails(),
                            const SizedBox(height: 20),
                            const Divider(color: Colors.grey),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildTotalAmount(),
                                const SizedBox(width: 100,),
                                ElevatedButton(
                                  onPressed: () {
                                    _saveInvoice();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const HomePage()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  child: const Text("Save"),
                                ),

                              ],
                            ),
                          ]
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
    );

  }

  Future<void> _saveInvoice() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Use user.email as the document name
        String email = user.email ?? "";
        String documentName = sanitizeEmail(email);

        // Reference to the user's document
        DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('Invoice').doc(documentName);

        // Add invoice details to a subcollection named 'invoiceNumber'
        if (widget.lot!="") {
          await userDocRef.collection('Invoices').doc(invoiceNumber).set({
            'invoiceNumber': invoiceNumber,
            'date': DateFormat('dd-MM-yyyy').format(DateTime.now()),
            'time': DateFormat('hh:mm a').format(DateTime.now()),
            'lotName': widget.lot,
            'slotName': widget.slot,
            'reservedHours': widget.reservedHours,
            'reservedDate': DateFormat('dd-MM-yyyy').format(
                widget.reservedDate),
            'reservedTime': DateFormat('hh:mm a').format(widget.reservedDate),
            'amount': widget.totalAmount,
            'vehicleType': widget.vehicleType,
            'vehicleNumber': widget.vehicleNumber,
            'customerName': customerName,
            'mobile': mobile,
          });
        }
        // Update slot details
        await updateSlotDetails(widget.lotId);

        logger.i('Invoice saved successfully for user: $documentName');
      } else {
        logger.e('User not signed in. Cannot save invoice.');
      }
    } catch (e) {
      logger.e('Error saving invoice: $e');
    }
  }


  Future<void> updateSlotDetails(String lotId) async {
    try {
      // Reference to the lot document
      DocumentReference lotDocRef =
      FirebaseFirestore.instance.collection('Lot Details').doc(lotId);

      // Check if the document exists
      bool lotDocExists = (await lotDocRef.get()).exists;

      if (lotDocExists) {
        // Get the current slot details
        DocumentSnapshot lotDoc = await lotDocRef.get();
        int slotsBooked = lotDoc['slotsBooked'];
        int slotsAvailable = lotDoc['slotsAvailable'];

        // Update the slot details
        await lotDocRef.update({
          'slotsBooked': slotsBooked + 1,
          'slotsAvailable': slotsAvailable - 1,
        });

        logger.i('Slot details updated successfully for lot ID: $lotId');
      } else {
        logger.e('Lot document does not exist for lot ID: $lotId');
      }
    } catch (e) {
      logger.e('Error updating slot details: $e');
    }
  }



  Widget buildInvoiceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reservation Details',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        buildDetailRow('Lot', widget.lot, Icons.local_parking),
        buildDetailRow('Slot', widget.slot, Icons.directions_car),
        buildDetailRow('Reserved Hours', widget.reservedHours.toString(), Icons.access_time),
        buildDetailRow('Reserved Date', DateFormat('dd-MM-yyyy').format(widget.reservedDate), Icons.calendar_today),
        buildDetailRow('Reserved Time', DateFormat('hh:mm a').format(widget.reservedDate), Icons.timer_outlined),
        buildDetailRow('Vehicle Type', widget.vehicleType, Icons.directions_car),
        buildDetailRow('Vehicle Number', widget.vehicleNumber, Icons.confirmation_number),
        buildDetailRow('Customer Name', customerName, Icons.person),
        buildDetailRow('Mobile', mobile, Icons.phone),

      ],
    );
  }

  Widget buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.indigo),
              const SizedBox(width: 4),
              Text(
                '$label:',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(width: 8), // Adjust the width as needed
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }



  Widget buildTotalAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Total Amount:',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          widget.totalAmount.toString(),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ],
    );
  }
}