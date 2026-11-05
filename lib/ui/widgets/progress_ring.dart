import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key, required this.progress, required this.child,
    this.size = 240, this.strokeWidth = 18, this.trackColor, this.progressColor,
  });

  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress, strokeWidth: strokeWidth,
                trackColor: trackColor ?? scheme.onSurface.withValues(alpha: 0.10),
                progressColor: progressColor ?? scheme.primary,
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(strokeWidth + 12), child: child),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.strokeWidth, required this.trackColor, required this.progressColor});
  final double progress; final double strokeWidth; final Color trackColor; final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    if (radius <= 0) return;

    final trackPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    final clamped = progress.clamp(0.0, 1.0).toDouble();
    if (clamped <= 0) return;

    final progressPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round..color = progressColor;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * clamped, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.strokeWidth != strokeWidth || old.trackColor != trackColor || old.progressColor != progressColor;
}
