class CarModel {
  final String name;
  final String type;
  final String imageUrl;

  CarModel(this.name, this.type, this.imageUrl);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'imageUrl': imageUrl,
    };
  }
}