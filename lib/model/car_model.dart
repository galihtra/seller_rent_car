class CarModel {
  final String id;
  final String name;
  final String type;
  late String imageUrl;
  final String passengerCount;
  final int price;
  final int maksPassenger;
  final int createdYear;
  final int maksTrunk;
  final String detail;

  CarModel(
      this.id,
      this.name,
      this.type,
      this.imageUrl,
      this.passengerCount,
      this.price,
      this.maksPassenger,
      this.createdYear,
      this.maksTrunk,
      this.detail);

  CarModel.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String,
        name = map['name'] as String,
        type = map['type'] as String,
        imageUrl = map['imageUrl'] as String,
        passengerCount = map['passengerCount'] as String,
        price = map['price'] as int,
        maksPassenger = map['maksPassenger'] as int,
        createdYear = map['createdYear'] as int,
        maksTrunk = map['maksTrunk'] as int,
        detail = map['detail'] as String;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'imageUrl': imageUrl,
      'passengerCount': passengerCount,
      'price': price,
      'maksPassenger': maksPassenger,
      'createdYear': createdYear,
      'maksTrunk': maksTrunk,
      'detail': detail,
    };
  }
}
