class DiaryEntry {
  final String id;
  String title;
  String content;
  DateTime date;
  String mood; // Joyful, Calm, Cozy, Reflective, Grateful
  String moodEmoji;
  String? imageUrl;
  List<String> tags;
  bool isFavorite;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.moodEmoji,
    this.imageUrl,
    this.tags = const [],
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'date': date.toIso8601String(),
        'mood': mood,
        'moodEmoji': moodEmoji,
        'imageUrl': imageUrl,
        'tags': tags,
        'isFavorite': isFavorite,
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        date: DateTime.parse(json['date'] as String),
        mood: json['mood'] as String,
        moodEmoji: json['moodEmoji'] as String,
        imageUrl: json['imageUrl'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}
