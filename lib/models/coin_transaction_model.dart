class CoinTransactionModel {
  final String id;
  final String userId;
  final int amount;
  final String type; // 'earned', 'spent', 'purchased'
  final String description;
  final DateTime createdAt;

  CoinTransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory CoinTransactionModel.fromJson(Map<String, dynamic> json) {
    return CoinTransactionModel(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'],
      type: json['type'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}



