import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';
import 'view_entry_screen.dart';

class DiaryListScreen extends StatefulWidget {
  final List<DiaryEntry>? entries;
  final dynamic Function(DiaryEntry)? onToggleFavorite;
  final VoidCallback? onNavigateToProfile;

  const DiaryListScreen({
    super.key,
    this.entries,
    this.onToggleFavorite,
    this.onNavigateToProfile,
  });

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'all'; // all, month, favorites, travel, reflections

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DiaryEntry> _filterEntries(List<DiaryEntry> entries) {
    final query = _searchController.text.trim().toLowerCase();

    return entries.where((entry) {
      final matchesQuery = query.isEmpty ||
          entry.title.toLowerCase().contains(query) ||
          entry.content.toLowerCase().contains(query) ||
          entry.tags.any((t) => t.toLowerCase().contains(query));

      if (!matchesQuery) return false;

      switch (_activeFilter) {
        case 'favorites':
          return entry.isFavorite;
        case 'month':
          final now = DateTime.now();
          return entry.date.year == now.year && entry.date.month == now.month;
        case 'travel':
          return entry.tags.any((t) => t.toLowerCase().contains('travel'));
        case 'reflections':
          return entry.tags.any((t) =>
                  t.toLowerCase().contains('reflect') ||
                  t.toLowerCase().contains('notes') ||
                  t.toLowerCase().contains('peace')) ||
              entry.mood.toLowerCase().contains('reflect');
        case 'all':
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final allEntries = widget.entries ?? provider.entries;
    final filteredEntries = _filterEntries(allEntries);

    final totalCount = allEntries.length;
    final monthCount = allEntries.where((e) {
      final now = DateTime.now();
      return e.date.year == now.year && e.date.month == now.month;
    }).length;
    final favCount = allEntries.where((e) => e.isFavorite).length;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.book_rounded, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'SnapDiary',
              style: GoogleFonts.epilogue(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: widget.onNavigateToProfile ?? () {},
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.surfaceContainerHigh,
                child: const Icon(Icons.person, color: AppTheme.primary, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppTheme.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppTheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search your thoughts, tags, or memories...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: const Icon(Icons.close, color: AppTheme.outline, size: 18),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All ($totalCount)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('month', 'This Month ($monthCount)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('favorites', 'Favorites ($favCount)',
                          icon: Icons.favorite),
                      const SizedBox(width: 8),
                      _buildFilterChip('travel', 'Travel'),
                      const SizedBox(width: 8),
                      _buildFilterChip('reflections', 'Reflections'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Diary List
          Expanded(
            child: filteredEntries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppTheme.surfaceContainerHigh,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_stories,
                                color: AppTheme.primary, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Memories Found',
                            style: GoogleFonts.epilogue(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No diary entries matched your search. Try another keyword or reset filters.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      final isToday = index == 0;
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ViewEntryScreen(entryId: entry.id),
                            ),
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.secondaryContainer
                                        .withValues(alpha: 0.08),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top meta & Heart
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: isToday ? 28.0 : 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${DateFormat('MMM d').format(entry.date)} • ${DateFormat('h:mm a').format(entry.date)}',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8,
                                                  color: AppTheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                entry.title,
                                                style: GoogleFonts.epilogue(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          entry.isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: entry.isFavorite
                                              ? AppTheme.primary
                                              : AppTheme.outline,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          if (widget.onToggleFavorite != null) {
                                            widget.onToggleFavorite!(entry);
                                          } else {
                                            provider.toggleFavorite(entry.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Mood Badge
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceContainerHigh,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${entry.moodEmoji} ${entry.mood}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Snippet
                                  Text(
                                    entry.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                  ),

                                  // Optional Polaroid Image Snippet
                                  if (entry.imageUrl != null &&
                                      entry.imageUrl!.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        entry.imageUrl!,
                                        width: double.infinity,
                                        height: 140,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          height: 80,
                                          color: AppTheme.surfaceContainerHigh,
                                          child: const Center(
                                            child: Icon(Icons.image,
                                                color: AppTheme.primary),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 14),
                                  // Tags & Word Count
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        children: entry.tags
                                            .map((t) => Text(
                                                  '#$t',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme.primary,
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                      Text(
                                        '${entry.content.trim().split(RegExp(r'\s+')).length} words',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: AppTheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Ribbon for today's entry
                            if (isToday)
                              Positioned(
                                top: -3,
                                left: 24,
                                child: Container(
                                  width: 18,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(4)),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.surfaceContainerLowest,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, {IconData? icon}) {
    final isSelected = _activeFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryContainer : AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? Colors.white : AppTheme.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
