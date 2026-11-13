import 'package:material_ui/material_ui.dart';

import '../features/editor/editor_page.dart';

class ElectroDesignApp extends StatelessWidget {
  const ElectroDesignApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ElectroDesign',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087E8B)), useMaterial3: true),
    home: const EditorPage(),
  );
}
