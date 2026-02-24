import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/model/employee.dart';
import '../constants/constants.dart';

Widget employeeCardWidget({
  required Employee employee,
  required bool istrailing,
  Widget? trailingIcon,
  VoidCallback? trailingFunction,
}) {
  final imageBytes = employee.imageBytes;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Avatar
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: (imageBytes != null && imageBytes.isNotEmpty)
              ? MemoryImage(imageBytes)
              : AssetImage(profile) as ImageProvider,
        ),

        const SizedBox(width: 14),

        /// Employee Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.name,
                style: TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                employee.workPhone ?? '—',
                style: MoboText.nav.copyWith(color: Colors.grey.shade700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        /// Trailing Icon
        if (istrailing)
          IconButton(
            key: Key("employee_remove"),
            onPressed: trailingFunction,
            icon:
                trailingIcon ??
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCancelCircleHalfDot,
                  size: 24,
                  color: Colors.grey,
                ),
          ),
      ],
    ),
  );
}
