import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../domain/models/project_document.dart';

/// Import/export of portable ElectroDesign JSON project files.
class ProjectFileService {
  static Future<bool> saveProject(ProjectDocument project) async {
    final contents = const JsonEncoder.withIndent('  ').convert(project.toJson());
    final destination = await FilePicker.platform.saveFile(
      dialogTitle: 'Enregistrer le projet ElectroDesign',
      fileName: 'electrodesign-project.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: Uint8List.fromList(utf8.encode(contents)),
    );
    return destination != null;
  }

  static Future<ProjectDocument?> openProject() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final bytes = result.files.single.bytes;
    if (bytes == null) {
      throw const FormatException('Unable to read the selected project file');
    }
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid ElectroDesign project file');
    }
    return ProjectDocument.fromJson(decoded);
  }
}
