// core/utils/color_extractor.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class ColorExtractor {
  static final Map<String, Color> _cache = {};
  static const int _maxCacheSize = 50;

  static const Duration _timeout = Duration(seconds: 8);

  static const Color _fallback = Color(0xFFF5F5F5);

  static Future<Color> extractDominantColor(String url) async {
    if (_cache.containsKey(url)) return _cache[url]!;

    try {
      final argb = await compute<_ColorRequest, int>(
        _computeColor,
        _ColorRequest(url),
      ).timeout(
        _timeout,
        onTimeout: () => throw TimeoutException("Color extraction timeout"),
      );

      final color = Color(argb);
      _save(url, color);
      return color;
    } catch (e) {
      _save(url, _fallback);
      return _fallback;
    }
  }

  static void _save(String url, Color color) {
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[url] = color;
  }
}

class _ColorRequest {
  final String url;
  _ColorRequest(this.url);
}

Future<int> _computeColor(_ColorRequest req) async {
  final uri = Uri.tryParse(req.url);
  if (uri == null) return ColorExtractor._fallback.value;

  final response = await http.get(uri);
  if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
    return ColorExtractor._fallback.value;
  }

  final bytes = response.bodyBytes;

  final img.Image? full = img.decodeImage(bytes);
  if (full == null) return ColorExtractor._fallback.value;

  final img.Image small = img.copyResize(
    full,
    width: 200,
    height: 200,
    interpolation: img.Interpolation.average,
  );

  int rSum = 0, gSum = 0, bSum = 0, count = 0;

  for (int y = 0; y < small.height; y++) {
    for (int x = 0; x < small.width; x++) {
      final px = small.getPixel(x, y);

      rSum += (px.r).toInt();
      gSum += (px.g).toInt();
      bSum += (px.b).toInt();
      count++;
    }
  }

  if (count == 0) return ColorExtractor._fallback.value;

  final r = ((rSum / count).clamp(0, 255)).toInt();
  final g = ((gSum / count).clamp(0, 255)).toInt();
  final b = ((bSum / count).clamp(0, 255)).toInt();

  return (0xFF << 24) | (r << 16) | (g << 8) | b;
}
