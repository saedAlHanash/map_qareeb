

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutePointsResult {
  List<LatLng>? points = [];
  double? distance = 0;
  double? duration = 0;
  LatLng? start = LatLng(0, 0);
  LatLng? end = LatLng(0, 0);

  RoutePointsResult({
    this.points,
    this.distance,
    this.duration,
    this.start,
    this.end,
  });
}
