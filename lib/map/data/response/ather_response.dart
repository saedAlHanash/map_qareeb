import 'package:latlong2/latlong.dart';

class AtherResponse {
  AtherResponse({
    required this.imes,
  });

  final List<Ime> imes;

  factory AtherResponse.fromJson(Map<String, dynamic> json, List<String> ime) {
    return AtherResponse(
      imes: ime
          .map(
            (e) => Ime.fromJson(json[e] ?? {})..ime = e,
          )
          .toList(),
    );
  }
}

class Ime {
  Ime({
    required this.name,
    required this.dtServer,
    required this.dtTracker,
    required this.lat,
    required this.lng,
    required this.altitude,
    required this.angle,
    required this.speed,
    required this.locValid,
  });

  final String name;
  final DateTime? dtServer;
  final DateTime? dtTracker;
  final double lat;
  final double lng;
  final String altitude;
  final double angle;
  final String speed;
  final String locValid;
  String ime = '';

  LatLng getLatLng() => LatLng(lat, lng);

  factory Ime.fromJson(Map<String, dynamic> json) {
    return Ime(
      name: json["name"] ?? "",
      dtServer: DateTime.tryParse(json["dt_server"] ?? ""),
      dtTracker: DateTime.tryParse(json["dt_tracker"] ?? ""),
      lat: double.parse(json["lat"] ?? '0.0'),
      lng: double.parse(json["lng"] ?? '0.0'),
      altitude: json["altitude"] ?? "",
      angle: double.parse(json["angle"] ?? '0.0'),
      speed: json["speed"] ?? "",
      locValid: json["loc_valid"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "dt_server": dtServer?.toIso8601String(),
        "dt_tracker": dtTracker?.toIso8601String(),
        "lat": lat,
        "lng": lng,
        "altitude": altitude,
        "angle": angle,
        "speed": speed,
        "loc_valid": locValid,
      };
}
