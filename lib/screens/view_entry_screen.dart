import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';
import 'add_entry_screen.dart';

class ViewEntryScreen extends StatelessWidget {
  final String entryId;

  const ViewEntryScreen({super.key, required this.entryId});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Memory?',
          style: GoogleFonts.epilogue(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to let go of this journal entry? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep It', style: GoogleFonts.plusJakartaSans(color: AppTheme.outline)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              context.read<DiaryProvider>().deleteEntry(entryId);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back from view screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Memory removed from sanctuary',
                    style: GoogleFonts.plusJakartaSans(),
                  ),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Delete', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final entry = provider.entries.where((e) => e.id == entryId).firstOrNull;

    if (entry == null) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Memory no longer exists.',
            style: GoogleFonts.plusJakartaSans(color: AppTheme.outline),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              entry.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: entry.isFavorite ? AppTheme.primary : AppTheme.outline,
              size: 22,
            ),
            onPressed: () {
              provider.toggleFavorite(entry.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEntryScreen(initialEntry: entry),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.outline, size: 22),
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Mood Pill
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('EEEE, MMMM d, y • h:mm a').format(entry.date),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${entry.moodEmoji} ${entry.mood}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              entry.title,
              style: GoogleFonts.epilogue(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Image If Available
            if (entry.imageUrl != null && entry.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  entry.imageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Ruled line container / body
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                entry.content,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  height: 1.8,
                  color: AppTheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tags
            if (entry.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: entry.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#$tag',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primary,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
