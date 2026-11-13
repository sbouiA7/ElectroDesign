import 'package:material_ui/material_ui.dart';

import '../../../domain/models/electrical_part.dart';
import '../../../domain/models/electrical_terminal.dart';
import '../../../domain/models/project_document.dart';

class GridPainter extends CustomPainter {
  GridPainter(
    List<PlacedPart> items,
    this.selected, {
    List<ProjectConnection> connections = const [],
    this.pendingWireStart,
  })  : items = List<PlacedPart>.unmodifiable(items),
        connections = List<ProjectConnection>.unmodifiable(connections);

  // Keep immutable snapshots: the editor mutates its working lists in place,
  // and the previous painter must retain the old values for repaint checks.
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
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final connection in connections) {
      final fromIndex = items.indexWhere((item) => item.id == connection.fromComponentId);
      final toIndex = items.indexWhere((item) => item.id == connection.toComponentId);
      if (fromIndex < 0 || toIndex < 0) continue;
      final fromPart = items[fromIndex];
      final toPart = items[toIndex];
      final fromTerminal = _terminalById(fromPart, connection.fromTerminal);
      final toTerminal = _terminalById(toPart, connection.toTerminal);
      // Never draw a wire from component centers or guessed terminals.
      if (fromTerminal == null || toTerminal == null) continue;
      final start = _terminalPosition(fromPart, fromTerminal);
      final end = _terminalPosition(toPart, toTerminal);
      final middleX = (start.dx + end.dx) / 2;
      final route = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(middleX, start.dy)
        ..lineTo(middleX, end.dy)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(route, wirePaint);
      canvas.drawCircle(start, 3.5, Paint()..color = wirePaint.color);
      canvas.drawCircle(end, 3.5, Paint()..color = wirePaint.color);
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
      final bounds = Rect.fromCenter(center: center, width: 54, height: 40);
      for (final terminal in item.part.terminals) {
        final terminalPoint = Offset(
          bounds.left + terminal.x * bounds.width,
          bounds.top + terminal.y * bounds.height,
        );
        canvas.drawCircle(
          terminalPoint,
          3.5,
          Paint()..color = const Color(0xFF087E8B),
        );
        final terminalLabel = TextPainter(
          text: TextSpan(
            text: terminal.label,
            style: const TextStyle(
              color: Color(0xFF087E8B),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 42);
        final labelOffset = Offset(
          terminalPoint.dx - terminalLabel.width / 2,
          terminalPoint.dy - 13,
        );
        terminalLabel.paint(canvas, labelOffset);
      }

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



  ElectricalTerminal? _terminalById(PlacedPart part, String id) {
    for (final terminal in part.part.terminals) {
      if (terminal.id == id) return terminal;
    }
    return null;
  }

  Offset _terminalPosition(PlacedPart part, ElectricalTerminal terminal) {
    const width = 54.0;
    const height = 40.0;
    final left = part.position.dx - width / 2;
    final top = part.position.dy - height / 2;
    return Offset(left + terminal.x * width, top + terminal.y * height);
  }

  @override
  bool shouldRepaint(covariant GridPainter old) =>
      old.items != items ||
      old.selected != selected ||
      old.connections != connections ||
      old.pendingWireStart != pendingWireStart;
}
