class Post {
  final int id;
  final String type;
  final String title;
  final String description;
  final double quantity;
  final String unit;
  final String materialName;
  final String userName;
  final double lat;
  final double lng;

  double? distanceKm;

  Post({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.materialName,
    required this.userName,
    required this.lat,
    required this.lng,
    this.distanceKm,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      materialName: json['material']?['name'] ?? '',
      userName: json['user']?['name'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}