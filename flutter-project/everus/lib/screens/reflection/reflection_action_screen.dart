import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/reflection_models.dart';
import '../../utils/reflection_helper.dart';
import 'widgets/communication_draft_card.dart';

class ReflectionActionScreen extends StatefulWidget {
  final ReflectionItem item;

  const ReflectionActionScreen({
    super.key,
    required this.item,
  });

  @override
  State<ReflectionActionScreen> createState() => _ReflectionActionScreenState();
}

class _ReflectionActionScreenState extends State<ReflectionActionScreen> {
  late TextEditingController _draftController;
  bool _isEditingDraft = false;
  bool _copied = false;
  bool _sharedWithPartner = false;

  @override
  void initState() {
    super.initState();
    _draftController = TextEditingController(text: widget.item.draftedMessage);
  }

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  Future<void> _saveAndFinish(String actionType) async {
    final updatedItem = ReflectionItem(
      id: widget.item.id,
      title: widget.item.title,
      situation: widget.item.situation,
      emotions: widget.item.emotions,
      underlyingNeed: widget.item.underlyingNeed,
      relatedPattern: widget.item.relatedPattern,
      whatHappened: widget.item.whatHappened,
      whatInterpreted: widget.item.whatInterpreted,
      aiPerspective: widget.item.aiPerspective,
      draftedMessage: _draftController.text.trim(),
      createdAt: widget.item.createdAt,
      actionTaken: actionType,
      isBookmarked: widget.item.isBookmarked,
      chatHistory: widget.item.chatHistory,
    );

    await ReflectionHelper.saveReflection(updatedItem);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Đã hoàn thành và lưu thông điệp!',
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Pop back to Reflection Home
    Navigator.of(context).popUntil(
        (route) => route.isFirst || route.settings.name == 'reflection_home');
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _draftController.text));
    setState(() {
      _copied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã sao chép tin nhắn vào bộ nhớ tạm!',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _simulateSharePartner() {
    setState(() {
      _sharedWithPartner = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã chuẩn bị chia sẻ cùng người ấy qua EverUs!',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: const Color(0xFFEC4899),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              // Top Bar
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
                    Text(
                      'Thông điệp giao tiếp',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),

              // Body content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông điệp chân thành gửi đối phương',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'EverUs giúp bạn chuyển hóa insight thành lời nhắn chân thành, không trách móc.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Direct Communication Draft Card
                      CommunicationDraftCard(
                        draftController: _draftController,
                        isEditingDraft: _isEditingDraft,
                        copied: _copied,
                        sharedWithPartner: _sharedWithPartner,
                        onToggleEdit: () {
                          setState(() {
                            _isEditingDraft = !_isEditingDraft;
                          });
                        },
                        onCopy: _copyToClipboard,
                        onSharePartner: _simulateSharePartner,
                        onSaveAndFinish: () => _saveAndFinish('shared'),
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
