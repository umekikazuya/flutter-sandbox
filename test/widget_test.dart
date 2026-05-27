import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_sandbox/main.dart';

void main() {
  testWidgets('roulette screen shows initial state', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('ルーレット'), findsOneWidget);
    expect(find.text('候補がありません'), findsOneWidget);
    expect(find.text('結果: -'), findsOneWidget);
  });

  testWidgets('can add candidates and spin once two candidates exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byKey(const Key('candidateInput')), 'A');
    await tester.tap(find.byKey(const Key('addCandidateButton')));
    await tester.pump();
    expect(find.text('A'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('candidateInput')), 'B');
    await tester.tap(find.byKey(const Key('addCandidateButton')));
    await tester.pump();
    expect(find.text('候補: 2件'), findsOneWidget);

    await tester.tap(find.byKey(const Key('spinButton')));
    await tester.pump(const Duration(milliseconds: 2300));

    expect(find.textContaining('当選:'), findsOneWidget);
  });

  testWidgets('shows validation message for empty candidate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('addCandidateButton')));
    await tester.pump();

    expect(find.text('候補を入力してください'), findsOneWidget);
  });
}
