import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/models/project_document.dart';

void main() {
  final createdAt = DateTime.utc(2026, 11, 11, 8);
  final updatedAt = DateTime.utc(2026, 11, 11, 9);

  ProjectDocument sampleProject() => ProjectDocument(
        id: 'project-1',
        name: 'Installation domestique',
        createdAt: createdAt,
        updatedAt: updatedAt,
        components: const [
          ProjectComponent(
            id: 'component-1',
            name: 'Disjoncteur',
            family: 'Protection',
            symbol: 'QF',
            details: 'Protection contre les surintensités',
            x: 48,
            y: 72,
          ),
          ProjectComponent(
            id: 'component-2',
            name: 'Lampe',
            family: 'Domestique',
            symbol: 'L',
            details: 'Point lumineux',
            x: 168,
            y: 72,
          ),
        ],
        connections: const [
          ProjectConnection(
            id: 'connection-1',
            fromComponentId: 'component-1',
            fromTerminal: '2',
            toComponentId: 'component-2',
            toTerminal: 'L',
            conductor: 'phase',
          ),
        ],
      );

  test('project document survives a JSON round trip', () {
    final original = sampleProject();
    final restored = ProjectDocument.fromJson(original.toJson());

    expect(restored.schemaVersion, ProjectDocument.currentSchemaVersion);
    expect(restored.id, original.id);
    expect(restored.name, original.name);
    expect(restored.components, hasLength(2));
    expect(restored.components.last.x, 168);
    expect(restored.connections, hasLength(1));
    expect(restored.connections.single.fromTerminal, '2');
    expect(restored.connections.single.conductor, 'phase');
  });

  test('schema version 1 projects migrate with no invented terminals', () {
    final json = sampleProject().toJson()
      ..['schemaVersion'] = 1;
    for (final component in json['components'] as List) {
      (component as Map<String, Object?>).remove('terminals');
    }

    final restored = ProjectDocument.fromJson(json);
    expect(restored.schemaVersion, ProjectDocument.currentSchemaVersion);
    expect(restored.components.every((component) => component.terminals.isEmpty), isTrue);
  });

  test('verified terminal metadata survives JSON round trip', () {
    final json = sampleProject().toJson();
    final components = json['components'] as List;
    components[0] = {
      ...components[0] as Map<String, Object?>,
      'terminals': [
        {'id': '1', 'label': 'Entrée phase', 'x': 0.0, 'y': 0.5},
        {'id': '2', 'label': 'Sortie phase', 'x': 1.0, 'y': 0.5},
      ],
    };
    final restored = ProjectDocument.fromJson(json);
    expect(restored.components.first.terminals, hasLength(2));
    expect(restored.components.first.terminals.last.id, '2');
  });

  test('terminal coordinates outside component bounds are rejected', () {
    final json = sampleProject().toJson();
    final components = json['components'] as List;
    components[0] = {
      ...components[0] as Map<String, Object?>,
      'terminals': [
        {'id': 'L', 'label': 'Phase', 'x': 1.2, 'y': 0.5},
      ],
    };
    expect(
      () => ProjectDocument.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });

  test('connections cannot reference unknown configured terminals', () {
    final json = sampleProject().toJson();
    final components = json['components'] as List;
    components[0] = {
      ...components[0] as Map<String, Object?>,
      'terminals': [
        {'id': '1', 'label': 'Entrée', 'x': 0.0, 'y': 0.5},
      ],
    };
    expect(
      () => ProjectDocument.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });

  test('manufacturer protective device assignment survives JSON round trip', () {
    final json = sampleProject().toJson();
    final components = json['components'] as List;
    components[0] = {
      ...components[0] as Map<String, Object?>,
      'protectiveDeviceManufacturer': 'ABB',
      'protectiveDeviceReference': '2CDS272061R0024',
      'protectiveDeviceRatingType': 'ICN',
      'protectiveDeviceBreakingCapacityA': 10000,
      'protectiveDeviceBreakingStandard': 'IEC/EN 60898-2',
      'protectiveDeviceBreakingVoltageV': 400,
      'protectiveDeviceRatedCurrentA': 2,
    };
    final restored = ProjectDocument.fromJson(json);
    expect(restored.components.first.protectiveDeviceManufacturer, 'ABB');
    expect(restored.components.first.protectiveDeviceReference, '2CDS272061R0024');
    expect(restored.components.first.protectiveDeviceRatingType, 'ICN');
    expect(restored.components.first.protectiveDeviceBreakingCapacityA, 10000);
    expect(restored.components.first.protectiveDeviceBreakingVoltageV, 400);
  });

  test('legacy schema version 2 projects remain readable', () {
    final json = sampleProject().toJson()..['schemaVersion'] = 2;
    final restored = ProjectDocument.fromJson(json);
    expect(restored.schemaVersion, ProjectDocument.currentSchemaVersion);
    expect(restored.components.first.protectiveDeviceReference, isNull);
  });

  test('unknown schema versions are rejected', () {
    final json = sampleProject().toJson()..['schemaVersion'] = 99;

    expect(
      () => ProjectDocument.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });

  test('connections to missing components are rejected', () {
    final json = sampleProject().toJson();
    final connections = json['connections'] as List;
    connections[0] = {
      ...connections[0] as Map<String, Object?>,
      'toComponentId': 'missing-component',
    };

    expect(
      () => ProjectDocument.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });

  test('duplicate component identifiers are rejected', () {
    expect(
      () => ProjectDocument(
        id: 'project-2',
        name: 'Projet invalide',
        createdAt: createdAt,
        updatedAt: updatedAt,
        components: const [
          ProjectComponent(
            id: 'same-id',
            name: 'Disjoncteur',
            family: 'Protection',
            symbol: 'QF',
            details: '',
            x: 0,
            y: 0,
          ),
          ProjectComponent(
            id: 'same-id',
            name: 'Lampe',
            family: 'Domestique',
            symbol: 'L',
            details: '',
            x: 24,
            y: 0,
          ),
        ],
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
