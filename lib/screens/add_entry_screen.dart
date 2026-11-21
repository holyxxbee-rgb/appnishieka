import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';

class AddEntryScreen extends StatefulWidget {
  final DiaryEntry? initialEntry;

  const AddEntryScreen({super.key, this.initialEntry});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final TextEditingController _tagInputController = TextEditingController();

  final List<Map<String, String>> _moods = [
    {'name': 'Joyful', 'emoji': '🌸'},
    {'name': 'Calm', 'emoji': '☁️'},
    {'name': 'Cozy', 'emoji': '☕'},
    {'name': 'Reflective', 'emoji': '🌙'},
    {'name': 'Grateful', 'emoji': '✨'},
  ];

  late String _selectedMood;
  late String _selectedMoodEmoji;
  late bool _isFavorite;
  late DateTime _selectedDate;
  late List<String> _tags;
  String? _photoUrl;

  final List<String> _photoPresets = [
    'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _contentController = TextEditingController(text: entry?.content ?? '');
    _selectedMood = entry?.mood ?? _moods[2]['name']!;
    _selectedMoodEmoji = entry?.moodEmoji ?? _moods[2]['emoji']!;
    _isFavorite = entry?.isFavorite ?? false;
    _selectedDate = entry?.date ?? DateTime.now();
    _tags = entry != null ? List.from(entry.tags) : ['cozyevening', 'autumn', 'journal'];
    _photoUrl = entry?.imageUrl ?? _photoPresets[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showAddTagDialog() {
    _tagInputController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Keepsake Tag',
          style: GoogleFonts.epilogue(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        content: TextField(
          controller: _tagInputController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. coffee, reflection, sunset',
            hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.surfaceContainerHigh),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppTheme.outline)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              final newTag = _tagInputController.text.trim().replaceAll('#', '');
              if (newTag.isNotEmpty && !_tags.contains(newTag)) {
                setState(() {
                  _tags.add(newTag);
                });
              }
              Navigator.pop(ctx);
            },
            child: Text('Add', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Keepsake Photo',
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoPresets.length,
                  itemBuilder: (context, idx) {
                    final url = _photoPresets[idx];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _photoUrl = url);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _photoUrl == url ? AppTheme.primary : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(url, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppTheme.primary),
                title: Text('Remove Photo', style: GoogleFonts.plusJakartaSans(color: AppTheme.primary)),
                onTap: () {
                  setState(() => _photoUrl = null);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in the entry title and content',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<DiaryProvider>();
    final isEditing = widget.initialEntry != null;

    final entry = DiaryEntry(
      id: widget.initialEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: _selectedDate,
      mood: _selectedMood,
      moodEmoji: _selectedMoodEmoji,
      imageUrl: _photoUrl,
      tags: _tags,
      isFavorite: _isFavorite,
    );

    if (isEditing) {
      provider.updateEntry(entry);
    } else {
      provider.addEntry(entry);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? 'Memory updated ✨' : 'Memory safely saved in your sanctuary ✨',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialEntry != null;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Entry' : 'New Entry',
          style: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Interactive Date Picker Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isEditing ? 'EDITING' : 'DRAFTING',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDateTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        size: 14, color: AppTheme.primary),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        DateFormat('MMM d, y • h:mm a').format(_selectedDate),
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.expand_more, size: 14, color: AppTheme.outline),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Mood Palette Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Frequency",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Tap to shift',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _moods.map((m) {
                            final isSelected = m['name'] == _selectedMood;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text('${m['emoji']} ${m['name']}'),
                                selected: isSelected,
                                selectedColor: AppTheme.secondaryContainer,
                                backgroundColor: AppTheme.surfaceContainerLow,
                                labelStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? AppTheme.onPrimaryContainer : AppTheme.onSurface,
                                ),
                                side: isSelected
                                    ? const BorderSide(color: AppTheme.primary, width: 1)
                                    : BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedMood = m['name']!;
                                    _selectedMoodEmoji = m['emoji']!;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Main Diary Canvas (Notebook Styling)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondaryContainer.withValues(alpha: 0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _titleController,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter a title for your memory';
                                }
                                return null;
                              },
                              style: GoogleFonts.epilogue(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Title of your day...',
                                hintStyle: GoogleFonts.epilogue(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.outlineVariant,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                            const Divider(color: AppTheme.surfaceContainerHigh, height: 24),
                            TextFormField(
                              controller: _contentController,
                              maxLines: 8,
                              onChanged: (_) => setState(() {}),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Write what happened or what you felt today';
                                }
                                return null;
                              },
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                height: 1.6,
                                color: AppTheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Dear Diary, what happened today? Write your feelings, memories, or gratitude freely...',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppTheme.outlineVariant,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Tags Section
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ..._tags.map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '#$tag',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _tags.remove(tag);
                                            });
                                          },
                                          child: const Icon(Icons.close, size: 14, color: AppTheme.outline),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _showAddTagDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.add, size: 14, color: AppTheme.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Add Tag',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Keepsake Photo Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Keepsake Photo',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _showPhotoOptionsDialog,
                                  child: Text(
                                    _photoUrl != null ? 'Change' : 'Add Photo',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.tertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (_photoUrl != null) ...[
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          _photoUrl!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: -6,
                                        right: -6,
                                        child: GestureDetector(
                                          onTap: () => setState(() => _photoUrl = null),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.cancel,
                                                color: AppTheme.primary, size: 18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                GestureDetector(
                                  onTap: _showPhotoOptionsDialog,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add_a_photo,
                                            color: AppTheme.outline, size: 24),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Memory',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: AppTheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Favorite Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.surfaceContainerHigh,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.favorite,
                                          color: AppTheme.primary, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mark as Favorite',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          'Pins this memory in keepsakes',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: AppTheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _isFavorite,
                                  activeTrackColor: AppTheme.primaryContainer,
                                  activeThumbColor: AppTheme.primary,
                                  onChanged: (val) => setState(() => _isFavorite = val),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed bottom bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryContainer.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_wordCount words',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      Text(
                        '~${(_wordCount / 150).ceil()} min read',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.outline,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(
                      isEditing ? 'Update Entry' : 'Save Entry',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _saveEntry,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
