import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fNameController;
  late final TextEditingController _lNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  late final TextEditingController _diaryTitleController;
  late final TextEditingController _milestoneController;
  late final TextEditingController _reminderController;
  late bool _ruledLines;

  @override
  void initState() {
    super.initState();
    final profile = context.read<DiaryProvider>().profile;
    _fNameController = TextEditingController(text: profile.firstName);
    _lNameController = TextEditingController(text: profile.lastName);
    _emailController = TextEditingController(text: profile.email);
    _bioController = TextEditingController(text: profile.bio);
    _diaryTitleController = TextEditingController(text: profile.diaryTitle);
    _milestoneController = TextEditingController(text: profile.memoryMilestone);
    _reminderController = TextEditingController(text: profile.reminderTime);
    _ruledLines = profile.notebookRuledLines;
  }

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _diaryTitleController.dispose();
    _milestoneController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final updated = UserProfile(
      firstName: _fNameController.text.trim(),
      lastName: _lNameController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      diaryTitle: _diaryTitleController.text.trim(),
      memoryMilestone: _milestoneController.text.trim(),
      reminderTime: _reminderController.text.trim(),
      notebookRuledLines: _ruledLines,
    );

    context.read<DiaryProvider>().updateProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile & sanctuary settings saved ✨',
          style: GoogleFonts.plusJakartaSans(),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  void _showDeleteSanctuaryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFBA1A1A), size: 24),
            const SizedBox(width: 8),
            Text(
              'Let Go of Your Sanctuary?',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'This action is irreversible. All daily entries and photos will be permanently erased.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep My Diary',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.outline)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              context.read<DiaryProvider>().clearAllData();
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Sanctuary reset complete',
                    style: GoogleFonts.plusJakartaSans(),
                  ),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Delete All',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.check, size: 16),
              label: Text('Save', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
              onPressed: _saveProfile,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryContainer.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: AppTheme.surfaceContainerHigh,
                            child: const Icon(Icons.person, color: AppTheme.primary, size: 52),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_camera,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_fNameController.text} ${_lNameController.text}',
                        style: GoogleFonts.epilogue(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keepsake Sanctuary Member',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.secondary,
                              side: const BorderSide(color: AppTheme.outlineVariant),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.photo_library, size: 16),
                            label: Text('Gallery',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Avatar updated from library')),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.secondary,
                              side: const BorderSide(color: AppTheme.outlineVariant),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.camera_alt, size: 16),
                            label: Text('Camera',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Camera opened')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Personal Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.badge, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Personal Details',
                            style: GoogleFonts.epilogue(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _fNameController,
                              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                filled: true,
                                fillColor: AppTheme.surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lNameController,
                              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                filled: true,
                                fillColor: AppTheme.surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        validator: (v) =>
                            v!.contains('@') ? null : 'Please enter valid email',
                        decoration: InputDecoration(
                          labelText: 'Email Address (Gmail)',
                          filled: true,
                          fillColor: AppTheme.surfaceContainerLow,
                          prefixIcon: const Icon(Icons.mail_outline, size: 18),
                          suffixIcon: const Icon(Icons.verified,
                              color: AppTheme.secondary, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: 150,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Sanctuary Bio / Journaling Mantra',
                          filled: true,
                          fillColor: AppTheme.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Diary Nuances Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Diary Nuances',
                            style: GoogleFonts.epilogue(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _diaryTitleController,
                        decoration: InputDecoration(
                          labelText: 'Diary Title & Greeting',
                          prefixIcon: const Icon(Icons.favorite_outline, size: 18),
                          filled: true,
                          fillColor: AppTheme.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _milestoneController,
                              decoration: InputDecoration(
                                labelText: 'Memory Milestone',
                                suffixIcon: const Icon(Icons.cake, size: 18, color: AppTheme.primary),
                                filled: true,
                                fillColor: AppTheme.surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _reminderController,
                              decoration: InputDecoration(
                                labelText: 'Evening Prompt',
                                suffixIcon: const Icon(Icons.notifications_active,
                                    size: 18, color: AppTheme.secondary),
                                filled: true,
                                fillColor: AppTheme.surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Notebook Ruled Lines',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Show soft linen lines in journal editor',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.outline,
                          ),
                        ),
                        activeTrackColor: AppTheme.primaryContainer,
                        activeThumbColor: AppTheme.primary,
                        value: _ruledLines,
                        onChanged: (val) => setState(() => _ruledLines = val),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Account & Security / Delete
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_outline, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Account & Security',
                            style: GoogleFonts.epilogue(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.surfaceContainerHigh,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.password, color: AppTheme.primary, size: 18),
                          ),
                          title: Text('Change Password',
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text('Update your journal credentials',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.outline)),
                          trailing: const Icon(Icons.chevron_right, size: 18),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password reset email sent')),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFBA1A1A),
                        ),
                        icon: const Icon(Icons.heart_broken, size: 18),
                        label: const Text('Permanently Delete Profile & Memories'),
                        onPressed: _showDeleteSanctuaryDialog,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Save Changes Pill Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _saveProfile,
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
