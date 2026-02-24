import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/model/expense_attachment_model.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Widget openAttachment(ExpenseAttachmentModel att) {
  if (att.isImage) {
    return Image.memory(base64Decode(att.datas!), fit: BoxFit.contain);
  }

  return GestureDetector(
    onTap: () async {
      await _openFile(att);
    },
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(icon: HugeIcons.strokeRoundedFile01, color: Colors.black),
          SizedBox(height: 10),
          Text(att.name, style: TextStyle(color: Colors.black)),
        ],
      ),
    ),
  );
}

Future<void> _openFile(ExpenseAttachmentModel att) async {
  final bytes = base64Decode(att.datas!);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${att.name}');
  await file.writeAsBytes(bytes, flush: true);

  /// Opens file using the device's default viewer
  await OpenFile.open(file.path);
}
