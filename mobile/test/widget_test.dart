import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/main.dart';

void main() {
  testWidgets('App renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const DeliveryApp());
    expect(find.text('Delivery Store'), findsNothing);
  });
}
