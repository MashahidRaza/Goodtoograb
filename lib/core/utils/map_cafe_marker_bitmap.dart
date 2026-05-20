import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../features/discover/domain/entities/store_item.dart';

/// Builds a map pin bitmap: circular café image + name (2 lines max).
/// Later your API can fill [StoreItem.logoUrl], [StoreItem.name], lat/lng — same pipeline.
Future<BitmapDescriptor?> buildCafeMarkerBitmap(
  StoreItem store, {
  required double pixelRatio,
}) async {
  const double logicalW = 152;
  const double imgDiameter = 48;
  const double pad = 8;

  ui.Image? photo;
  try {
    final uri = Uri.parse(store.logoUrl);
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      final codec = await ui.instantiateImageCodec(
        response.bodyBytes,
        targetWidth: (imgDiameter * pixelRatio).round(),
      );
      final frame = await codec.getNextFrame();
      photo = frame.image;
    }
  } catch (_) {
    photo = null;
  }

  final namePainter = TextPainter(
    text: TextSpan(
      text: store.name,
      style: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 2,
    ellipsis: '…',
  )..layout(maxWidth: logicalW - pad * 2);

  final textH = namePainter.height;
  final logicalH = pad + imgDiameter + 6 + textH + pad;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final shadowPaint = Paint()
    ..color = Colors.black26
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  final cardRrect = RRect.fromRectAndRadius(
    Rect.fromLTWH(2, 2, logicalW, logicalH),
    const Radius.circular(12),
  );
  canvas.drawRRect(cardRrect.shift(const Offset(0, 1)), shadowPaint);

  final bgPaint = Paint()..color = Colors.white;
  final borderPaint = Paint()
    ..color = const Color(0xFF006A4E)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  final cardRrectMain = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, logicalW, logicalH),
    const Radius.circular(12),
  );
  canvas.drawRRect(cardRrectMain, bgPaint);
  canvas.drawRRect(cardRrectMain, borderPaint);

  final imgLeft = (logicalW - imgDiameter) / 2;
  final imgTop = pad;
  final imgRect = Rect.fromLTWH(imgLeft, imgTop, imgDiameter, imgDiameter);

  if (photo != null) {
    canvas.save();
    canvas.clipPath(Path()..addOval(imgRect));
    paintImage(
      canvas: canvas,
      rect: imgRect,
      image: photo,
      fit: BoxFit.cover,
    );
    canvas.restore();
    canvas.drawOval(
      imgRect,
      Paint()
        ..color = const Color(0x33000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  } else {
    final fallback = TextPainter(
      text: TextSpan(
        text: store.name.isNotEmpty ? store.name[0].toUpperCase() : '?',
        style: const TextStyle(color: Color(0xFF006A4E), fontSize: 22, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.drawCircle(imgRect.center, imgDiameter / 2, Paint()..color = const Color(0xFFE8F5E9));
    fallback.paint(
      canvas,
      Offset(imgRect.center.dx - fallback.width / 2, imgRect.center.dy - fallback.height / 2),
    );
  }

  namePainter.paint(canvas, Offset(pad, imgTop + imgDiameter + 6));

  final picture = recorder.endRecording();
  photo?.dispose();
  photo = null;

  final int wPx = (logicalW * pixelRatio).round();
  final int hPx = (logicalH * pixelRatio).round();
  final ui.Image raster = await picture.toImage(wPx, hPx);
  try {
    final byteData = await raster.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final bytes = byteData.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes);
  } finally {
    raster.dispose();
  }
}
