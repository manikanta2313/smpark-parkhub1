// ignore_for_file: use_build_context_synchronously, file_names

import 'dart:async';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:smartparkin1/HomePage.dart';
import 'package:smartparkin1/dateandtime.dart';

class MapsPage extends StatefulWidget {

  const MapsPage({super.key});

  @override
  MapsPageState createState() => MapsPageState();
}

const kGoogleApiKey = 'AIzaSyCQCrWhfNM2AnegyOq4C6v9FxJeNPovA6M';
final Logger logger = Logger();

class MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  late GoogleMapController googleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(17.39587287558397, 78.62196950902965),
    zoom: 16,
  );

  Set<Marker> markersList = {};

  Future<void> fetchMarkersFromFirestoreForAllUsers() async {
    try {
      QuerySnapshot locationsSnapshot = await FirebaseFirestore.instance
          .collection('Lot Locations')
          .get();

      for (QueryDocumentSnapshot docSnapshot in locationsSnapshot.docs) {
        double latitude = docSnapshot['latitude'];
        double longitude = docSnapshot['longitude'];
        String name = docSnapshot['name'];
        String markerId = docSnapshot.id;

        markersList.add(
          Marker(
            markerId: MarkerId(markerId),
            position: LatLng(latitude, longitude),
            onTap: () {
              _showSlideUpModal(context, markerId, name);
            },
            infoWindow: InfoWindow(
              title: name,
            ),
          ),
        );
      }

      setState(() {});
    } catch (error) {
      logger.i('Error fetching markers from Firestore: $error');
    }
  }

  Future<Map<String, dynamic>> fetchSlotDetailsFromFirestore(String markerId) async {
    try {
      DocumentSnapshot lotDetailsSnapshot = await FirebaseFirestore.instance
          .collection('Lot Details')
          .doc(markerId)
          .get();

      if (lotDetailsSnapshot.exists) {
        return lotDetailsSnapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (error) {
      logger.i('Error fetching slot details from Firestore: $error');
      return {};
    }
  }

  Future<void> _showSlideUpModal(BuildContext context, String markerId, String userName) async {
    final localContext = context;

    Map<String, dynamic> slotDetails = await fetchSlotDetailsFromFirestore(markerId);

    String parkingLotDetailsText = userName;


    showModalBottomSheet(
      context: localContext,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 50.0,
                  backgroundImage: AssetImage('assets/images/lot_image.jpg'),
                ),
              ),
              const SizedBox(height: 25.0),
              Text(
                parkingLotDetailsText,
                style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 35.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(Icons.check_circle, 'Slots available', slotDetails['slotsAvailable'].toString(), Colors.green),
                  _buildInfoItem(Icons.event_busy, 'Slots booked', slotDetails['slotsBooked'].toString(), Colors.red),
                  _buildInfoItem(Icons.format_list_numbered, 'Total slots', slotDetails['totalSlots'].toString(), Colors.blue),
                ],
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>  DateAndTime(lotName: parkingLotDetailsText,lotId: markerId,)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120.0, 40.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32.0),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: const TextStyle(fontSize: 16.0, color: Colors.black),
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: Mode.overlay,
      language: 'en',
      strictbounds: false,
      types: [],
      components: [Component(Component.country, "IND")],
    );

    if (p != null) {
      displayPrediction(p, homeScaffoldKey.currentState as ScaffoldMessengerState?);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(homeScaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  Future<void> displayPrediction(Prediction p, ScaffoldMessengerState? messengerState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    markersList.clear();
    markersList.add(
      Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name),
      ),
    );
    setState(() {});

    final context = messengerState!.context;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(detail.result.name)));
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) {
      if (kDebugMode) {
        print("error$error");
      }
    });

    return await Geolocator.getCurrentPosition();
  }

  void loadLocation() {
    getUserCurrentLocation().then((value) async {
      if (kDebugMode) {
        print("My current location");
      }
      if (kDebugMode) {
        print("${value.latitude} ${value.longitude}");
      }
      markersList.add(
        Marker(
          markerId: const MarkerId("0"),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: const InfoWindow(title: "My Current Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
      CameraPosition cameraPosition = CameraPosition(
        zoom: 14,
        target: LatLng(value.latitude, value.longitude),
      );
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMarkersFromFirestoreForAllUsers();
    loadLocation();
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
        key: homeScaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
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
            "Maps",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            ElevatedButton(
              onPressed: _handlePressButton,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200.0, 10.0),
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Text("Search Parking Lots"),
            ),
          ],
        ),
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          markers: markersList,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            googleMapController = controller;
          },
        ),
      ),
    );
  }
}
