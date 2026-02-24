import 'package:intl/intl.dart';

class Invoice {
  final int? id;

  final int? partnerId;
  final String? partnerName;

  final double amount;
  final double amountUntaxed;
  final double taxAmount;
  final double amountDue;

  final String? ref;
  final String? state;
  final String? name;

  final String? invoiceVendorBillId;

  /// Raw dates from Odoo
  final String? invoiceDateRaw;
  final String? invoiceDateDueRaw;
  final String? dateRaw;

  final String paymentReference;

  final int? partnerBankId;
  final int? journalId;
  final String? journalName;

  final List<int> lineIds;
  final List<int> invoiceLineIds;

  Invoice({
    required this.id,
    this.partnerId,
    this.partnerName,
    required this.amount,
    required this.amountUntaxed,
    required this.taxAmount,
    required this.amountDue,
    this.ref,
    this.state,
    this.name,
    this.invoiceVendorBillId,
    this.invoiceDateRaw,
    this.invoiceDateDueRaw,
    this.dateRaw,
    required this.paymentReference,
    this.partnerBankId,
    this.journalId,
    this.journalName,
    required this.lineIds,
    required this.invoiceLineIds,
  });

  /// ---------------- FACTORY ----------------

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as int?,

      amount: _toDouble(json['amount_total']),
      amountUntaxed: _toDouble(json['amount_untaxed']),
      taxAmount: _toDouble(json['amount_tax']),
      amountDue: _toDouble(json['amount_residual']),

      partnerId: _m2oId(json['partner_id']),
      partnerName: _m2oName(json['partner_id']),

      ref: json['ref']?.toString(),
      state: json['state']?.toString(),
      name: json['name']?.toString(),

      invoiceVendorBillId: json['invoice_vendor_bill_id']?.toString(),

      invoiceDateRaw: _rawDate(json['invoice_date']),
      invoiceDateDueRaw: _rawDate(json['invoice_date_due']),
      dateRaw: _rawDate(json['date']),

      paymentReference: json['payment_reference'] == false
          ? '--'
          : json['payment_reference']?.toString() ?? '--',

      partnerBankId: _m2oId(json['partner_bank_id']),
      journalId: _m2oId(json['journal_id']),
      journalName: _m2oName(json['journal_id']),

      lineIds: _toIntList(json['line_ids']),
      invoiceLineIds: _toIntList(json['invoice_line_ids']),
    );
  }

  /// ---------------- DATE GETTERS (FIXED) ----------------

  String get invoiceDate => _formatDate(invoiceDateRaw);
  String get invoiceDateDue => _formatDate(invoiceDateDueRaw);
  String get date => _formatDate(dateRaw);

  /// ---------------- HELPERS ----------------

  static double _toDouble(dynamic value) {
    if (value == null || value == false) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int? _m2oId(dynamic value) {
    if (value == null || value == false) return null;
    if (value is List && value.isNotEmpty) return value[0] as int;
    return null;
  }

  static String? _m2oName(dynamic value) {
    if (value == null || value == false) return null;
    if (value is List && value.length > 1) {
      return value[1].toString().split(',').last.trim();
    }
    return null;
  }

  static List<int> _toIntList(dynamic value) {
    if (value == null || value == false) return <int>[];
    return List<int>.from(value);
  }

  static String? _rawDate(dynamic value) {
    if (value == null || value == false || value.toString().isEmpty) {
      return null;
    }
    return value.toString();
  }

  static String _formatDate(String? value) {
    if (value == null) return '--';
    try {
      return DateFormat('dd-MMM-yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }
}
