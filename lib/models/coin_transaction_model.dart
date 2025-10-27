import '../utils/safe_parsing.dart';
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
      id: SafeParsing.getRequiredString(json, 'id'),
      userId: SafeParsing.getRequiredString(json, 'user_id'),
      amount: SafeParsing.getInt(json, 'amount', defaultValue: 0),
      type: SafeParsing.getOptionalString(json, 'type') ?? 'unknown',
      description: SafeParsing.getOptionalString(json, 'description') ?? '',
      createdAt: SafeParsing.parseDateTimeRequired(json['created_at']),
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



