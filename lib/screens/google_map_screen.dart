import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => GoogleMapScreenState();
}

class GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController mapController;

  final LatLng _center = LatLng(28.5821, 77.3109);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Center(
          child: Text(
            "Google Map",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated, // Callback when map is created
        initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
        mapType: MapType.normal,

        markers: {
          Marker(
            markerId: MarkerId("1"),
            position: LatLng(28.758314, 77.300537),
            infoWindow: InfoWindow(
              title: "Google HQ",
              snippet: "Mountain View",
            ),
            draggable: true,
            onDragEnd: (LatLng newPosition) {
              print("Marker moved to: $newPosition");
            },
          ),

          Marker(
            markerId: MarkerId("2"),
            position: LatLng(28.6481226, 77.0506123896381),
            infoWindow: InfoWindow(
              title: "Google HQ",
              snippet: "Mountain View",
            ),
            draggable: true,
            onDragEnd: (LatLng newPosition) {
              print("Marker moved to: $newPosition");
            },
          ),

          // customMarker(markerId: 2, lng: 28.5355, lat:),
        }, // Set of markers to show on the map
        polylines: {
          Polyline(
            polylineId: PolylineId("line1"),
            points: [
              LatLng(28.6481226, 77.0506123896381),
              LatLng(28.758314, 77.300537),
            ],
            color: Colors.red,
            width: 5,
          ),
        },
      ),
    );
  }
}
