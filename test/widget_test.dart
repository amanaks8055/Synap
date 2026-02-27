import 'package:flutter_test/flutter_test.dart';
import 'package:synap/main.dart';

void main() {
  testWidgets('App launches', (tester) async {
    await tester.pumpWidget(const SynapApp());
    expect(find.text('Synap'), findsOneWidget);
  });
}
