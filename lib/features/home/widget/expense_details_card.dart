import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/simple_card.dart';
import '../../../core/widgets/space_btw_widget.dart';
import '../../../core/widgets/textform_search_listing.dart';
import '../../../provider/common_provider.dart';

Widget expenseDetailsCard(
  BuildContext context,

  bool isCategory,
  bool isDescription,
  CommonProvider commonProvider,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return simpleCardWidget(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text("Expense Details", style: MoboText.h3),
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 10),

        Text(
          "Expense Description",
          style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black87),
        ),

        textFormSearchListingWidget(
          error: isDescription,
          isDark: isDark,
          controller: commonProvider.discriptionController,
          readOnly: false,
          icon: HugeIcon(icon: HugeIcons.strokeRoundedContentWriting),
          hintText: "Description",
          isLeading: false,
          isSearching: true,
          onSearchChanged: (_) {},
        ),

        const SizedBox(height: 6),
        Visibility(
          visible: isDescription,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Please enter a description",
              style: MoboText.normal.copyWith(color: Colors.red, fontSize: 12),
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          "Date",
          style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black87),
        ),
        textFormSearchListingWidget(
          error: false,
          isDark: isDark,
          controller: commonProvider.dateController,
          readOnly: true,
          context: context,
          date: true,
          icon: HugeIcon(icon: HugeIcons.strokeRoundedDateTime),
          hintText: "Date",
          isLeading: false,
          isSearching: false,
        ),

        const SizedBox(height: 20),

        Text(
          "Category",
          style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black87),
        ),

        GestureDetector(
          onTap: () {
            commonProvider.changingCategory(commonProvider.categoryShow);
          },
          child: Container(
            padding: MoboPadding.pagePadding,
            decoration: BoxDecoration(
              color: MoboColor.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Expanded(child: Text("Category")),
                      Flexible(
                        child: Text(
                          commonProvider.selectedCategory?.name ??
                              "Select category",
                        ),
                      ),
                    ],
                  ),
                ),
                !commonProvider.categoryShow
                    ? HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01)
                    : HugeIcon(icon: HugeIcons.strokeRoundedArrowUp01),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),
        Visibility(
          visible: isCategory,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Please select a category",
              style: MoboText.normal.copyWith(color: Colors.red, fontSize: 12),
            ),
          ),
        ),

        const SizedBox(height: 20),
        Visibility(
          visible: commonProvider.categoryShow,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 3,
                  spreadRadius: 2,
                ),
              ],
            ),
            height: 200,
            child: ListView.builder(
              itemCount: commonProvider.categoryList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    commonProvider.changingCategory(
                      commonProvider.categoryShow,
                    );
                    commonProvider.getSelectedCategory(
                      commonProvider.categoryList[index],
                    );
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: spaceBetweenWidget(
                          commonProvider.categoryList[index].id.toString(),
                          commonProvider.categoryList[index].name,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Divider(color: Color(0xFFEFEFEF)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}
