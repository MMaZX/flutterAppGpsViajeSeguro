class MapBoxRetrieveV2 {
  String type;
  List<Feature> features;
  String attribution;

  MapBoxRetrieveV2({
    required this.type,
    required this.features,
    required this.attribution,
  });

  factory MapBoxRetrieveV2.fromJson(Map<String, dynamic> json) =>
      MapBoxRetrieveV2(
        type: json["type"],
        features: List<Feature>.from(
            json["features"].map((x) => Feature.fromJson(x))),
        attribution: json["attribution"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "features": List<dynamic>.from(features.map((x) => x.toJson())),
        "attribution": attribution,
      };

  factory MapBoxRetrieveV2.fromDefault() {
    return MapBoxRetrieveV2(type: "null", features: [], attribution: "null");
  }
}

class Feature {
  String type;
  String id;
  Geometry geometry;
  Properties properties;

  Feature({
    required this.type,
    required this.id,
    required this.geometry,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Feature(
        type: "",
        id: "",
        geometry: Geometry(type: "", coordinates: []),
        properties: Properties(
          mapboxId: "",
          featureType: "",
          fullAddress: "",
          name: "",
          namePreferred: "",
          coordinates: Coordinates(longitude: 0, latitude: 0),
        ),
      );
    }

    return Feature(
      type: json["type"],
      id: json["id"],
      geometry: Geometry.fromJson(json["geometry"]),
      properties: Properties.fromJson(json["properties"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        "geometry": geometry.toJson(),
        "properties": properties.toJson(),
      };
}

class Geometry {
  String type;
  List<double> coordinates;

  Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json["type"],
        coordinates:
            List<double>.from(json["coordinates"].map((x) => x.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
      };
}

class Properties {
  String mapboxId;
  String featureType;
  String fullAddress;
  String name;
  String namePreferred;
  Coordinates coordinates;

  Properties({
    required this.mapboxId,
    required this.featureType,
    required this.fullAddress,
    required this.name,
    required this.namePreferred,
    required this.coordinates,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        mapboxId: json["mapbox_id"],
        featureType: json["feature_type"],
        fullAddress: json["full_address"],
        name: json["name"],
        namePreferred: json["name_preferred"],
        coordinates: Coordinates.fromJson(json["coordinates"]),
      );

  Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "feature_type": featureType,
        "full_address": fullAddress,
        "name": name,
        "name_preferred": namePreferred,
        "coordinates": coordinates.toJson(),
      };
}

class Coordinates {
  final double longitude;
  final double latitude;

  Coordinates({
    required this.longitude,
    required this.latitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
        longitude: json["longitude"].toDouble(),
        latitude: json["latitude"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "longitude": longitude,
        "latitude": latitude,
      };
}
