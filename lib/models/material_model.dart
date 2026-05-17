class CompostMaterial {
  final int id;
  final String name;
  final String description;
  final String icon;

  CompostMaterial({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory CompostMaterial.fromJson(Map<String, dynamic> json) {
    return CompostMaterial(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}