import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/reflection_models.dart';
import 'reflection_summary_screen.dart';
import 'widgets/reflection_item_card.dart';

class ReflectionDiaryScreen extends StatefulWidget {
  final List<ReflectionItem> reflections;
  final ValueChanged<ReflectionItem> onViewDetail;

  const ReflectionDiaryScreen({
    super.key,
    required this.reflections,
    required this.onViewDetail,
  });

  @override
  State<ReflectionDiaryScreen> createState() => _ReflectionDiaryScreenState();
}

class _ReflectionDiaryScreenState extends State<ReflectionDiaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all' | 'private' | 'shared' | 'bookmarked'
  String _selectedSort = 'newest'; // 'newest' | 'oldest' | 'bookmarked'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ReflectionItem> get _filteredReflections {
    final query = _searchController.text.toLowerCase().trim();
    var list = widget.reflections.where((item) {
      // Search filter
      final matchesSearch = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.situation.toLowerCase().contains(query) ||
          item.emotions.toLowerCase().contains(query) ||
          item.underlyingNeed.toLowerCase().contains(query);

      // Category filter
      bool matchesCategory = true;
      if (_selectedFilter == 'private') {
        matchesCategory = item.actionTaken == 'private';
      } else if (_selectedFilter == 'shared') {
        matchesCategory = item.actionTaken == 'shared';
      } else if (_selectedFilter == 'bookmarked') {
        matchesCategory = item.isBookmarked;
      }

      return matchesSearch && matchesCategory;
    }).toList();

    // Sorting
    if (_selectedSort == 'oldest') {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_selectedSort == 'bookmarked') {
      list.sort((a, b) {
        if (a.isBookmarked == b.isBookmarked) {
          return b.createdAt.compareTo(a.createdAt);
        }
        return a.isBookmarked ? -1 : 1;
      });
    } else {
      // newest
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReflections;

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
              // Top Bar Header
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
                            'Nhật ký Reflection',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            '${widget.reflections.length} khoảnh khắc được lưu giữ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Search Bar & Sort Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    // Search Input
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF3E8FF),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF8B5CF6).withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF1F2937),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm cảm xúc, tình huống...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF9CA3AF),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF8B5CF6),
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Sort Popup Menu
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF3E8FF),
                          width: 1.5,
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        initialValue: _selectedSort,
                        onSelected: (val) => setState(() => _selectedSort = val),
                        icon: const Icon(
                          Icons.sort_rounded,
                          color: Color(0xFF8B5CF6),
                          size: 20,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'newest',
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_downward_rounded,
                                    size: 16, color: Color(0xFF8B5CF6)),
                                const SizedBox(width: 8),
                                Text('Mới nhất',
                                    style: GoogleFonts.inter(fontSize: 13)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'oldest',
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_upward_rounded,
                                    size: 16, color: Color(0xFF8B5CF6)),
                                const SizedBox(width: 8),
                                Text('Cũ nhất',
                                    style: GoogleFonts.inter(fontSize: 13)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'bookmarked',
                            child: Row(
                              children: [
                                const Icon(Icons.bookmark_rounded,
                                    size: 16, color: Color(0xFFEC4899)),
                                const SizedBox(width: 8),
                                Text('Yêu thích nhất',
                                    style: GoogleFonts.inter(fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Filter Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    _buildFilterChip(
                      id: 'all',
                      label: 'Tất cả (${widget.reflections.length})',
                      icon: Icons.all_inbox_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      id: 'private',
                      label: 'Riêng tư',
                      icon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      id: 'shared',
                      label: 'Đã chia sẻ',
                      icon: Icons.send_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      id: 'bookmarked',
                      label: 'Đã đánh dấu',
                      icon: Icons.bookmark_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Main List
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ReflectionItemCard(
                            item: item,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReflectionSummaryScreen(item: item),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedFilter == id;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = id),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : const Color(0xFFF3E8FF),
            width: 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF3E8FF)),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy nhật ký phù hợp',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Thử thay đổi từ khóa tìm kiếm hoặc chọn bộ lọc khác.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
