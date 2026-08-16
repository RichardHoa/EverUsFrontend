import 'dart:convert';

/// Represents a single reflection session / card
class ReflectionItem {
  final String id;
  final String title;
  final String situation;
  final String emotions;
  final String underlyingNeed;
  final String relatedPattern;
  final String whatHappened;
  final String whatInterpreted;
  final String aiPerspective;
  final String draftedMessage;
  final DateTime createdAt;
  final String actionTaken; // 'private' | 'shared' | 'pending'
  final bool isBookmarked;
  final List<ReflectionChatMessage>? chatHistory;

  ReflectionItem({
    required this.id,
    required this.title,
    required this.situation,
    required this.emotions,
    required this.underlyingNeed,
    required this.relatedPattern,
    required this.whatHappened,
    required this.whatInterpreted,
    required this.aiPerspective,
    required this.draftedMessage,
    required this.createdAt,
    this.actionTaken = 'private',
    this.isBookmarked = false,
    this.chatHistory,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'situation': situation,
      'emotions': emotions,
      'underlyingNeed': underlyingNeed,
      'relatedPattern': relatedPattern,
      'whatHappened': whatHappened,
      'whatInterpreted': whatInterpreted,
      'aiPerspective': aiPerspective,
      'draftedMessage': draftedMessage,
      'createdAt': createdAt.toIso8601String(),
      'actionTaken': actionTaken,
      'isBookmarked': isBookmarked,
      'chatHistory': chatHistory?.map((e) => e.toMap()).toList(),
    };
  }

  factory ReflectionItem.fromMap(Map<String, dynamic> map) {
    return ReflectionItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      situation: map['situation'] ?? '',
      emotions: map['emotions'] ?? '',
      underlyingNeed: map['underlyingNeed'] ?? '',
      relatedPattern: map['relatedPattern'] ?? '',
      whatHappened: map['whatHappened'] ?? '',
      whatInterpreted: map['whatInterpreted'] ?? '',
      aiPerspective: map['aiPerspective'] ?? '',
      draftedMessage: map['draftedMessage'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      actionTaken: map['actionTaken'] ?? 'private',
      isBookmarked: map['isBookmarked'] ?? false,
      chatHistory: map['chatHistory'] != null
          ? (map['chatHistory'] as List<dynamic>)
              .map((e) =>
                  ReflectionChatMessage.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReflectionItem.fromJson(String source) =>
      ReflectionItem.fromMap(json.decode(source));
}

/// Dynamic memory patterns recognized by EverUs
class MemoryPattern {
  final String id;
  final String trigger;
  final String description;
  final double confidence; // 0.0 to 1.0
  final int count;
  final DateTime lastObserved;

  MemoryPattern({
    required this.id,
    required this.trigger,
    required this.description,
    required this.confidence,
    required this.count,
    required this.lastObserved,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trigger': trigger,
      'description': description,
      'confidence': confidence,
      'count': count,
      'lastObserved': lastObserved.toIso8601String(),
    };
  }

  factory MemoryPattern.fromMap(Map<String, dynamic> map) {
    return MemoryPattern(
      id: map['id'] ?? '',
      trigger: map['trigger'] ?? '',
      description: map['description'] ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.8,
      count: (map['count'] as num?)?.toInt() ?? 1,
      lastObserved: map['lastObserved'] != null
          ? DateTime.tryParse(map['lastObserved']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Mutual safe insights for the "Us" (Chúng mình) tab
class SharedRelationshipInsight {
  final String id;
  final String title;
  final String triggerScenario;
  final String dynamicExplanation;
  final String communicationLoop;
  final List<String> helpfulTips;
  final String reflectionQuestion;

  SharedRelationshipInsight({
    required this.id,
    required this.title,
    required this.triggerScenario,
    required this.dynamicExplanation,
    required this.communicationLoop,
    required this.helpfulTips,
    required this.reflectionQuestion,
  });
}

/// Chat message types for the layered reflection conversation
enum MessageType {
  user,
  ai,
  memoryRecall,
  perspectiveReframing,
  summaryReady,
}

class ReflectionChatMessage {
  final String id;
  final MessageType type;
  final String content;
  final List<String> quickOptions;
  final String? selectedOption;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ReflectionChatMessage({
    required this.id,
    required this.type,
    required this.content,
    this.quickOptions = const [],
    this.selectedOption,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  ReflectionChatMessage copyWith({
    String? selectedOption,
    Map<String, dynamic>? metadata,
  }) {
    return ReflectionChatMessage(
      id: id,
      type: type,
      content: content,
      quickOptions: quickOptions,
      selectedOption: selectedOption ?? this.selectedOption,
      timestamp: timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'quickOptions': quickOptions,
      'selectedOption': selectedOption,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ReflectionChatMessage.fromMap(Map<String, dynamic> map) {
    return ReflectionChatMessage(
      id: map['id'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.ai,
      ),
      content: map['content'] ?? '',
      quickOptions:
          (map['quickOptions'] as List<dynamic>?)?.cast<String>() ?? const [],
      selectedOption: map['selectedOption'],
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }
}
