// Subtle zellige-inspired geometric pattern for the home header.
//
// A low-alpha lattice of eight-pointed stars over the brand gradient.
// Kept deliberately faint so header text stays readable in both
// brightness modes.
import 'package:flutter/material.dart';

class ZelligePattern extends StatelessWidget {
  const ZelligePattern({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _ZelligePainter()),
      ),
    );
  }
}

/// Wraps [child] with the zellige pattern painted behind it. Unlike
/// [ZelligePattern] (for full-screen stacks), this sizes itself to the
/// child, so it works inside columns.
class ZelligeBackground extends StatelessWidget {
  const ZelligeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _ZelligePainter(), child: child);
  }
}

class _ZelligePainter extends CustomPainter {
  const _ZelligePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const double step = 44;
    // Diamond lattice + inscribed squares suggest zellige stars.
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final Path diamond = Path()
          ..moveTo(x, y - step / 2)
          ..lineTo(x + step / 2, y)
          ..lineTo(x, y + step / 2)
          ..lineTo(x - step / 2, y)
          ..close();
        canvas.drawPath(diamond, paint);
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: step / 3, height: step / 3),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
