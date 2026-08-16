import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/reflection_mock_data.dart';
import 'reflection_chat_screen.dart';
import 'widgets/topic_option_card.dart';
import 'widgets/custom_topic_input.dart';

class ReflectionTopicScreen extends StatefulWidget {
  const ReflectionTopicScreen({super.key});

  @override
  State<ReflectionTopicScreen> createState() => _ReflectionTopicScreenState();
}

class _ReflectionTopicScreenState extends State<ReflectionTopicScreen> {
  final TextEditingController _customTopicController = TextEditingController();
  bool _isWriting = false;

  void _startReflectionWithTopic(Map<String, dynamic> topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReflectionChatScreen(
          topicId: topic['id'] as String?,
          initialUserText: topic['initialPrompt'] as String,
          initialAiText: topic['initialAiQuestion'] as String,
          initialChips: (topic['initialChips'] as List<dynamic>).cast<String>(),
          topicTitle: topic['title'] as String,
        ),
      ),
    );
  }

  void _startWithCustomTopic() {
    final text = _customTopicController.text.trim();
    if (text.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReflectionChatScreen(
          topicId: 'custom',
          initialUserText: text,
          initialAiText: ReflectionMockData.defaultCustomAiQuestion,
          initialChips: ReflectionMockData.defaultCustomChips,
          topicTitle: 'Tâm sự tự do',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customTopicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topics = ReflectionMockData.topicOptions;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF5F5), // ultra-light pink
              Colors.white,
              Color(0xFFFAF5FF), // ultra-light lavender
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top navigation
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF8B5CF6),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Khởi đầu Reflection',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Có chuyện gì đang ở trong đầu bạn?',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chọn một điểm khởi đầu hoặc tự do chia sẻ điều bạn đang trải qua.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Options
                      ...topics.map(
                        (topic) => TopicOptionCard(
                          topic: topic,
                          onTap: () => _startReflectionWithTopic(topic),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Divider with "hoặc"
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Hoặc cứ kể cho EverUs nghe...',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Freeform Textbox
                      CustomTopicInput(
                        controller: _customTopicController,
                        isWriting: _isWriting,
                        onChanged: (val) {
                          setState(() {
                            _isWriting = val.trim().isNotEmpty;
                          });
                        },
                        onStart: _startWithCustomTopic,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
