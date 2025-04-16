import 'package:google_maps_flutter/google_maps_flutter.dart';

customMarker({required markerId, lat, lng, onTap}) {
  return Marker(
    markerId: MarkerId(markerId.toString()),
    position: LatLng(lat, lng),
    infoWindow: InfoWindow(title: "Google HQ", snippet: "Mountain View"),

    onTap: () {
      if (onTap != null) {
        onTap();
      }
    },
  );
}
