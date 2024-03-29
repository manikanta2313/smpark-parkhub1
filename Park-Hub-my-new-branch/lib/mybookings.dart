import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'HomePage.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  MyBookingsPageState createState() => MyBookingsPageState();
}

class MyBookingsPageState extends State<MyBookingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
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
            "My Bookings",
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: const [
              Tab(text: 'In Progress'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent('In Progress'),
                  _buildTabContent('Upcoming'),
                  _buildTabContent('Past'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<Map<String, dynamic>>> _buildTabContent(String tabTitle) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getBookingDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Map<String, dynamic>> bookingsList = snapshot.data ?? [];
          if (bookingsList.isEmpty) {
            return Center(child: Text('No invoices for $tabTitle'));
          } else {
            List<Map<String, dynamic>> filteredBookings = _filterBookingsByTab(bookingsList, tabTitle);
            if (filteredBookings.isEmpty) {
              return Center(child: Text('No invoices for $tabTitle'));
            } else {
              return ListView.builder(
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  var invoiceData = filteredBookings[index];
                  return _buildInvoiceCard(invoiceData);
                },
              );
            }
          }
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getBookingDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email ?? "";
      String documentName = sanitizeEmail(email);

      DocumentReference userDocRef = FirebaseFirestore.instance.collection('Invoice').doc(documentName);

      QuerySnapshot<Map<String, dynamic>> snapshot = await userDocRef.collection('Invoices').get();

      List<Map<String, dynamic>> bookingsList = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        Map<String, dynamic> bookingDetails = doc.data();

        // Parse the date and time strings to create DateTime objects
        bookingDetails['reservedDateTime'] =
            _parseDateAndTime(bookingDetails['reservedDate'], bookingDetails['reservedTime']);

        bookingsList.add(bookingDetails);
      }

      // Sort the bookingsList based on the logic
      bookingsList.sort((a, b) {
        DateTime aTime = a['reservedDateTime'];
        DateTime bTime = b['reservedDateTime'];
        return aTime.compareTo(bTime);
      });

      return bookingsList;
    } else {
      throw Exception('User not signed in');
    }
  }

  DateTime _parseDateAndTime(String date, String time) {
    String dateString = '$date $time';
    final dateFormat = DateFormat("dd-MM-yyyy HH:mm");
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      print("Error parsing date string: $dateString");
      print("Error details: $e");
      // Handle the error or return a default value
      return DateTime.now();
    }
  }


  List<Map<String, dynamic>> _filterBookingsByTab(
      List<Map<String, dynamic>> bookingsList, String tabTitle) {
    DateTime now = DateTime.now();

    return bookingsList.where((invoiceData) {
      DateTime reservedTime = invoiceData['reservedDateTime'];
      String reservedHours = invoiceData['reservedHours'].toString(); // Treat as String
      int parsedReservedHours = int.parse(reservedHours);

      DateTime reservedEndTime = reservedTime.add(Duration(hours: parsedReservedHours));

      if (tabTitle == 'Past' && reservedEndTime.isBefore(now)) {
        return true;
      } else if (tabTitle == 'In Progress' &&
          reservedTime.isBefore(now) &&
          reservedEndTime.isAfter(now)) {
        return true;
      } else if (tabTitle == 'Upcoming' && reservedTime.isAfter(now)) {
        return true;
      }

      return false;
    }).toList();
  }






  Future<void> _showInvoiceDialog(Map<String, dynamic> invoiceData) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.indigo.shade200, Colors.indigo.shade100],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle('Invoice Details'),
                  const SizedBox(height: 10),
                  _buildInfoRow('Invoice Number', '#${invoiceData['invoiceNumber']}'),
                  _buildInfoRow('Date', invoiceData['date']),
                  _buildInfoRow('Time', invoiceData['time']),
                  const SizedBox(height: 10,),
                  _buildTitle('Reservation Details'),
                  const SizedBox(height: 10),
                  _buildInvoiceDetails(invoiceData),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey),
                  _buildTotalAmount(invoiceData),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontStyle: FontStyle.italic,fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails(Map<String, dynamic> invoiceData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Lot', invoiceData['lotName'], Icons.local_parking),
        _buildDetailRow('Slot', invoiceData['slotName'], Icons.directions_car),
        _buildDetailRow('Reserved Hours', invoiceData['reservedHours'].toString(), Icons.access_time),
        _buildDetailRow('Reserved Date', invoiceData['reservedDate'], Icons.calendar_today),
        _buildDetailRow('Reserved Time', invoiceData['reservedTime'], Icons.timer_outlined),
        _buildDetailRow('Vehicle Type', invoiceData['vehicleType'], Icons.directions_car),
        _buildDetailRow('Vehicle Number', invoiceData['vehicleNumber'], Icons.confirmation_number),
        _buildDetailRow('Customer Name', invoiceData['customerName'], Icons.person),
        _buildDetailRow('Mobile', invoiceData['mobile'], Icons.phone),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmount(Map<String, dynamic> invoiceData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Total Amount:',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        const SizedBox(height: 10),
        Text(
          invoiceData['amount'].toString(),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ],
    );
  }



  Widget _buildInvoiceCard(Map<String, dynamic> invoiceData) {
    return GestureDetector(
      onTap: () {
        _showInvoiceDialog(invoiceData);
        // showing full invoice card
      },
      child: Card(
        color: Colors.green.shade500,
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(invoiceData['lotName'] ?? '',style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
          subtitle: Text('Invoice Number: ${invoiceData['invoiceNumber']}',style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w600),),
        ),
      ),
    );
  }

  String sanitizeEmail(String email) {
    return email.replaceAll(RegExp(r'[^\w\s]+'), '');
  }


}
