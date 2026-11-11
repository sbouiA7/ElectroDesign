import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/models/project_document.dart';

/// Local, persistent project library shared by Android and Windows.
class ProjectLibraryService {
  ProjectLibraryService({Directory? rootDirectory})
      : _rootDirectory = rootDirectory;

  final Directory? _rootDirectory;

  Future<Directory> _projectsDirectory() async {
    final root = _rootDirectory ?? await getApplicationSupportDirectory();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}ElectroDesign'
      '${Platform.pathSeparator}projects',
    );
    await directory.create(recursive: true);
    return directory;
  }

  String _fileName(String projectId) {
    final safeId = projectId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    if (safeId.isEmpty) {
      throw const FormatException('Invalid project identifier');
    }
    return '$safeId.json';
  }

  /// Saves through a temporary file and keeps a recoverable previous copy
  /// until the replacement has been moved into place.
  Future<void> saveProject(ProjectDocument project) async {
    project.validate();
    final directory = await _projectsDirectory();
    final destination = File(
      '${directory.path}${Platform.pathSeparator}${_fileName(project.id)}',
    );
    final temporary = File('${destination.path}.tmp');
    final backup = File('${destination.path}.bak');
    final contents =
        const JsonEncoder.withIndent('  ').convert(project.toJson());

    await temporary.writeAsString(contents, flush: true);
    var movedPrevious = false;
    try {
      if (await destination.exists()) {
        if (await backup.exists()) await backup.delete();
        await destination.rename(backup.path);
        movedPrevious = true;
      }
      await temporary.rename(destination.path);
      if (movedPrevious && await backup.exists()) await backup.delete();
    } catch (_) {
      if (await temporary.exists()) await temporary.delete();
      if (movedPrevious && !await destination.exists() && await backup.exists()) {
        await backup.rename(destination.path);
      }
      rethrow;
    }
  }

  Future<ProjectDocument?> loadProject(String projectId) async {
    final directory = await _projectsDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}${_fileName(projectId)}',
    );
    if (!await file.exists()) return null;
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid saved ElectroDesign project');
    }
    return ProjectDocument.fromJson(decoded);
  }

  /// Returns valid projects, newest modification first. Corrupt files are
  /// left untouched so that a recovery attempt remains possible.
  Future<List<ProjectDocument>> listProjects() async {
    final directory = await _projectsDirectory();
    final projects = <ProjectDocument>[];
    await for (final entity in directory.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      try {
        final decoded = jsonDecode(await entity.readAsString());
        if (decoded is Map<String, dynamic>) {
          projects.add(ProjectDocument.fromJson(decoded));
        }
      } on FormatException {
        // Keep malformed files on disk; do not silently delete user data.
      } on TypeError {
        // Keep malformed files on disk; do not silently delete user data.
      }
    }
    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  Future<void> deleteProject(String projectId) async {
    final directory = await _projectsDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}${_fileName(projectId)}',
    );
    if (await file.exists()) await file.delete();
  }
}
