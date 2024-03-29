
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:smartparkin1/slot.dart';
import 'package:upi_india/upi_india.dart';

import 'invoice.dart';

class PaymentScreen extends StatefulWidget {
  final double amountToPay;
  final String lotName;
  final DateTime reserved;
  final int hours;
  final String selectedVehicleType;
  final String selectedVehicleNumber;
  final String slot;
  final String lotId;
  const PaymentScreen({
    super.key,
    required this.amountToPay,
    required this.lotName,
    required this.reserved,
    required this.hours,
    required this.selectedVehicleType,
    required this.selectedVehicleNumber,
    required this.slot,
    required this.lotId
  });

  @override
  State<PaymentScreen> createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {

  final Logger logger = Logger();
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  String invoiceNumber = DateTime.now().millisecondsSinceEpoch.toString();


  TextStyle header = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "abhisheksam1289@okaxis",
      receiverName: 'M ABHISHEK',
      transactionRefId: invoiceNumber,
      transactionNote: 'Amount for parking',
      amount: widget.amountToPay,
    );
  }

  Widget displayUpiApps() {
    if (apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty) {
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    }
    else {
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            spacing: 50,
            runSpacing: 20,
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  _transaction = initiateTransaction(app);
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 20,right: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(height: 10,),
                      Text(
                          app.name,
                          textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException _:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException _:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException _:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException _:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
                body,
                style: value,
              )),
        ],
      ),
    );
  }

  Widget _buildInvoiceButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => InvoicePage(
                lot: widget.lotName,
                slot: widget.slot,
                reservedHours: widget.hours,
                reservedDate: widget.reserved,
                totalAmount: widget.amountToPay,
                vehicleType: widget.selectedVehicleType,
                vehicleNumber: widget.selectedVehicleNumber,
                lotId: widget.lotId,
              )
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: const Text('Invoice'),
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SelectSlotPage(
            amountToPass:0.0,
            selectedVehicleType: '',
            selectedVehicleNumber:'',
            reserved: DateTime(2004),
            lotName:'',
            hours: 0,
            lotId: '',
          ),),
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
                  builder: (context) => SelectSlotPage(
                    lotName: '',
                    reserved: DateTime(2004),
                    hours: 0,
                    selectedVehicleType: '',
                    selectedVehicleNumber: '',
                    amountToPass: 0.0,
                    lotId: '',
                  ),
                ),
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
            "Payments",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: displayUpiApps(),
            ),
            Expanded(
              child: FutureBuilder(
                future: _transaction,
                builder: (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          _upiErrorHandler(snapshot.error.runtimeType),
                          style: header,
                        ), // Print's text message on screen
                      );
                    }

                    // If we have data then definitely we will have UpiResponse.
                    // It cannot be null
                    UpiResponse upiResponse = snapshot.data!;

                    // Data in UpiResponse can be null. Check before printing
                    String txnId = upiResponse.transactionId ?? 'N/A';
                    String resCode = upiResponse.responseCode ?? 'N/A';
                    String txnRef = upiResponse.transactionRefId ?? 'N/A';
                    String status = upiResponse.status ?? 'N/A';
                    String approvalRef = upiResponse.approvalRefNo ?? 'N/A';
                    _checkTxnStatus(status);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          displayTransactionData('Transaction Id', txnId),
                          displayTransactionData('Response Code', resCode),
                          displayTransactionData('Reference Id', txnRef),
                          displayTransactionData('Status', status.toUpperCase()),
                          displayTransactionData('Approval No', approvalRef),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text(''),
                    );
                  }
                },
              ),
            ),
            Center(
              child: _buildInvoiceButton(),),
            const SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }
}
