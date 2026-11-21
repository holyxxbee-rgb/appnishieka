import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';
import 'view_entry_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<DiaryEntry>? entries;
  final dynamic Function(DiaryEntry)? onToggleFavorite;
  final VoidCallback? onNavigateToProfile;

  const FavoritesScreen({
    super.key,
    this.entries,
    this.onToggleFavorite,
    this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final List<DiaryEntry> favorites = entries != null
        ? entries!.where((e) => e.isFavorite).toList()
        : provider.favorites;

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
              child: const Icon(
                Icons.book_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
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
              onTap: onNavigateToProfile ?? () {},
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.surfaceContainerHigh,
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: favorites.isEmpty
          ? Center(
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
                    child: const Icon(
                      Icons.favorite_border,
                      size: 32,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Keepsakes Pinned Yet',
                    style: GoogleFonts.epilogue(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Heart any memory to keep it safe in your special album.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final entry = favorites[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ViewEntryScreen(entryId: entry.id),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryContainer.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${entry.moodEmoji} ${entry.mood}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                              onPressed: () {
                                if (onToggleFavorite != null) {
                                  onToggleFavorite!(entry);
                                } else {
                                  provider.toggleFavorite(entry.id);
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          entry.title,
                          style: GoogleFonts.epilogue(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMMM d, y • h:mm a').format(entry.date),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
