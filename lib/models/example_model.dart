// ============================================================================
// EXAMPLE MODEL
// Replace with your own models
// ============================================================================

/// Example model class - replace with your own
class ExampleModel {
  final String id;
  final String name;
  final DateTime createdAt;

  const ExampleModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  ExampleModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return ExampleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from Map (JSON deserialization)
  factory ExampleModel.fromMap(Map<String, dynamic> map) {
    return ExampleModel(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
