import 'package:everus/data/questionnaire_data.dart';
import 'package:everus/screens/login/widgets/profile_view.dart';
import 'package:everus/screens/questionnaire_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetAppState());

  testWidgets('profile view offers editing questionnaire answers', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ProfileView(
          name: 'A',
          email: 'a@b.c',
          isLoading: false,
          onSignOut: () {},
          onEditAnswers: () => tapped = true,
        ),
      ),
    ));

    await tester.tap(find.text('Chỉnh sửa câu trả lời'));
    expect(tapped, isTrue);
  });

  testWidgets('edit mode is pre-filled, has no skip-all, and saves with PUT', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    logIn();
    final backend = RecordingClient((_) => jsonResponse({'success': true}));
    final firstOption = coupleQuestions.first.options.first;
    var completed = false;

    await tester.pumpWidget(MaterialApp(
      home: QuestionnaireScreen(
        isEditMode: true,
        initialAnswers: {'q1': [firstOption]},
        onCompleted: () => completed = true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Bỏ qua tất cả'), findsNothing);
    expect(find.byIcon(Icons.check), findsOneWidget);

    for (var i = 0; i < coupleQuestions.length - 1; i++) {
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();

    final put = backend.to('PUT', '/questionnaire/submit').single;
    expect(put.json['answers']['q1'], [firstOption]);
    expect(backend.to('POST', '/questionnaire/submit'), isEmpty);
    expect(completed, isTrue);
  });
}
