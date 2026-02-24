import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/constants.dart';
import '../category/add_category/add_category.dart';

Widget floatingActionButtonAddingCategory(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InkWell(
    key: Key("fab"),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCategoryScreen()),
    ),
    child: Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : MoboColor.redColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [MoboShadows.medium, MoboShadows.medium],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedPackageAdd,
          color: isDark ? Colors.black : Colors.white,
          strokeWidth: 1,
        ),
      ),
    ),
  );
}
