import 'dart:convert';
import 'package:flutter/material.dart';

class ImageUtils {
  /// Converts a base64 string or URL to an [ImageProvider].
  /// Handles raw base64 and data URI formats.
  static ImageProvider? getSafeImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // Check if it's likely a base64 string
    if (url.startsWith('data:image') || (!url.startsWith('http') && url.length > 100)) {
      try {
        final base64String = url.contains(',') 
            ? url.split(',').last.replaceAll(RegExp(r'\s+'), '')
            : url.replaceAll(RegExp(r'\s+'), '');
        return MemoryImage(base64Decode(base64String));
      } catch (_) {
        return null;
      }
    }
    
    // Fallback to network image
    return NetworkImage(url);
  }
}
