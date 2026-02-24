import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class OdooPdfDownloader {
  ///download slip pdf
  Future downloadPaymentPdf({
    required String odooUrl,
    required String sessionId,
    required int paymentId,
  }) async {
    final url = "$odooUrl/report/pdf/account.report_payment_receipt/$paymentId";

    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'session_id=$sessionId', 'Accept': 'application/pdf'},
    );

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Invoice_$paymentId.pdf';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } else {
      throw Exception("Failed to download PDF (${response.statusCode})");
    }
  }
}
