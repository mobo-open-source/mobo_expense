import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/simple_card.dart';

class CategoryCardWidget extends StatelessWidget {
  final String name;
  final String defaultCode;
  final Uint8List? bytes;

  const CategoryCardWidget({
    super.key,
    required this.name,
    required this.defaultCode,
    required this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return simpleCardWidget(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ///  Image / Letter Box
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: bytes == null
                  ? (isDark ? Colors.grey[700] : Colors.grey.shade200)
                  : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: bytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      bytes!,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      errorBuilder: (_, __, ___) =>
                          _letterBox(firstLetter, isDark),
                    ),
                  )
                : _letterBox(firstLetter, isDark),
          ),

          const SizedBox(height: 10),

          ///  Name
          Text(
            name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : MoboColor.redColor,
            ),
          ),

          if (defaultCode.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              defaultCode,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Rectangle letter box
  Widget _letterBox(String letter, bool isDark) {
    return Container(
      height: 56,
      width: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDark ? Colors.grey[700] : Colors.grey.shade200,
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
