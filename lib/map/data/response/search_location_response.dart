class SearchLocationResponse {
  SearchLocationResponse({
    required this.result,
  });

  final List<SearchLocationResult> result;

  factory SearchLocationResponse.fromJson(dynamic json) {
    return SearchLocationResponse(
      result: List<SearchLocationResult>.from(
          json.map((x) => SearchLocationResult.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "result": result.map((x) => x.toJson()).toList(),
      };
}

class SearchLocationResult {
  SearchLocationResult({
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.icon,
  });

  final double lat;
  final double lon;
  final String displayName;
  final String icon;

  factory SearchLocationResult.fromJson(Map<String, dynamic> json) {
    return SearchLocationResult(
      lat: double.parse(json["lat"] ?? "0.0"),
      lon: double.parse(json["lon"] ?? "0.0"),
      displayName: json["display_name"] ?? "",
      icon: json["icon"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lon": lon,
        "display_name": displayName,
        "icon": icon,
      };
}
