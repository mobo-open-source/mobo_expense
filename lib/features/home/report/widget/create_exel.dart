import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' show AnchorElement;

import '../../../../model/montly_expense_model.dart';

/// helpers
CellValue _text(String v) => TextCellValue(v);
CellValue _num(num v) => DoubleCellValue(v.toDouble());

Future<void> createExcel(List<MonthlyAmountModel> data) async {
  final excel = Excel.createExcel();
  final Sheet sheet = excel['Sheet1'];

  /// ---------------- Header Row ----------------
  List<CellValue> header = [_text('Total')];
  for (int i = 0; i < data.length; i++) {
    header.add(_text(data[i].month));
  }
  header.add(_text('Total In Currency'));
  sheet.appendRow(header);

  /// ---------------- Grand Total Row ----------------
  List<CellValue> totalRow = [_text('Total')];
  double grandTotal = 0;

  for (int i = 0; i < data.length; i++) {
    totalRow.add(_num(data[i].amount));
    grandTotal += data[i].amount;
  }
  totalRow.add(_num(grandTotal));
  sheet.appendRow(totalRow);

  /// ---------------- Month Rows ----------------
  for (int row = 0; row < data.length; row++) {
    List<CellValue> rowData = List.generate(data.length + 2, (_) => _text(''));

    rowData[0] = _text(data[row].month);

    for (int col = 0; col < data.length; col++) {
      if (row == col) {
        rowData[col + 1] = _num(data[row].amount);
      }
    }

    rowData[data.length + 1] = _num(data[row].amount);
    sheet.appendRow(rowData);
  }

  ///---------------- Save ----------------
  final bytes = excel.encode()!;

  if (kIsWeb) {
    AnchorElement(
        href:
            'data:application/octet-stream;charset=utf-8;base64,${base64.encode(bytes)}',
      )
      ..setAttribute(
        'download',
        'Report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      )
      ..click();
  } else {
    final path = (await getApplicationSupportDirectory()).path;
    final file = File(
      '$path/Report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(file.path);
  }
}
