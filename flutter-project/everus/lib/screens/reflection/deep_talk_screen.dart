import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/deep_talk_data.dart';
import '../../models/deep_talk_card.dart';
import 'reflection_chat_screen.dart';

class DeepTalkScreen extends StatefulWidget {
  const DeepTalkScreen({super.key});

  @override
  State<DeepTalkScreen> createState() => _DeepTalkScreenState();
}

class _DeepTalkScreenState extends State<DeepTalkScreen> {
  String _selectedTopic = 'TẤT CẢ';
  late List<DeepTalkCard> _filteredCards;
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _filteredCards = DeepTalkData.getCardsByTopic(_selectedTopic);
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectTopic(String topic) {
    if (_selectedTopic == topic) return;
    setState(() {
      _selectedTopic = topic;
      _filteredCards = DeepTalkData.getCardsByTopic(topic);
      _currentIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _nextCard() {
    if (_filteredCards.isEmpty) return;
    if (_currentIndex < _filteredCards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevCard() {
    if (_filteredCards.isEmpty) return;
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.animateToPage(
        _filteredCards.length - 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _shuffleDeck() {
    setState(() {
      _filteredCards.shuffle(Random());
      _currentIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã xáo trộn bộ bài!',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _startReflectionFromCard(DeepTalkCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReflectionChatScreen(
          topicId: card.id,
          initialUserText: card.text,
          initialAiText:
              'Câu hỏi thấu cảm này khơi gợi suy nghĩ gì trong bạn? Cùng EverUs chia sẻ góc nhìn của bạn nhé.',
          initialChips: const [
            'Mình muốn mở lòng về điều này',
            'Cần chuẩn bị trước khi hỏi người ấy',
            'Cần thêm góc nhìn từ EverUs'
          ],
          topicTitle: card.topic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _filteredCards.isNotEmpty
        ? _filteredCards[_currentIndex]
        : null;

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
              // Top Navigation Bar
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
                          Text(
                            'Deep Talk Cards',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'Bộ thẻ bài mở lòng & trò chuyện chiều sâu',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.shuffle_rounded,
                        color: Color(0xFF8B5CF6),
                      ),
                      tooltip: 'Xáo bài',
                      onPressed: _shuffleDeck,
                    ),
                  ],
                ),
              ),

              // Topic Filter Chips
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: DeepTalkData.topics.length,
                  itemBuilder: (context, index) {
                    final topic = DeepTalkData.topics[index];
                    final isSelected = topic == _selectedTopic;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          topic,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF4B5563),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF8B5CF6),
                        backgroundColor: Colors.white,
                        elevation: isSelected ? 3 : 0,
                        shadowColor:
                            const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        onSelected: (_) => _selectTopic(topic),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Card Counter Indicator
              if (_filteredCards.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3E8FF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Thẻ ${_currentIndex + 1} / ${_filteredCards.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Interactive Card Area with Proportional Card Deck & Side Buttons
              Expanded(
                child: _filteredCards.isEmpty
                    ? const Center(child: Text('Không có thẻ bài nào'))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            // Obvious Previous Button right beside the card
                            Material(
                              color: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.25),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _prevCard,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE9D5FF),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18,
                                    color: Color(0xFF8B5CF6),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),

                            // Smooth PageView Card Deck with 3:4 Proportions
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _filteredCards.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final card = _filteredCards[index];

                                  return AnimatedBuilder(
                                    animation: _pageController,
                                    builder: (context, child) {
                                      double value = 1.0;
                                      if (_pageController
                                          .position.haveDimensions) {
                                        value = (_pageController.page! - index)
                                            .abs();
                                        value = (1 - (value * 0.12))
                                            .clamp(0.85, 1.0);
                                      }
                                      return Transform.scale(
                                        scale: value,
                                        child: child,
                                      );
                                    },
                                    child: _DeepTalkFlipCard(
                                      key: ValueKey(card.id),
                                      card: card,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 4),

                            // Obvious Next Button right beside the card
                            Material(
                              color: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.25),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _nextCard,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE9D5FF),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                    color: Color(0xFF8B5CF6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // Bottom Action Controls
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 8.0),
                child: Column(
                  children: [
                    // Gesture instruction tip (Wrapped in Expanded/Flexible to prevent overflow)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.swap_horiz_rounded,
                          size: 16,
                          color: Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Vuốt trái/phải để đổi thẻ • Chạm để lật bài',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Action: Reflect together CTA
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: currentCard != null
                            ? () => _startReflectionFromCard(currentCard)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Reflect cùng câu hỏi này',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

/// Dedicated Stateful Card Flip Widget
class _DeepTalkFlipCard extends StatefulWidget {
  final DeepTalkCard card;

  const _DeepTalkFlipCard({super.key, required this.card});

  @override
  State<_DeepTalkFlipCard> createState() => _DeepTalkFlipCardState();
}

class _DeepTalkFlipCardState extends State<_DeepTalkFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _flipAnimation.addListener(() {
      if (_flipAnimation.value >= 0.5 && _isFront) {
        setState(() {
          _isFront = false;
        });
      } else if (_flipAnimation.value < 0.5 && !_isFront) {
        setState(() {
          _isFront = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_flipController.isAnimating) return;
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle >= pi / 2
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardBack(widget.card),
                  )
                : _buildCardFront(),
          );
        },
      ),
    );
  }

  // Front of Card View (Proportional 3:4 aspect ratio)
  Widget _buildCardFront() {
    return Center(
      child: AspectRatio(
        aspectRatio: 0.70,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decorative rings
              Positioned(
                right: -30,
                bottom: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '♡',
                        style: TextStyle(
                          fontSize: 34,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'DEEP TALK CARDS',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'EVERUS REFLECTION',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'CHẠM ĐỂ MỞ THẺ',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
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

  // Back of Card View (Proportional 3:4 aspect ratio)
  Widget _buildCardBack(DeepTalkCard card) {
    return Center(
      child: AspectRatio(
        aspectRatio: 0.70,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFF3E8FF),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category & Topic
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            card.category,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF8B5CF6),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.topic,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF0F5),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      card.icon,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Card Question Text
              Text(
                card.text,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // Bottom card ID watermark
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  card.id,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFD1D5DB),
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
