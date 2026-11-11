import 'package:flutter/material.dart';

import '../../../domain/models/electrical_part.dart';

class GridPainter extends CustomPainter {
  GridPainter(this.items, this.selected);
  final List<PlacedPart> items;
  final int? selected;
  @override
  void paint(Canvas canvas, Size size) {
    const step = 24.0;
    final grid = Paint()..color = const Color(0xFFE3E9EC)..strokeWidth = .6;
    for (double x = 0; x < size.width; x += step) { canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid); }
    for (double y = 0; y < size.height; y += step) { canvas.drawLine(Offset(0, y), Offset(size.width, y), grid); }
    for (var i = 0; i < items.length; i++) {
      final item = items[i]; final c = item.position;
      final p = Paint()..color = (i == selected ? const Color(0xFF087E8B) : const Color(0xFF263746))..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawRect(Rect.fromCenter(center: c, width: 54, height: 40), p);
      final symbol = TextPainter(text: TextSpan(text: item.part.symbol, style: TextStyle(color: p.color, fontSize: 12, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout(maxWidth: 50);
      symbol.paint(canvas, c - Offset(symbol.width / 2, symbol.height / 2));
      final label = TextPainter(text: TextSpan(text: item.part.name, style: const TextStyle(color: Color(0xFF34495E), fontSize: 9)), textDirection: TextDirection.ltr)..layout(maxWidth: 110);
      label.paint(canvas, c + Offset(-label.width / 2, 23));
    }
  }
  @override
  bool shouldRepaint(covariant GridPainter old) => old.items != items || old.selected != selected;
}
