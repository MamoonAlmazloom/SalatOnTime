/// The user's chosen mosque: a named pin on the map.
class Mosque {
  final String name;
  final double latitude;
  final double longitude;

  const Mosque({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Mosque.fromJson(Map<String, dynamic> json) => Mosque(
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}
