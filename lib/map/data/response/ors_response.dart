class OrsResponse {
  OrsResponse({
    required this.features,
  });

  final List<Feature> features;

  factory OrsResponse.fromJson(Map<String, dynamic> json) {
    return OrsResponse(
      features: json["features"] == null
          ? []
          : List<Feature>.from(
              json["features"]!.map((x) => Feature.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "features": features.map((x) => x.toJson()).toList(),
      };
}

class Feature {
  Feature({
    required this.properties,
    required this.geometry,
  });

  final Properties properties;
  final Geometry geometry;

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      properties: json["properties"] == null
          ? Properties.fromJson({})
          : Properties.fromJson(json["properties"]),
      geometry: json["geometry"] == null
          ? Geometry.fromJson({})
          : Geometry.fromJson(json["geometry"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "properties": properties.toJson(),
        "geometry": geometry.toJson(),
      };
}

class Geometry {
  Geometry({required this.coordinates});

  final List<List<double>> coordinates;

  factory Geometry.fromJson(Map<String, dynamic> json) {
    Geometry item;

    var b1 = json["coordinates"] as List;
    if (b1.isNotEmpty) {
      var g = b1[0] is List;
      if (!g) return Geometry(coordinates: []);
    }

    item = Geometry(
      coordinates: json["coordinates"] == null
          ? []
          : List<List<double>>.from(json["coordinates"]!.map(
              (x) => x == null ? [] : List<double>.from(x!.map((x) => x)))),
    );

    return item;
  }

  Map<String, dynamic> toJson() => {
        "coordinates":
            coordinates.map((x) => x.map((x) => x).toList()).toList(),
      };
}

class Properties {
  Properties({
    required this.summary,
    required this.name,
  });

  final Summary summary;
  final String name;

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      name: json['name'] ?? '',
      summary: json["summary"] == null
          ? Summary.fromJson({})
          : Summary.fromJson(json["summary"]),
    );
  }

  Map<String, dynamic> toJson() => {"summary": summary.toJson(), 'name': name};
}

class Summary {
  Summary({
    required this.distance,
    required this.duration,
  });

  final double distance;
  final double duration;

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      distance: json["distance"] ?? 0.0,
      duration: json["duration"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "distance": distance,
        "duration": duration,
      };
}
