import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';

Widget textFormSearchListingWidget({
  Widget? icon,
  required String hintText,
  required bool isLeading,
  required bool isSearching,
  bool? date,
  Widget? trailingIcon,
  required bool readOnly,
  TextEditingController? controller,
  BuildContext? context,
  ValueChanged<String>? onSearchChanged,
  VoidCallback? trailingFunction,
  bool? isItNotes,
  required bool error,
  required bool isDark,
  bool? isBorder,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.only(left: 10),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[800] : MoboColor.white,
      borderRadius: BorderRadius.circular(8),
      border: (isBorder ?? false)
          ? Border.all(color: Colors.grey.shade300, width: 1)
          : null,
    ),

    child: Row(
      children: [
        icon ?? SizedBox.shrink(),
        Expanded(
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            style: TextStyle(fontSize: 14),
            onChanged: (value) {
              if (!readOnly && isSearching && onSearchChanged != null) {
                onSearchChanged(value);
              }
            },
            onTap: () async {
              final commonProvider = context!.read<CommonProvider>();
              if (readOnly) {
                if (date == true) {
                  if (controller!.text.isEmpty) {
                    final date = DateTime.now();
                    final dateString = "${date.day}-${date.month}-${date.year}";

                    final value = await chooseDateTime(
                      context,
                      "select date",
                      dateString,
                    );
                    commonProvider.changeDate(controller, value!);
                    return;
                  }

                  final value = await chooseDateTime(
                    context,
                    "select date",
                    controller.text,
                  );
                  commonProvider.changeDate(controller, value!);
                  return;
                }
              }
            },
            maxLines: isItNotes == null || isItNotes == false ? 1 : 3,

            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),

              hintText: hintText,
              hintStyle: GoogleFonts.montserrat(fontSize: 12),
            ),
          ),
        ),

        isLeading
            ? IconButton(onPressed: trailingFunction, icon: trailingIcon!)
            : SizedBox(),
      ],
    ),
  );
}

Future<String?> chooseDateTime(
  BuildContext context,
  String title,
  String expenseDate,
) async {
  /// Convert existing string → DateTime
  DateTime initialDate = DateFormat("dd-MM-yyyy").parse(expenseDate);

  final date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2050),
    helpText: "Select $title",
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: MoboColor.redColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
          datePickerTheme: DatePickerThemeData(
            headerBackgroundColor: MoboColor.redColor,
            headerForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (date == null) return null;

  String formatted = DateFormat("dd-MM-yyyy").format(date);
  return formatted;
}
