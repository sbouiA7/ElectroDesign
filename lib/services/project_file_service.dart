import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_selector/file_selector.dart';

import '../domain/models/project_document.dart';

/// Import/export of portable ElectroDesign JSON project files.
class ProjectFileService {
  static const _projectType = XTypeGroup(
    label: 'Projet ElectroDesign',
    extensions: ['json'],
  );

  static Future<bool> saveProject(ProjectDocument project) async {
    final destination = await getSaveLocation(
      suggestedName: 'electrodesign-project.json',
      acceptedTypeGroups: [_projectType],
    );
    if (destination == null) return false;

    final contents = const JsonEncoder.withIndent('  ').convert(project.toJson());
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(contents)),
      name: 'electrodesign-project.json',
      mimeType: 'application/json',
    );
    await file.saveTo(destination.path);
    return true;
  }

  static Future<ProjectDocument?> openProject() async {
    final file = await openFile(
      acceptedTypeGroups: [_projectType],
    );
    if (file == null) return null;

    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid ElectroDesign project file');
    }
    return ProjectDocument.fromJson(decoded);
  }
}
