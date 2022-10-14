
class Transaction {
  final String assetId;
  final String fromId;
  final String toId;
  final String agree;
  final String balance;
  final String date;

  Transaction({required this.assetId, required this.fromId, required this.toId, required this.agree, required this.balance, required this.date});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      assetId: json['assetId'] as String,
      fromId: json['fromId'] as String,
      toId: json['toId'] as String,
      agree: json['agree'] as String,
      balance: json['balance'] as String,
      date: json['date'] as String,
    );
  }
}