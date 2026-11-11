import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electro_design/domain/models/electrical_part.dart';
import 'package:electro_design/domain/models/project_document.dart';
import 'package:electro_design/features/editor/widgets/grid_painter.dart';

void main() {
  test('GridPainter keeps snapshots when editor lists are mutated', () {
    final placed = <PlacedPart>[];
    final connections = <ProjectConnection>[];
    final before = GridPainter(placed, null, connections: connections);

    placed.add(
      PlacedPart(
        const Part('Lampe', 'Domestique', 'L', 'Point lumineux'),
        Offset.zero,
      ),
    );
    connections.add(
      const ProjectConnection(
        id: 'connection-1',
        fromComponentId: 'component-1',
        fromTerminal: 'L',
        toComponentId: 'component-2',
        toTerminal: 'N',
      ),
    );

    final after = GridPainter(placed, null, connections: connections);

    expect(before.items, isEmpty);
    expect(before.connections, isEmpty);
    expect(after.items, hasLength(1));
    expect(after.connections, hasLength(1));
    expect(after.shouldRepaint(before), isTrue);
  });
}
