class StationModel {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final int availableSlots;
  final double pricePerHour;
  final String chargerType;

  StationModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.availableSlots,
    required this.pricePerHour,
    required this.chargerType,
  });

  factory StationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return StationModel(
      id: documentId,
      name: map['name'] ?? '',
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
      availableSlots: map['availableSlots']?.toInt() ?? 0,
      pricePerHour: (map['pricePerHour'] ?? 0.0).toDouble(),
      chargerType: map['chargerType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
      'availableSlots': availableSlots,
      'pricePerHour': pricePerHour,
      'chargerType': chargerType,
    };
  }
}
