import 'package:flutter/material.dart';
import 'dart:ui' as ui;

enum VSTheme {
  pink,
  dark,
  white,
}

class VSImageWidget extends StatefulWidget {
  final VSTheme theme;
  final double width;
  final double height;

  const VSImageWidget({
    super.key,
    required this.theme,
    this.width = 80,
    this.height = 40,
  });

  @override
  State<VSImageWidget> createState() => _VSImageWidgetState();
}

class _VSImageWidgetState extends State<VSImageWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: VSPainter(theme: widget.theme),
    );
  }

  @override
  void didUpdateWidget(VSImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Theme değiştiğinde widget'ı yenile
    if (oldWidget.theme != widget.theme) {
      // debugPrint('🔄 VS WIDGET THEME CHANGED: ${oldWidget.theme.name} -> ${widget.theme.name}');
      setState(() {});
    }
  }
}

class VSPainter extends CustomPainter {
  final VSTheme theme;

  VSPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // debugPrint('🎨 VS PAINTER DRAWING: ${theme.name} theme');
    switch (theme) {
      case VSTheme.pink:
        _drawPinkTheme(canvas, size);
        break;
      case VSTheme.dark:
        _drawDarkTheme(canvas, size);
        break;
      case VSTheme.white:
        _drawWhiteTheme(canvas, size);
        break;
    }
  }

  void _drawPinkTheme(Canvas canvas, Size size) {
    // Pink theme - cosmic galaxy VS with metallic outline (no splatter background, use container background)
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.amber;

    // Draw V
    final vPath = Path();
    vPath.moveTo(size.width * 0.15, size.height * 0.1);
    vPath.lineTo(size.width * 0.25, size.height * 0.7);
    vPath.lineTo(size.width * 0.35, size.height * 0.1);
    vPath.lineTo(size.width * 0.32, size.height * 0.1);
    vPath.lineTo(size.width * 0.27, size.height * 0.65);
    vPath.lineTo(size.width * 0.23, size.height * 0.65);
    vPath.lineTo(size.width * 0.18, size.height * 0.1);
    vPath.close();

    // Draw S
    final sPath = Path();
    sPath.moveTo(size.width * 0.55, size.height * 0.15);
    sPath.arcToPoint(Offset(size.width * 0.75, size.height * 0.3), 
                     radius: const Radius.circular(15));
    sPath.lineTo(size.width * 0.8, size.height * 0.3);
    sPath.arcToPoint(Offset(size.width * 0.65, size.height * 0.5), 
                     radius: const Radius.circular(15));
    sPath.arcToPoint(Offset(size.width * 0.85, size.height * 0.7), 
                     radius: const Radius.circular(15));
    sPath.lineTo(size.width * 0.85, size.height * 0.8);
    sPath.arcToPoint(Offset(size.width * 0.55, size.height * 0.85), 
                     radius: const Radius.circular(15));

    // Fill letters with gradient effect (simplified)
    final letterPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height),
        [Colors.purple, Colors.pink, Colors.purple],
        [0.0, 0.5, 1.0],
      );

    canvas.drawPath(vPath, letterPaint);
    canvas.drawPath(sPath, letterPaint);

    // Draw metallic outline
    canvas.drawPath(vPath, outlinePaint);
    canvas.drawPath(sPath, outlinePaint);

    // Draw light beam effect
    final lightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.24, 0, size.width * 0.02, size.height),
      lightPaint,
    );
  }

  void _drawDarkTheme(Canvas canvas, Size size) {
    // Dark theme - VS with lightning bolt (no background, use container background)

    // Draw lightning bolt
    final lightningPath = Path();
    lightningPath.moveTo(size.width * 0.9, size.height * 0.1);
    lightningPath.lineTo(size.width * 0.6, size.height * 0.4);
    lightningPath.lineTo(size.width * 0.7, size.height * 0.5);
    lightningPath.lineTo(size.width * 0.3, size.height * 0.8);
    lightningPath.lineTo(size.width * 0.35, size.height * 0.85);
    lightningPath.lineTo(size.width * 0.75, size.height * 0.55);
    lightningPath.lineTo(size.width * 0.65, size.height * 0.45);
    lightningPath.close();

    final lightningPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;

    canvas.drawPath(lightningPath, lightningPaint);

    // Draw V with glowing effect
    final vPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;

    final vPath = Path();
    vPath.moveTo(size.width * 0.15, size.height * 0.1);
    vPath.lineTo(size.width * 0.25, size.height * 0.7);
    vPath.lineTo(size.width * 0.35, size.height * 0.1);
    vPath.lineTo(size.width * 0.32, size.height * 0.1);
    vPath.lineTo(size.width * 0.27, size.height * 0.65);
    vPath.lineTo(size.width * 0.23, size.height * 0.65);
    vPath.lineTo(size.width * 0.18, size.height * 0.1);
    vPath.close();

    // Draw S with glowing effect
    final sPath = Path();
    sPath.moveTo(size.width * 0.55, size.height * 0.15);
    sPath.arcToPoint(Offset(size.width * 0.75, size.height * 0.3), 
                     radius: const Radius.circular(15));
    sPath.lineTo(size.width * 0.8, size.height * 0.3);
    sPath.arcToPoint(Offset(size.width * 0.65, size.height * 0.5), 
                     radius: const Radius.circular(15));
    sPath.arcToPoint(Offset(size.width * 0.85, size.height * 0.7), 
                     radius: const Radius.circular(15));
    sPath.lineTo(size.width * 0.85, size.height * 0.8);
    sPath.arcToPoint(Offset(size.width * 0.55, size.height * 0.85), 
                     radius: const Radius.circular(15));

    canvas.drawPath(vPath, vPaint);
    canvas.drawPath(sPath, vPaint);

    // Add white outline
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;

    canvas.drawPath(vPath, outlinePaint);
    canvas.drawPath(sPath, outlinePaint);
  }

  void _drawWhiteTheme(Canvas canvas, Size size) {
    // White theme - turuncu VS (beyaz arka plan içinde turuncu)

    // Draw V
    final vPath = Path();
    vPath.moveTo(size.width * 0.15, size.height * 0.1);
    vPath.lineTo(size.width * 0.25, size.height * 0.7);
    vPath.lineTo(size.width * 0.35, size.height * 0.1);
    vPath.lineTo(size.width * 0.32, size.height * 0.1);
    vPath.lineTo(size.width * 0.27, size.height * 0.65);
    vPath.lineTo(size.width * 0.23, size.height * 0.65);
    vPath.lineTo(size.width * 0.18, size.height * 0.1);
    vPath.close();

    // Draw S
    final sPath = Path();
    sPath.moveTo(size.width * 0.55, size.height * 0.15);
    sPath.arcToPoint(Offset(size.width * 0.75, size.height * 0.3), 
                     radius: const Radius.circular(15));
    sPath.lineTo(size.width * 0.8, size.height * 0.3);
    sPath.arcToPoint(Offset(size.width * 0.65, size.height * 0.5), 
                     radius: const Radius.circular(15));
    sPath.arcToPoint(Offset(size.width * 0.85, size.height * 0.7), 
                     radius: const Radius.circular(15));
    sPath.lineTo(size.width * 0.85, size.height * 0.8);
    sPath.arcToPoint(Offset(size.width * 0.55, size.height * 0.85), 
                     radius: const Radius.circular(15));

    // Create turuncu gradient (logodaki turuncu tonları)
    final orangePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height),
        [
          const Color(0xFFFF6B35), // Ana turuncu ton
          const Color(0xFFFF8C42), // Açık turuncu ton
          const Color(0xFFE55A2B), // Koyu turuncu ton
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawPath(vPath, orangePaint);
    canvas.drawPath(sPath, orangePaint);

    // Add subtle outline for better visibility
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFFF6B35).withValues(alpha: 0.3);

    canvas.drawPath(vPath, outlinePaint);
    canvas.drawPath(sPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is VSPainter && oldDelegate.theme != theme;
  }
}
