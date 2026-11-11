import 'package:flutter/material.dart';

import '../../../domain/models/electrical_part.dart';
import '../../../domain/models/project_document.dart';

class GridPainter extends CustomPainter {
  GridPainter(
    this.items,
    this.selected, {
    this.connections = const [],
    this.pendingWireStart,
  });

  final List<PlacedPart> items;
  final int? selected;
  final List<ProjectConnection> connections;
  final int? pendingWireStart;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 24.0;
    final grid = Paint()
      ..color = const Color(0xFFE3E9EC)
      ..strokeWidth = .6;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final wirePaint = Paint()
      ..color = const Color(0xFF087E8B)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (final connection in connections) {
      final from = _indexOf(connection.fromComponentId);
      final to = _indexOf(connection.toComponentId);
      if (from == null || to == null) continue;
      canvas.drawLine(items[from].position, items[to].position, wirePaint);
      canvas.drawCircle(items[from].position, 3, Paint()..color = wirePaint.color);
      canvas.drawCircle(items[to].position, 3, Paint()..color = wirePaint.color);
    }

    if (pendingWireStart != null && pendingWireStart! < items.length) {
      final pendingPaint = Paint()
        ..color = const Color(0xFFE09F3E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(items[pendingWireStart!].position, 30, pendingPaint);
    }

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final center = item.position;
      final paint = Paint()
        ..color = (i == selected
            ? const Color(0xFF087E8B)
            : const Color(0xFF263746))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 54, height: 40),
        paint,
      );
      final symbol = TextPainter(
        text: TextSpan(
          text: item.part.symbol,
          style: TextStyle(
            color: paint.color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 50);
      symbol.paint(
        canvas,
        center - Offset(symbol.width / 2, symbol.height / 2),
      );
      final label = TextPainter(
        text: TextSpan(
          text: item.part.name,
          style: const TextStyle(
            color: Color(0xFF34495E),
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 110);
      label.paint(canvas, center + Offset(-label.width / 2, 23));
    }
  }

  int? _indexOf(String componentId) {
    if (!componentId.startsWith('component-')) return null;
    final index = int.tryParse(
      componentId.substring('component-'.length),
    );
    if (index == null || index < 1 || index > items.length) return null;
    return index - 1;
  }

  @override
  bool shouldRepaint(covariant GridPainter old) =>
      old.items != items ||
      old.selected != selected ||
      old.connections != connections ||
      old.pendingWireStart != pendingWireStart;
}
