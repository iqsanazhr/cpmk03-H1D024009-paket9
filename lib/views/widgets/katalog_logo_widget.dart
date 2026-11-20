import 'package:flutter/material.dart';

/// WIDGET: Logo Resmi KatalogKu UMKM
/// Menggantikan logo Coinbase dengan emblem identitas mandiri:
/// - Bentuk squircle modern dengan palet Royal Blue (#0052FF) & Emerald Green (#10B981)
/// - Ikon etalase toko (storefront) geometris berpadu dengan kotak inventori dan panah pertumbuhan laba
class KatalogLogoWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showBackground;

  const KatalogLogoWidget({
    super.key,
    this.size = 56,
    this.color,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showBackground) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0052FF),
              Color(0xFF0041CC),
            ],
          ),
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0052FF).withOpacity(0.32),
              blurRadius: size * 0.35,
              offset: Offset(0, size * 0.12),
            ),
          ],
        ),
        child: Center(
          child: CustomPaint(
            size: Size(size * 0.58, size * 0.58),
            painter: _KatalogLogoPainter(color ?? Colors.white),
          ),
        ),
      );
    }

    return CustomPaint(
      size: Size(size, size),
      painter: _KatalogLogoPainter(color ?? const Color(0xFF0052FF)),
    );
  }
}

class _KatalogLogoPainter extends CustomPainter {
  final Color color;

  _KatalogLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Gambar atap kanopi etalase toko (Storefront Awning)
    final awningPath = Path()
      ..moveTo(w * 0.15, h * 0.38)
      ..lineTo(w * 0.85, h * 0.38)
      ..lineTo(w * 0.78, h * 0.16)
      ..cubicTo(w * 0.76, h * 0.12, w * 0.72, h * 0.10, w * 0.68, h * 0.10)
      ..lineTo(w * 0.32, h * 0.10)
      ..cubicTo(w * 0.28, h * 0.10, w * 0.24, h * 0.12, w * 0.22, h * 0.16)
      ..close();

    canvas.drawPath(awningPath, fillPaint);

    // 2. Kotak Badan Toko / Box Katalog Inventori
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.44, w * 0.64, h * 0.46),
      Radius.circular(w * 0.14),
    );
    canvas.drawRRect(bodyRect, strokePaint);

    // 3. Panah Pertumbuhan Margin & Laba ke Atas (Growth Arrow)
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final arrowPath = Path()
      // Garis vertikal
      ..moveTo(w * 0.50, h * 0.76)
      ..lineTo(w * 0.50, h * 0.54)
      // Sayap panah kiri
      ..moveTo(w * 0.38, h * 0.64)
      ..lineTo(w * 0.50, h * 0.52)
      // Sayap panah kanan
      ..lineTo(w * 0.62, h * 0.64);

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _KatalogLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
