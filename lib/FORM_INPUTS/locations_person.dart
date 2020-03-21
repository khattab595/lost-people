//import 'dart:async';
//
//import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//
//
//
//class MapSample extends StatefulWidget {
//  @override
//  State<MapSample> createState() => MapSampleState();
//}
//
//class MapSampleState extends State<MapSample> {
//  Completer<GoogleMapController> _controller = Completer();
//
//  static final CameraPosition _kGooglePlex = CameraPosition(
//    target: LatLng(30.42796133580664, 31.085749655962),
//    zoom: 5.4746,
//  );
//
//  static final CameraPosition _kLake = CameraPosition(
//      bearing: 192.8334901395799,
//      target: LatLng(30.43296265331129,31.08832357078792),
//      tilt: 59.440717697143555,
//      zoom: 5.151926040649414);
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      body: GoogleMap(
//        onTap: (latlang){
//          print(latlang);
//        },
//        mapType: MapType.hybrid,
//        initialCameraPosition: _kGooglePlex,
//        onMapCreated: (GoogleMapController controller) {
//          _controller.complete(controller);
//        },
//      ),
//      floatingActionButton: FloatingActionButton.extended(
//        onPressed: _goToTheLake,
//        label: Text('To The location person!'),
//        icon: Icon(Icons.directions_boat),
//      ),
//    );
//  }
//
//  Future<void> _goToTheLake() async {
//    final GoogleMapController controller = await _controller.future;
//    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//  }
//}