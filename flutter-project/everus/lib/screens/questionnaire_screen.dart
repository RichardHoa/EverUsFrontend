import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/questionnaire_data.dart';
import '../models/questionnaire_model.dart';
import '../utils/questionnaire_helper.dart';

class QuestionnaireScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  /// Edit mode (signed-in users, opened from the profile): pre-filled, no
  /// "skip all", and saves over the previous answers instead of adding new ones.
  final bool isEditMode;
  final Map<String, dynamic>? initialAnswers;
  final String? initialFreeText;

  const QuestionnaireScreen({
    super.key,
    required this.onCompleted,
    this.isEditMode = false,
    this.initialAnswers,
    this.initialFreeText,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _freeTextController = TextEditingController();

  int _currentIndex = 0;
  bool _isSubmitting = false;

  // Stores answers: Map of question id -> String (single choice) or List<String> (multiple choice)
  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAnswers;
    if (initial != null) {
      initial.forEach((key, value) {
        _answers[key] = value is List ? List<String>.from(value.map((e) => e.toString())) : value;
      });
    }
    _freeTextController.text = widget.initialFreeText ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _freeTextController.dispose();
    super.dispose();
  }

  void _onOptionSelected(QuestionnaireItem question, String option) {
    setState(() {
      if (question.allowMultiple) {
        List<String> current = List<String>.from(_answers[question.id] ?? []);
        if (current.contains(option)) {
          current.remove(option);
        } else {
          current.add(option);
        }
        if (current.isEmpty) {
          _answers.remove(question.id);
        } else {
          _answers[question.id] = current;
        }
      } else {
        _answers[question.id] = option;
      }
    });
  }

  void _nextPage() {
    if (_currentIndex < coupleQuestions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _skipCurrentQuestion() {
    _nextPage();
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final freeText = _freeTextController.text.trim();
    if (widget.isEditMode) {
      final saved = await QuestionnaireHelper.updateOnBackend(
        answers: _answers,
        freeText: freeText.isNotEmpty ? freeText : null,
      );
      if (!saved && mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa lưu được câu trả lời. Vui lòng thử lại!')),
        );
        return;
      }
    } else {
      await QuestionnaireHelper.submitToBackend(
        answers: _answers,
        freeText: freeText.isNotEmpty ? freeText : null,
      );
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      widget.onCompleted();
    }
  }

  Future<void> _skipAll() async {
    setState(() {
      _isSubmitting = true;
    });
    // Skipping still counts as answering (with no answers) so the user is not asked again.
    await QuestionnaireHelper.submitToBackend(answers: {});
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = coupleQuestions.length;
    final progress = (_currentIndex + 1) / totalQuestions;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFF0F5), // Lavender blush
                    Color(0xFFFFFFFF),
                    Color(0xFFF5EFFF), // Soft lavender
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar / Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    children: [
                      // Back Button
                      if (_currentIndex > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF5A384C)),
                          onPressed: _previousPage,
                          tooltip: 'Câu trước',
                        )
                      else if (widget.isEditMode)
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF5A384C)),
                          child: Text('Huỷ', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600)),
                        )
                      else
                        const SizedBox(width: 40),

                      // Progress indicator
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFEADBEC),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                          ),
                        ),
                      ),

                      // Skip current question button
                      TextButton(
                        onPressed: _skipCurrentQuestion,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        child: Text(
                          _currentIndex == totalQuestions - 1 ? 'Bỏ qua' : 'Bỏ qua',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Question Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: totalQuestions,
                    itemBuilder: (context, index) {
                      final question = coupleQuestions[index];
                      return _buildQuestionCard(question);
                    },
                  ),
                ),

                // Bottom Action Bar
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 20.0, top: 10.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF653851),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: const Color(0xFF653851).withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentIndex == totalQuestions - 1
                                          ? (widget.isEditMode ? 'Lưu thay đổi' : 'Hoàn thành & Bắt đầu')
                                          : 'Tiếp tục',
                                      style: GoogleFonts.inter(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (!widget.isEditMode) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _isSubmitting ? null : _skipAll,
                        child: Text(
                          'Bỏ qua tất cả & Bắt đầu trải nghiệm ➔',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: const Color(0xFF9E8E9B),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionnaireItem question) {
    final dynamic currentAnswer = _answers[question.id];

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Glassmorphic Card Container
              Container(
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5A384C).withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Title
                    Text(
                      question.title,
                      style: GoogleFonts.comfortaa(
                        fontSize: 18.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5A384C),
                        height: 1.35,
                      ),
                    ),
                    if (question.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        question.subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: const Color(0xFF7C6E79),
                        ),
                      ),
                    ],
                    if (question.allowMultiple) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: Text(
                          'Có thể chọn nhiều đáp án',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Options or Free Text
                    if (question.isFreeText)
                      _buildFreeTextInput()
                    else
                      Column(
                        children: question.options.map((option) {
                          final bool isSelected = question.allowMultiple
                              ? (currentAnswer is List && currentAnswer.contains(option))
                              : (currentAnswer == option);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: _buildOptionTile(
                              option: option,
                              isSelected: isSelected,
                              isMultiple: question.allowMultiple,
                              onTap: () => _onOptionSelected(question, option),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String option,
    required bool isSelected,
    required bool isMultiple,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF6F0FF) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFEDE3EC),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: isMultiple ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: isMultiple ? BorderRadius.circular(6) : null,
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFC7BAC5),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 15,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? const Color(0xFF4C2A40) : const Color(0xFF40363D),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D6E0), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _freeTextController,
        maxLines: 5,
        maxLength: 300,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF40363D),
        ),
        decoration: InputDecoration(
          hintText: 'Ví dụ: Tụi mình thích đi cà phê yên tĩnh vào chiều Chủ nhật, thích nuôi mèo...',
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFFA596A3),
          ),
          border: InputBorder.none,
          counterStyle: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFFA596A3),
          ),
        ),
      ),
    );
  }
}
