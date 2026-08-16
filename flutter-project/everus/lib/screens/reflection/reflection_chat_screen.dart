import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/reflection_models.dart';
import '../../utils/reflection_helper.dart';
import 'reflection_summary_screen.dart';
import 'widgets/reflection_chat_bubble.dart';
import 'widgets/reflection_chat_input.dart';

class ReflectionChatScreen extends StatefulWidget {
  final String? topicId;
  final String initialUserText;
  final String initialAiText;
  final List<String> initialChips;
  final String topicTitle;

  const ReflectionChatScreen({
    super.key,
    this.topicId,
    required this.initialUserText,
    required this.initialAiText,
    required this.initialChips,
    required this.topicTitle,
  });

  @override
  State<ReflectionChatScreen> createState() => _ReflectionChatScreenState();
}

class _ReflectionChatScreenState extends State<ReflectionChatScreen> {
  final List<ReflectionChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAiTyping = false;
  int _currentStep = 1; // 1: Situation, 2: Emotion, 3: Memory, 4: Perspective, 5: Need, 6: Ready for Summary

  // Collected reflection state
  String _situation = '';
  String _selectedEmotion = '';
  String _memoryValidation = '';
  String _selectedFact = '';
  String _underlyingNeed = '';

  @override
  void initState() {
    super.initState();
    _situation = widget.initialUserText;
    _initializeChat();
  }

  void _initializeChat() {
    _messages.add(
      ReflectionChatMessage(
        id: 'msg_user_1',
        type: MessageType.user,
        content: widget.initialUserText,
      ),
    );

    _messages.add(
      ReflectionChatMessage(
        id: 'msg_ai_1',
        type: MessageType.ai,
        content: widget.initialAiText,
        quickOptions: widget.initialChips,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _handleUserResponse(String text) {
    if (text.trim().isEmpty) return;

    // Add user reply
    setState(() {
      _messages.add(
        ReflectionChatMessage(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          type: MessageType.user,
          content: text,
        ),
      );
      _isAiTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    // Advance layered flow based on step
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _advanceFlow(text);
    });
  }

  void _advanceFlow(String userResponse) {
    setState(() {
      _isAiTyping = false;

      if (_currentStep == 1) {
        // Step 1 -> Step 2 (Emotion selected -> Memory recall)
        _selectedEmotion = userResponse;
        _currentStep = 2;

        _messages.add(
          ReflectionChatMessage(
            id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
            type: MessageType.memoryRecall,
            content:
                'Có một điều mình nhớ từ những lần trước:\n"Những lúc communication đột ngột giảm, bạn thường bắt đầu tự hỏi liệu mình còn được ưu tiên hay không."\n\nBạn nghĩ cảm giác hôm nay có liên quan đến điều đó không?',
            quickOptions: [
              'Có, khá giống',
              'Có một chút',
              'Không, lần này khác',
            ],
          ),
        );
      } else if (_currentStep == 2) {
        // Memory validation chosen -> Perspective Reframing (Step 3)
        _memoryValidation = userResponse;
        if (userResponse.contains('Không')) {
          ReflectionHelper.adjustPatternConfidence('pat_1', -0.15);
        } else {
          ReflectionHelper.adjustPatternConfidence('pat_1', 0.05);
        }
        _currentStep = 3;

        _messages.add(
          ReflectionChatMessage(
            id: 'persp_${DateTime.now().millisecondsSinceEpoch}',
            type: MessageType.perspectiveReframing,
            content:
                'Có vẻ phần khiến bạn đau nhất là cảm giác mình không được ưu tiên.\n\nNhưng hiện tại mình chưa biết việc người ấy chưa trả lời đến từ không quan tâm, đang bận, cần không gian hay một lý do khác.\n\nNếu tạm thời không đoán ý định của người ấy, điều gì là fact (sự thật) mình thực sự biết lúc này?',
            quickOptions: [
              'Anh ấy chưa trả lời',
              'Anh ấy đang online',
              'Mình đã chờ vài tiếng',
              'Khác (Cần bình tĩnh)',
            ],
          ),
        );
      } else if (_currentStep == 3) {
        // Step 3 -> Step 4 (Deep need identification)
        _selectedFact = userResponse;
        _currentStep = 4;

        _messages.add(
          ReflectionChatMessage(
            id: 'ai_need_${DateTime.now().millisecondsSinceEpoch}',
            type: MessageType.ai,
            content:
                'Việc phân biệt được sự thật và suy đoán giúp tâm trí nhẹ đi nhiều.\n\nNếu bỏ qua câu chuyện tin nhắn một chút, điều bạn thực sự mong nhận được từ người ấy lúc này là gì?',
            quickOptions: [
              'Một lời nhắn ngắn báo đang bận',
              'Cảm giác được nhớ tới và ưu tiên',
              'Sự tôn trọng thời gian của nhau',
              'Một cái ôm và sự lắng nghe',
            ],
          ),
        );
      } else if (_currentStep == 4) {
        // Step 4 -> Step 5 (Summary is ready)
        _underlyingNeed = userResponse;
        _currentStep = 5;

        _messages.add(
          ReflectionChatMessage(
            id: 'ready_${DateTime.now().millisecondsSinceEpoch}',
            type: MessageType.summaryReady,
            content:
                'EverUs đã cùng bạn đi qua từng lớp cảm xúc.\nMọi thứ giờ đây dường như đã rõ ràng hơn rất nhiều.',
          ),
        );
      } else {
        // Additional thoughts
        _messages.add(
          ReflectionChatMessage(
            id: 'ai_extra_${DateTime.now().millisecondsSinceEpoch}',
            type: MessageType.ai,
            content:
                'Mình luôn ở đây lắng nghe bạn. Khi sẵn sàng, bạn có thể xem bản tổng kết phản chiếu bất cứ lúc nào.',
          ),
        );
      }
    });
    _scrollToBottom();
  }

  Future<void> _navigateToSummary() async {
    String relatedPattern;
    String whatInterpreted;
    String aiPerspective;
    String draftedMessage;

    if (widget.topicId == 'vague_feeling') {
      relatedPattern =
          'Khi sự gắn kết giảm bớt, cảm giác trống trải dễ xuất hiện dù ở cạnh nhau.';
      whatInterpreted =
          'Lo sợ mối quan hệ đang dần phai nhạt hoặc hai người có khoảng cách vô hình.';
      aiPerspective =
          'Có thể cả hai đều đang mệt mỏi sau những áp lực riêng và chưa dành đủ thời gian chất lượng cho nhau.';
      draftedMessage =
          'Dạo này em cảm thấy hai đứa hơi có khoảng cách một chút. Em rất trân trọng tình cảm của mình, tối nay tụi mình dành 30 phút trò chuyện nhẹ nhàng để kết nối lại nha.';
    } else if (widget.topicId == 'pattern_analysis') {
      relatedPattern =
          'Vòng lặp im lặng hoặc né tránh sau những xung đột bất đồng.';
      whatInterpreted =
          'Cho rằng đối phương không muốn giải quyết hoặc phớt lờ cảm xúc của mình.';
      aiPerspective =
          'Im lặng thường là cơ chế tự vệ khi quá tải cảm xúc, không hẳn là ngừng yêu thương hay coi thường mối quan hệ.';
      draftedMessage =
          'Mỗi lần tụi mình im lặng sau tranh luận, em cảm thấy rất bất an. Lần tới nếu cần thời gian bình tĩnh, anh báo em một tiếng rồi tụi mình hẹn giờ nói chuyện lại nha.';
    } else if (widget.topicId == 'custom') {
      relatedPattern =
          'Phản ứng cảm xúc tự nhiên khi trải qua băn khoăn trong mối quan hệ.';
      whatInterpreted =
          'Cảm thấy bị ảnh hưởng tâm lý và cần không gian bóc tách cảm xúc rõ ràng hơn.';
      aiPerspective =
          'Mọi cảm xúc của bạn đều hoàn toàn chính đáng và đáng được trân trọng.';
      draftedMessage =
          'Lúc này em cảm thấy: ${_selectedEmotion.isNotEmpty ? _selectedEmotion : 'hơi bối rối'}. Điều em mong muốn nhất từ anh là ${_underlyingNeed.isNotEmpty ? _underlyingNeed : 'sự lắng nghe và thấu hiểu'}.';
    } else {
      // 'incident' or default
      relatedPattern =
          'Khi communication thay đổi đột ngột, bạn dễ bắt đầu nghi ngờ mức độ quan tâm của đối phương.';
      whatInterpreted =
          'Cảm giác mình không còn được ưu tiên hoặc bị xem nhẹ.';
      aiPerspective =
          'Có thể đối phương đang bận xử lý công việc gấp hoặc cần không gian hạ nhiệt sau giờ làm việc căng thẳng.';
      draftedMessage =
          'Em không cần anh phải trả lời em ngay khi anh đang bận. Nhưng khi communication đột ngột mất đi, em hơi bất an. Nếu lúc đó anh báo em một câu là đang bận và sẽ nói chuyện sau thì em sẽ thấy yên tâm hơn nhiều.';
    }

    final item = ReflectionItem(
      id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
      title: widget.topicTitle,
      situation: _situation,
      emotions: _selectedEmotion.isNotEmpty
          ? _selectedEmotion
          : 'Bực bội, bất an và hơi bị bỏ quên',
      underlyingNeed: _underlyingNeed.isNotEmpty
          ? _underlyingNeed
          : 'Cần sự an tâm (Reassurance) + một expectation rõ ràng về communication',
      relatedPattern: relatedPattern,
      whatHappened: _selectedFact.isNotEmpty ? _selectedFact : _situation,
      whatInterpreted: whatInterpreted,
      aiPerspective: aiPerspective,
      draftedMessage: draftedMessage,
      createdAt: DateTime.now(),
      actionTaken: 'private',
      chatHistory: List.from(_messages),
    );

    // Save immediately so session is safely stored in Diary
    await ReflectionHelper.saveReflection(item);

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReflectionSummaryScreen(item: item),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // Chat App Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'AI Reflection',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF2F8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFBCFE8),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Private',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFEC4899),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lắng nghe & bóc tách cảm xúc',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Summary button if ready or anytime accessible
                    if (_currentStep >= 3)
                      TextButton.icon(
                        onPressed: _navigateToSummary,
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          foregroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                        icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                        label: Text(
                          'Tổng kết',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Progress dots indicator
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                child: Row(
                  children: List.generate(5, (index) {
                    final isActive = index < _currentStep;
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 8),

              // Messages list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 12.0),
                  itemCount: _messages.length + (_isAiTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isAiTyping) {
                      return _buildTypingIndicator();
                    }
                    final msg = _messages[index];
                    return ReflectionChatBubble(
                      message: msg,
                      onOptionSelected: (opt) {
                        setState(() {
                          final idx = _messages.indexOf(msg);
                          _messages[idx] = msg.copyWith(selectedOption: opt);
                        });
                        _handleUserResponse(opt);
                      },
                      onNavigateToSummary: _navigateToSummary,
                    );
                  },
                ),
              ),

              // Bottom Input Bar
              ReflectionChatInput(
                controller: _textController,
                onSubmitted: _handleUserResponse,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF3E8FF), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EverUs đang suy nghĩ cùng bạn',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
