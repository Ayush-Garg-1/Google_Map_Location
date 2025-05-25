import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../service/location_service.dart';
import '../utils/constants.dart';
import '../utils/custom_snackbar.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => GoogleMapScreenState();
}

class GoogleMapScreenState extends State<GoogleMapScreen> {
  bool isLoading = true;
  final Completer<GoogleMapController> mapController = Completer();
  final LocationService _locationService = LocationService();

  List<LatLng> _polylineCoordinates = [];
  final PolylinePoints _polylinePoints = PolylinePoints();
  LatLng? _currentLatLng;
  LatLng _destination_mohan_nagar = const LatLng(28.6728, 77.3863);
  LatLng _source_gol_chakkar = const LatLng(28.7387085, 77.3082886);
  Set<Marker> _markers = {}; // Set of markers to display on the map

  StreamSubscription<LatLng>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final hasPermission = await _locationService.checkPermission();
    // print("hasPermission $hasPermission");
    if (!hasPermission) {
      showCustomSnackbar(
        context: context,
        message: "Location permission is't granted",
      );
      return;
    }
    final currentLocation = await _locationService.getCurrentLocation();
    // print("currentLocation $currentLocation");
    if (currentLocation == null) return;
    setState(() {
      isLoading = false;
      _currentLatLng = currentLocation;
    });
    // Add a marker at the current location
    _addMarker(currentLocation, 'Current Location', id: 'current_location');
    // Add a marker at the destination location
    _addMarker(_destination_mohan_nagar, 'Destination Location');
    // Add a marker at the source location
    // _addMarker(_source_gol_chakkar, 'Source Location');
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(_currentLatLng!));
    _startLocationUpdates(); // Start location stream updates
    // await _getPolylinePoints();
    // Move camera to the current location
  }

  void _startLocationUpdates() {
    _locationSubscription = _locationService.locationStream.listen((
      LatLng newLocation,
    ) async {
      // print("newLocation $newLocation");
      setState(() {
        _currentLatLng = newLocation;
        _markers.removeWhere((m) => m.markerId.value == 'current_location');
        _addMarker(_currentLatLng!, 'Current Location', id: 'current_location');
      });

      final controller = await mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(newLocation));
    });
  }

  // must enable billing
  Future<void> _getPolylinePoints() async {
    try {
      // must enable billing for getRouteBetweenCoordinates
      late PolylineResult result;
      try {
        result = await _polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: googleApiKey,
          request: PolylineRequest(
            origin: PointLatLng(
              _currentLatLng!.latitude,
              _currentLatLng!.longitude,
            ),
            destination: PointLatLng(
              _destination_mohan_nagar.latitude,
              _destination_mohan_nagar.longitude,
            ),
            mode: TravelMode.driving,
          ),
        );
      } catch (e) {
        print("Error In getRouteBetweenCoordinates $e");
      }
      // print("**************************************************************");

      // print("_currentLatLng $_currentLatLng");
      // print("_destination_mohan_nagar $_destination_mohan_nagar");

      // print("_currentLatLng $_currentLatLng");
      // print("_destination_mohan_nagar $_destination_mohan_nagar");
      // print("**************************************************************");
      if (result.points.isNotEmpty) {
        _polylineCoordinates =
            result.points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();

        setState(() {});
      } else {
        print("Failed to fetch route: ${result.errorMessage}");
      }
    } catch (e) {
      print("Exception occurred: ${e.toString()}");
    }
  }

  // Function to add marker at the given LatLng
  void _addMarker(LatLng position, locationName, {id}) {
    final marker = Marker(
      markerId: MarkerId('${id ?? position}'),
      position: position,
      infoWindow: InfoWindow(title: locationName),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        // _showBottomSheet(position);
      },
    );

    setState(() {
      _markers.add(marker); // Add marker to the map
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Center(
          child: Text(
            "Live Map",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.orangeAccent),
              )
              : GoogleMap(
                onMapCreated:
                    (controller) => mapController.complete(
                      controller,
                    ), // Callback when map is created
                initialCameraPosition: CameraPosition(
                  target: _currentLatLng!,
                  zoom: 14.0,
                ),
                mapType: MapType.normal,
                myLocationEnabled: true,

                markers: _markers, // Set of markers to show on the map

                buildingsEnabled: true,

                // polylines: {
                //   Polyline(
                //     polylineId: const PolylineId("route"),
                //     points: _polylineCoordinates,
                //     color: Colors.blue,
                //     width: 5,
                //   ),
                // },
                //   // customMarker(markerId: 2, lng: 28.5355, lat:),
                // }, // Set of markers to show on the map
                polylines: {
                  Polyline(
                    polylineId: PolylineId("line1"),
                    points: [_currentLatLng!, _destination_mohan_nagar],
                    color: Colors.red,
                    width: 5,
                  ),
                },
              ),
    );
  }
}
