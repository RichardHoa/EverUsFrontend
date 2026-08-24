class DeepTalkCard {
  final String id;
  final String topic;
  final String category;
  final String icon;
  final String text;

  const DeepTalkCard({
    required this.id,
    required this.topic,
    required this.category,
    required this.icon,
    required this.text,
  });

  factory DeepTalkCard.fromMap(Map<String, dynamic> map) {
    return DeepTalkCard(
      id: map['id'] as String? ?? '',
      topic: map['topic'] as String? ?? '',
      category: map['category'] as String? ?? '',
      icon: map['icon'] as String? ?? '♡',
      text: map['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic': topic,
      'category': category,
      'icon': icon,
      'text': text,
    };
  }
}
