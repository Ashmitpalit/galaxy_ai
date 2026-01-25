import 'photo_model.dart';

class BoardModel {
  final String id;
  final String name;
  final List<String> pinIds; // Store photo IDs instead of full objects
  final DateTime createdAt;

  BoardModel({
    required this.id,
    required this.name,
    required this.pinIds,
    required this.createdAt,
  });

  // Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pinIds': pinIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      pinIds: List<String>.from(json['pinIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Copy with method for updates
  BoardModel copyWith({
    String? id,
    String? name,
    List<String>? pinIds,
    DateTime? createdAt,
  }) {
    return BoardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pinIds: pinIds ?? this.pinIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
