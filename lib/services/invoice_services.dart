import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../core/services/odoo_session_manager.dart';

class InvoiceServices {
  ///checking is it pdf
  bool _isPdf(List<int> bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 &&
        /// %
        bytes[1] == 0x50 &&
        /// P
        bytes[2] == 0x44 &&
        /// D
        bytes[3] == 0x46;

    /// F
  }

  ///download invoice
  Future<File> downloadInvoice(int moveId) async {
    const int maxRetry = 3;
    const timeout = Duration(minutes: 5);

    try {
      final session = await OdooSessionManager.getCurrentSession();
      final baseUrl = session!.serverUrl;
      final sessionId = session.sessionId;

      final pdfUrl =
          '$baseUrl/report/pdf/account.report_invoice_with_payments/$moveId'
          '?t=${DateTime.now().millisecondsSinceEpoch}';

      http.Response? response;

      for (int attempt = 1; attempt <= maxRetry; attempt++) {
        try {
          response = await http
              .get(
                Uri.parse(pdfUrl),
                headers: {'Cookie': 'session_id=$sessionId'},
              )
              .timeout(timeout);

          if (response.statusCode == 200 && _isPdf(response.bodyBytes)) {
            break;
          }
        } catch (e) {
          if (attempt == maxRetry) rethrow;
          await Future.delayed(Duration(seconds: 2 * attempt));
        }
      }

      if (response == null) {
        throw Exception('Failed to download invoice PDF');
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Invoice_$moveId.pdf';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } catch (e) {
      rethrow;
    }
  }

  /// get invoice
  Future<List<dynamic>?> getInvoice(int id) async {
    try {
      final action = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'action_open_account_move',
        'args': [
          [id],
        ],
        'kwargs': {},
      });

      final String resModel = action['res_model'];
      final int resId = action['res_id'];

      /// Case 1: Payment
      if (resModel == 'account.payment') {
        final result = await OdooSessionManager.callKwWithCompany({
          'model': 'account.payment',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['id', '=', resId],
            ],
            'fields': [
              'id',
              'name',
              'amount',
              'memo',
              'state',
              'date',
              'journal_id',
              'partner_id',
            ],
          },
        });

        return result as List<dynamic>;
      }

      /// Case 2: Invoice (account.move)
      final records = await OdooSessionManager.callKwWithCompany({
        'model': resModel,
        'method': 'read',
        'args': [
          [resId],
          [
            'partner_id',
            'ref',
            'state',
            'name',
            'invoice_vendor_bill_id',
            'invoice_date_due',
            'invoice_date',
            'date',
            'payment_reference',
            'partner_bank_id',
            'journal_id',
            'line_ids',
            'invoice_line_ids',
            'amount_residual',
            'amount_untaxed',
            'amount_tax',
            'amount_total',
          ],
        ],
        'kwargs': {},
      });

      return records as List<dynamic>;
    } catch (e) {
      return null;
    }
  }
}
