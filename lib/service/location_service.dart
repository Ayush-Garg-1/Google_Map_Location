import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Future<bool> checkPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();

      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();

      if (permissionGranted != PermissionStatus.granted) return false;
    }
    // ## You should only call enableBackgroundMode(true) (used to fetch location in background) after ensuring both:
    // # location (foreground) permission is granted
    // # locationAlways (background) permission is granted
    // await _location.enableBackgroundMode(enable: true);
    return true;
  }

  Future<LatLng?> getCurrentLocation() async {
    final locationData = await _location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      return LatLng(locationData.latitude!, locationData.longitude!);
    }
    return null;
  }

  Stream<LatLng> get locationStream {
    return _location.onLocationChanged.map((locationData) {
      return LatLng(locationData.latitude!, locationData.longitude!);
    });
  }
}
