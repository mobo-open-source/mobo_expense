import 'dart:convert';
import 'dart:typed_data';

class ExpenseCategory {
  final int id;
  final String name;
  final String? image1920;
  final String? defaultCode;

  ExpenseCategory({
    required this.id,
    required this.name,
    this.image1920,
    this.defaultCode,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      image1920: json['image_1920'] != false ? json['image_1920'] : null,
      defaultCode: json['default_code'] == false ? " " : json['default_code'],
    );
  }

  Uint8List? get imageBytes {
    if (image1920 == null || image1920!.isEmpty) return null;

    try {
      var data = image1920!.trim();

      if (data.contains(',')) {
        data = data.split(',').last.trim();
      }

      final padding = data.length % 4;
      if (padding != 0) {
        data = data.padRight(data.length + (4 - padding), '=');
      }

      final bytes = base64Decode(data);

      if (bytes.length < 4) {
        return null;
      }

      final b0 = bytes[0];
      final b1 = bytes[1];
      final b2 = bytes[2];
      final b3 = bytes[3];

      final isJpeg = b0 == 0xFF && b1 == 0xD8;

      /// JPEG
      final isPng = b0 == 0x89 && b1 == 0x50 && b2 == 0x4E && b3 == 0x47;

      /// PNG

      if (!isJpeg && !isPng) {
        return null;
      }

      return bytes;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
