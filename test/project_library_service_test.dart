import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/models/project_document.dart';
import 'package:electro_design/services/project_library_service.dart';

void main() {
  late Directory temporaryDirectory;
  late ProjectLibraryService library;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('electrodesign-test-');
    library = ProjectLibraryService(rootDirectory: temporaryDirectory);
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  ProjectDocument project({
    String id = 'project-1',
    String name = 'Installation domestique',
    DateTime? updatedAt,
  }) {
    final created = DateTime.utc(2026, 1, 1);
    return ProjectDocument(
      id: id,
      name: name,
      createdAt: created,
      updatedAt: updatedAt ?? created,
    );
  }

  test('saves and reopens a project from the persistent library', () async {
    await library.saveProject(project());
    final restored = await library.loadProject('project-1');

    expect(restored, isNotNull);
    expect(restored!.name, 'Installation domestique');
    expect(restored.id, 'project-1');
  });

  test('updates an existing project without creating duplicates', () async {
    await library.saveProject(project());
    await library.saveProject(project(
      name: 'Installation modifiée',
      updatedAt: DateTime.utc(2026, 1, 2),
    ));

    final projects = await library.listProjects();
    expect(projects, hasLength(1));
    expect(projects.single.name, 'Installation modifiée');
  });

  test('lists projects with the newest modification first', () async {
    await library.saveProject(project(id: 'older'));
    await library.saveProject(project(
      id: 'newer',
      name: 'Projet récent',
      updatedAt: DateTime.utc(2026, 1, 3),
    ));

    final projects = await library.listProjects();
    expect(projects.map((item) => item.id), ['newer', 'older']);
  });

  test('deletes only the selected project', () async {
    await library.saveProject(project());
    await library.saveProject(project(id: 'project-2', name: 'Autre'));

    await library.deleteProject('project-1');

    expect(await library.loadProject('project-1'), isNull);
    expect(await library.loadProject('project-2'), isNotNull);
  });
}
