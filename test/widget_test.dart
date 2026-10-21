import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aspan/main.dart';

void main() {
  testWidgets('Demo renders on a small phone and forecast scrolls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(find.text('Алматы'), findsOneWidget);
    expect(find.textContaining('Демо көрініс'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Алдағы күндер'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Empty search leaves the demo visible', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Алматы'), findsOneWidget);
  });
}
