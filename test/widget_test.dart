import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appnishieka/main.dart';
import 'package:appnishieka/providers/diary_provider.dart';
import 'package:appnishieka/models/diary_entry.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUp(() {
    HttpOverrides.global = _TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SnapDiaryApp full flow test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final provider = DiaryProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const SnapDiaryApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Dashboard displays
    expect(find.text('SnapDiary'), findsOneWidget);
    expect(find.text('Hello, Sarah!'), findsOneWidget);
    expect(find.text('Recent Moments'), findsOneWidget);

    // 2. Open Add Entry flow
    final captureBanner = find.text('Capture This Moment');
    expect(captureBanner, findsOneWidget);
    await tester.tap(captureBanner);
    await tester.pumpAndSettle();

    expect(find.text('New Entry'), findsOneWidget);

    // 3. Test back navigation
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.text('Recent Moments'), findsOneWidget);

    // 4. Test provider state manipulation & UI reactivity
    await provider.addEntry(
      DiaryEntry(
        id: 'test_123',
        title: 'A Golden Evening',
        content: 'Watching the sunset through the window with warm chamomile tea.',
        date: DateTime.now(),
        mood: 'Cozy',
        moodEmoji: '☕',
        tags: ['cozy', 'tea'],
        isFavorite: true,
      ),
    );
    await tester.pumpAndSettle();

    // Verify newly added entry shows on Dashboard
    expect(find.text('A Golden Evening'), findsOneWidget);

    // 5. Navigate to My Diary tab
    await tester.tap(find.text('My Diary'));
    await tester.pumpAndSettle();
    expect(find.text('A Golden Evening'), findsOneWidget);

    // 6. Test search filter
    await tester.enterText(
        find.widgetWithText(TextField, 'Search your thoughts, tags, or memories...'),
        'Golden');
    await tester.pumpAndSettle();
    expect(find.text('A Golden Evening'), findsOneWidget);

    // Test search filter without match
    await tester.enterText(
        find.widgetWithText(TextField, 'Search your thoughts, tags, or memories...'),
        'NonExistentQueryXYZ');
    await tester.pumpAndSettle();
    expect(find.text('No Memories Found'), findsOneWidget);

    // Clear search
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('A Golden Evening'), findsOneWidget);

    // 7. Navigate to Favorites tab
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('A Golden Evening'), findsOneWidget);

    // 8. Navigate to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Sarah Jenkins'), findsOneWidget);

    // 9. Open Edit Profile screen
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // Scroll down to ensure button is visible then save
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Edit bio and save
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Capturing golden moments, quiet rain, and chamomile thoughts 🌸☕'),
        'Updated Bio: Embracing peace and mindfulness everyday ✨');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Check updated bio reflected on Profile screen
    expect(find.text('Updated Bio: Embracing peace and mindfulness everyday ✨'),
        findsOneWidget);
  });
}
