class QuestionnaireItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? insight;
  final List<String> options;
  final bool allowMultiple;
  final bool isFreeText;

  const QuestionnaireItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.insight,
    this.options = const [],
    this.allowMultiple = false,
    this.isFreeText = false,
  });
}
