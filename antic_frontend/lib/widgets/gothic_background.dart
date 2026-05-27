import 'dart:math';

import 'package:flutter/material.dart';

class GothicBackground extends StatelessWidget {
  final Widget child;
  const GothicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF050505),
            Color(0xFF0B0B0B),
            Color(0xFF070707),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GothicPatternPainter(),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: const _GothicVignette(),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GothicVignette extends StatelessWidget {
  const _GothicVignette();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 1.1,
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 166),
          ],
        ),
      ),
    );
  }
}

class _GothicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x33FFFFFF);

    // A rough version of repeating-linear-gradient from the HTML reference.
    const spacing = 24.0;
    for (double x = 0; x <= size.width + spacing; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height + spacing; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Subtle “cross” stripes for texture.
    final diagPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x1FFFFFFF);

    final diagStep = 48.0;
    final diagAngle = 18 * pi / 180;
    final dx = cos(diagAngle);
    final dy = sin(diagAngle);

    for (double i = -size.height; i < size.width; i += diagStep) {
      final p1 = Offset(i, 0);
      final p2 = Offset(i + size.width * dx, size.height * dy);
      canvas.drawLine(p1, p2, diagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

