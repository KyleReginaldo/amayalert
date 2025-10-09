enum SearchResultType { post, alert, evacuation, activity }

class SearchResult {
  final String id;
  final SearchResultType type;
  final String title;
  final String description;
  final String subtitle;
  final Map<String, dynamic> metadata;

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.subtitle,
    required this.metadata,
  });

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      id: map['id'] ?? '',
      type: SearchResultType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SearchResultType.post,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subtitle: map['subtitle'] ?? '',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'subtitle': subtitle,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResult &&
        other.id == id &&
        other.type == type &&
        other.title == title &&
        other.description == description &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode {
    return Object.hash(id, type, title, description, subtitle);
  }

  @override
  String toString() {
    return 'SearchResult(id: $id, type: $type, title: $title, description: $description, subtitle: $subtitle)';
  }
}
