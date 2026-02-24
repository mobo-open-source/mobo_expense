import 'dart:convert';
import 'dart:typed_data';

class CategoriesFullModel {
  final int id;
  final String name;
  final String defaultCode;
  final String description;
  final double listPrice;
  final double standardPrice;

  final String supplierTaxes;
  final List<dynamic>? taxId;
  final String? image1920;

  ///  Proper category fields
  final int? categId;
  final String? categName;
  final String? policy;

  CategoriesFullModel({
    required this.id,
    required this.name,
    required this.defaultCode,
    required this.description,
    required this.listPrice,
    required this.standardPrice,
    required this.supplierTaxes,
    this.image1920,
    this.categId,
    this.categName,
    this.taxId,
    this.policy,
  });

  factory CategoriesFullModel.fromJson(Map<String, dynamic> json) {
    final categ = json['categ_id'];

    return CategoriesFullModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      policy: json['expense_policy'] ?? 'No Policy',
      defaultCode: json['default_code'] == false ? '' : json['default_code'],
      description: _stripHtml(
        json['description'] != false ? json['description'] : '',
      ),
      listPrice: (json['lst_price'] != false ? json['lst_price'] : 0)
          .toDouble(),
      standardPrice:
          (json['standard_price'] == false ? 0 : json['standard_price'])
              .toDouble(),

      /// TAX (string only for display)
      supplierTaxes:
          (json['supplier_taxes_id'] is List &&
              (json['supplier_taxes_id'] as List).isNotEmpty)
          ? (json['supplier_taxes_id'] as List)
                .map((e) => e.toString())
                .join(', ')
          : '',

      /// CATEGORY (Many2one)
      categId: categ is List ? categ[0] as int : null,
      categName: categ is List ? categ[1] as String : null,
      image1920: json['image_1920'] != false ? json['image_1920'] : null,
    );
  }

  CategoriesFullModel copyWith({
    int? id,
    String? name,
    String? defaultCode,
    String? description,
    double? listPrice,
    double? standardPrice,
    String? supplierTaxes,
    String? image1920,
    int? categId,
    String? categName,
    List<dynamic>? taxId,
    String? policy,
  }) {
    return CategoriesFullModel(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultCode: defaultCode ?? this.defaultCode,
      description: description ?? this.description,
      listPrice: listPrice ?? this.listPrice,
      standardPrice: standardPrice ?? this.standardPrice,
      supplierTaxes: supplierTaxes ?? this.supplierTaxes,
      image1920: image1920 ?? this.image1920,
      categId: categId ?? this.categId,
      categName: categName ?? this.categName,
      taxId: taxId ?? this.taxId,
      policy: policy ?? this.policy,
    );
  }

  Uint8List? get imageBytes {
    if (image1920 == null || image1920!.isEmpty) return null;
    try {
      return base64Decode(image1920!);
    } catch (_) {
      return null;
    }
  }

  static String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}
