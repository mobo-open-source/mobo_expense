class JournalModel {
  int? id;
  String? code;
  String? type;
  String? displayName;
  List<dynamic>? defaultAccountId;

  JournalModel({
    this.id,
    this.code,
    this.type,
    this.displayName,
    this.defaultAccountId,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'],
      code: json['code'],
      type: json['type'],
      displayName: json['display_name'],
      defaultAccountId: json['default_account_id'] != false
          ? json['default_account_id']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'display_name': displayName,
      'default_account_id': defaultAccountId,
    };
  }
}
