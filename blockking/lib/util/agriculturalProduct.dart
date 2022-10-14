class AgriculturalProducts {
  final String id;
  final String title;
  final String kind;
  final String type;
  final String area;
  final String location;
  final String method;
  final String departureDate;
  final String price;
  final String date;
  final String userId;
  final String totalPrice;
  bool onSale = true;

  AgriculturalProducts({required this.id, required this.title, required this.kind, required this.type, required this.area, required this.location, required this.method, required this.departureDate, required this.price, required this.date, required this.userId, required this.totalPrice});

  factory AgriculturalProducts.fromJson(Map<String, dynamic> json) {
    return AgriculturalProducts(
      id: json['id'] as String,
      title: json['title'] as String,
      kind: json['kind'] as String,
      type: json['type'] as String,
      area: json['area'] as String,
      location: json['location'] as String,
      method: json['method'] as String,
      departureDate: json['departureDate'] as String,
      price: json['price'] as String,
      date: json['date'] as String,
      userId: json['userId'] as String,
      totalPrice: json['totalPrice'] as String,
    );
  }
}