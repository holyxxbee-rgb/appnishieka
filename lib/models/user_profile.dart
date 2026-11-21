class UserProfile {
  String firstName;
  String lastName;
  String email;
  String bio;
  String diaryTitle;
  String memoryMilestone;
  String reminderTime;
  bool notebookRuledLines;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.bio,
    required this.diaryTitle,
    required this.memoryMilestone,
    required this.reminderTime,
    this.notebookRuledLines = true,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'bio': bio,
        'diaryTitle': diaryTitle,
        'memoryMilestone': memoryMilestone,
        'reminderTime': reminderTime,
        'notebookRuledLines': notebookRuledLines,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        firstName: json['firstName'] ?? 'Sarah',
        lastName: json['lastName'] ?? 'Jenkins',
        email: json['email'] ?? 'sarah.jenkins@gmail.com',
        bio: json['bio'] ??
            'Capturing golden moments, quiet rain, and chamomile thoughts 🌸☕',
        diaryTitle: json['diaryTitle'] ?? "Sarah's Quiet Sanctuary",
        memoryMilestone: json['memoryMilestone'] ?? 'April 14',
        reminderTime: json['reminderTime'] ?? '8:30 PM',
        notebookRuledLines: json['notebookRuledLines'] ?? true,
      );
}
