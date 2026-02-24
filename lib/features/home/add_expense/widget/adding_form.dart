import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/model/tax_model.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/simple_card.dart';
import '../../../../core/widgets/textform_search_listing.dart';
import '../../../../model/expenseCategory.dart';

class AddingForm extends StatelessWidget {
  List<ExpenseCategory> catogoryList;

  List<TaxModel> taxes;
  TextEditingController title;
  TextEditingController amount;
  double taxAmount;
  TextEditingController date;
  ExpenseCategory? selectedExpenseCategory;
  List<TaxModel>? selectedTax;
  Function(ExpenseCategory catogory) categorySelection;
  Function(List<TaxModel> tax) taxSelection;
  Function(String value) gettingTax;

  AddingForm({
    super.key,
    this.selectedTax,
    this.selectedExpenseCategory,
    required this.catogoryList,
    required this.taxes,
    required this.title,
    required this.amount,
    required this.taxSelection,
    required this.categorySelection,
    required this.taxAmount,
    required this.date,
    required this.gettingTax,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ///form view
    return simpleCardWidget(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            "Expense Details",
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          SizedBox(height: 10),

          Text(
            "Expense Description",
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 10),

          SizedBox(
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,

              controller: title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Title';
                }
                return null;
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                fillColor: isDark ? Colors.grey[800] : MoboColor.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "Enter Expense Title",
                hintStyle: MoboText.body,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Expense Amount",
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          SizedBox(height: 10),

          SizedBox(
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: TextStyle(color: Colors.black),

              controller: amount,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Amount';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (selectedTax != null) {
                  gettingTax(value);
                }
              },
              decoration: InputDecoration(
                fillColor: isDark ? Colors.grey[800] : MoboColor.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "Enter Amount",
                hintStyle: MoboText.body,
              ),
            ),
          ),

          SizedBox(height: 20),
          Text(
            "Tax : \$${taxAmount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),

          SizedBox(height: 20),
          Text(
            "Date",
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 10),

          textFormSearchListingWidget(
            isDark: isDark,
            error: false,
            controller: date,
            readOnly: true,
            context: context,
            date: true,
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedDateTime,
              color: isDark ? Colors.white : Colors.black,
            ),
            hintText: "Date",
            isLeading: false,
            isSearching: false,
          ),

          const SizedBox(height: 20),
          Text(
            "Expense Category",
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          SizedBox(height: 10),

          DropdownButtonFormField2<ExpenseCategory>(
            isExpanded: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,

            hint: Text(
              'Select Category',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            items: catogoryList
                .map(
                  (category) => DropdownMenuItem<ExpenseCategory>(
                    value: category,
                    child: Text(
                      category.name,
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),

            onChanged: (ExpenseCategory? value) {
              categorySelection(value!);
            },
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white : Colors.black,
            ),

            buttonStyleData: const ButtonStyleData(height: 45),
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },

            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: isDark ? Colors.grey[800] : Colors.white,
              ),
            ),

            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              filled: true,
              fillColor: isDark ? Colors.grey[800] : MoboColor.white,

              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Tax",
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          SizedBox(height: 10),
          SizedBox(
            child: MultiSelectContainer<TaxModel>(
              items: taxes
                  .map(
                    (tax) => MultiSelectCard<TaxModel>(
                      value: tax,
                      label: tax.name!,
                      child: Text(tax.name!, style: TextStyle()),
                    ),
                  )
                  .toList(),

              itemsPadding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 10,
              ),

              textStyles: MultiSelectTextStyles(
                selectedTextStyle: TextStyle(color: Colors.white),
                textStyle: TextStyle(color: Colors.black),
              ),
              itemsDecoration: MultiSelectDecorations(
                decoration: BoxDecoration(
                  color: MoboColor.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                    style: BorderStyle.solid,
                  ),
                ),

                selectedDecoration: BoxDecoration(
                  color: MoboColor.redColor,

                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
              ),

              onChange: (List<TaxModel> values, TaxModel changedItem) {
                taxSelection(values);

                if (amount.text.isNotEmpty) {
                  gettingTax(amount.text);
                }
              },
            ),
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
}
