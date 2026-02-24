import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

Uint8List? safeBase64Image(String? img) {
  if (img == null || img.isEmpty || img == 'false') return null;

  try {
    final clean = img.contains(',') ? img.split(',').last : img;

    final bytes = base64Decode(clean);

    ///  THIS IS THE KEY
    if (!isSupportedImage(bytes)) {
      return null;
    }

    return bytes;
  } catch (e) {
    return null;
  }
}

bool isSupportedImage(Uint8List bytes) {
  /// PNG
  if (bytes.length > 4 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47)
    return true;

  /// JPEG
  if (bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) return true;

  /// WEBP
  if (bytes.length > 12 &&
      bytes[0] == 0x52 &&
      /// R
      bytes[1] == 0x49 &&
      /// I
      bytes[2] == 0x46 &&
      /// F
      bytes[3] == 0x46)
    return true;

  return false;
}
