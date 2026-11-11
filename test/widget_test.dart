import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/main.dart';
void main() {
  testWidgets('ElectroDesign opens editor', (tester) async {
    await tester.pumpWidget(const ElectroDesignApp());
    expect(find.text('ElectroDesign'), findsOneWidget);
    expect(find.text('Mon schéma'), findsOneWidget);
    expect(find.byTooltip('Ouvrir un projet'), findsOneWidget);
    expect(find.byTooltip('Enregistrer le projet'), findsOneWidget);
    expect(find.byTooltip('Tracer une liaison'), findsOneWidget);
  });
}
