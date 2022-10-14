
class Reciept{
  final String assetId;
  final String fromId;
  final String toId;
  final String totalPrice;
  final String downPayment;
  final String releaseDate;
  final String timestamp;

  Reciept({required this.assetId, required this.fromId, required this.toId, required this.totalPrice, required this.downPayment, required this.releaseDate, required this.timestamp});

  factory Reciept.fromJson(Map<String, dynamic> json) {
    return Reciept(
      assetId: json['assetId'] as String,
      fromId: json['fromId'] as String,
      toId: json['toId'] as String,
      totalPrice: json['totalPrice'] as String,
      downPayment: json['downPayment'] as String,
      releaseDate: json['releaseDate'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}