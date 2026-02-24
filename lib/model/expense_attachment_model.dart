class ExpenseAttachmentModel {
  final int id;
  final String name;
  final String? mimetype;
  final String? datas;

  /// base64 file content
  final int? fileSize;

  ExpenseAttachmentModel({
    required this.id,
    required this.name,
    this.mimetype,
    this.datas,
    this.fileSize,
  });

  /// Factory constructor to create model from Odoo API response
  factory ExpenseAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ExpenseAttachmentModel(
      id: json['id'],
      name: json['name'] ?? '',
      mimetype: json['mimetype'],
      datas: json['datas'],
      fileSize: json['file_size'],
    );
  }

  /// Convert model back to JSON (if needed for upload/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mimetype': mimetype,
      'datas': datas,
      'file_size': fileSize,
    };
  }

  ExpenseAttachmentModel copywith({
    int? id,
    String? name,
    String? mimetype,
    String? datas,
    int? fileSize,
  }) {
    return ExpenseAttachmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mimetype: mimetype ?? this.mimetype,
      datas: datas ?? this.datas,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  /// Helper methods
  bool get isImage => mimetype != null && mimetype!.startsWith('image/');
  bool get isPdf => mimetype == 'application/pdf';
  bool get isText => mimetype != null && mimetype!.startsWith('text/');
}
