class Todo {
  Todo({
    required this.id,
    required this.description,
    this.completed = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  // from json method
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      description: json['description'],
      completed: json['completed'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  final String id;
  final String description;
  final bool completed;
  final DateTime updatedAt;

  // tojson method

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'completed': completed,
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  List<Object> get props => [id, description, completed, updatedAt];

  @override
  String toString() {
    return 'Todo(id: $id, description: $description, completed: $completed, updatedAt: $updatedAt)';
  }
}
