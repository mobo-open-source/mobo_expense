import 'dart:convert';
import 'dart:typed_data';

class Employee {
  final int id;
  final String name;
  final String? workPhone;
  final String? image1920;

  /// base64 or null
  final List<dynamic>? companyId;

  Employee({
    required this.id,
    required this.name,
    required this.workPhone,
    this.image1920,
    this.companyId,
  });

  Uint8List? get imageBytes {
    if (image1920 == null || image1920!.isEmpty) {
      return null;
    }

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

  factory Employee.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image_1920'];

    String? image;
    if (rawImage == false || rawImage == null || rawImage == '') {
      image = null;
    } else if (rawImage is String) {
      image = rawImage;
    } else {
      image = null;
    }

    return Employee(
      id: json['id'] as int,
      name: json['name'] as String,
      workPhone: json['work_phone'] == false
          ? null
          : json['work_phone'] as String?,
      image1920: image,
      companyId: json['company_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'work_phone': workPhone,
      'company_id': companyId,
    };
  }
}
