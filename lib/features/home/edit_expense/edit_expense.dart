import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/loading.dart';
import '../../../core/utils/show_back_dialog.dart';
import '../../../core/widgets/common_result_pannel.dart';
import '../../../core/widgets/custom_card_h.dart';
import '../../../core/widgets/employee_card.dart';
import '../../../core/widgets/open_attachment.dart';
import '../../../core/widgets/simple_card.dart';
import '../../../core/widgets/submit_button.dart';
import '../../../core/widgets/textform_search_listing.dart';
import '../../../model/employee.dart';
import '../../../provider/common_provider.dart';
import '../../../provider/expense_provider.dart';
import '../../../shared/widgets/snackbars/custom_snackbar.dart';
import '../home_screen.dart';

class EditExpense extends StatefulWidget {
  final Expense currentExpense;

  const EditExpense({super.key, required this.currentExpense});

  @override
  State<EditExpense> createState() => _EditExpenseState();
}

class _EditExpenseState extends State<EditExpense> {
  bool isEmployee = false;
  bool isDescription = false;
  bool isAmount = false;
  bool isCategory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialCalling();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        ///confirm dialog
        bool confirm = await showBackDialog(
          context,
          title: 'Expense',
          subtitle:
              "You have unsaved expense data that will be lost if you leave this page.Are you sure you want to discard this expense?",
          leftButtonName: "Stay",
          rightButtonName: "Leave",
          function: () {
            Navigator.pop(context, true);
          },
        );

        if (confirm) {
          Navigator.pop(context, result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
          title: Text(
            "Edit Expense",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: GestureDetector(
            onTap: () async {
              bool shouldExit = await showBackDialog(
                context,
                title: 'Discard Expense?',
                subtitle:
                    "You have unsaved expense data that will be lost if you leave this page.Are you sure you want to discard this expense?",
                leftButtonName: "Stay",
                rightButtonName: "Leave",
                function: () {
                  Navigator.pop(context, true);
                },
              );
              if (shouldExit) {
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          actionsPadding: EdgeInsets.only(right: 20),
        ),
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,

        body: Consumer<CommonProvider>(
          builder: (context, commonProvider, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: MoboPadding.pagePadding,
                child: expenseProvider.isLoading
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CardLoading(
                            height: 150,
                            borderRadius: BorderRadius.circular(
                              MoboRadius.card,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          simpleCardWidget(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  "Employee Details",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                ),
                                const SizedBox(height: 10),
                                const SizedBox(height: 10),
                                commonProvider.selctedEmployee != null
                                    ? employeeCardWidget(
                                        employee:
                                            commonProvider.selctedEmployee!,
                                        istrailing: true,
                                        trailingFunction: () {
                                          commonProvider.gettingTypedList("");
                                          commonProvider.removingEmployee();
                                        },
                                      )
                                    : textFormSearchListingWidget(
                                        isDark: isDark,
                                        error: isEmployee,
                                        trailingFunction: () {
                                          commonProvider.changing(
                                            commonProvider.isShow,
                                          );
                                        },
                                        readOnly: false,
                                        isLeading: true,
                                        isSearching: true,
                                        controller:
                                            commonProvider.employeeController,
                                        onSearchChanged: (value) {
                                          commonProvider.gettingTypedList(
                                            value,
                                          );
                                        },
                                        icon: HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedUserSearch02,
                                        ),
                                        hintText: "Type to search  employees",
                                        trailingIcon: !commonProvider.isShow
                                            ? HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedArrowDown01,
                                              )
                                            : HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedArrowUp01,
                                              ),
                                      ),
                                const SizedBox(height: 8),

                                Visibility(
                                  visible: isEmployee,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Please select an employee",
                                      style: MoboText.normal.copyWith(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                CommonResultPanel<Employee>(
                                  visible: commonProvider.isShow,
                                  isLoading: commonProvider.isLoading,
                                  items: commonProvider.employeeList,
                                  height: 250,
                                  padding: const EdgeInsets.only(
                                    left: 2,
                                    right: 2,
                                    top: 2,
                                  ),
                                  itemBuilder: (context, employee) =>
                                      employeeCardWidget(
                                        employee: employee,
                                        istrailing: false,
                                      ),
                                  onTap: (employee) {
                                    isEmployee = false;
                                    commonProvider.addEmployee(employee);
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// ---------------- Expense Details block ----------------
                          simpleCardWidget(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  "Expense Details",
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  "Expense Description",
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),

                                /// description input (your custom widget)
                                textFormSearchListingWidget(
                                  isDark: isDark,
                                  error: isDescription,
                                  controller:
                                      commonProvider.discriptionController,
                                  readOnly: false,

                                  hintText: "Description",
                                  isLeading: false,
                                  isSearching: true,
                                  onSearchChanged: (_) {
                                    setState(() {
                                      isDescription = false;
                                    });
                                  },
                                ),

                                const SizedBox(height: 6),
                                Visibility(
                                  visible: isDescription,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Please enter a description",
                                      style: MoboText.normal.copyWith(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Text(
                                  "Date",
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                textFormSearchListingWidget(
                                  isDark: isDark,
                                  error: false,
                                  controller: commonProvider.dateController,
                                  readOnly: true,
                                  context: context,
                                  date: true,

                                  hintText: "Date",
                                  isLeading: false,
                                  isSearching: false,
                                ),

                                const SizedBox(height: 20),
                                Text(
                                  "Category",
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                DropdownButtonFormField(
                                  value: commonProvider.selectedCategory,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDark
                                        ? Colors.grey[800]
                                        : MoboColor.white,
                                    contentPadding: MoboPadding.pagePadding,

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    errorText: isCategory
                                        ? "Please select a category"
                                        : null,
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  dropdownColor: isDark
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  hint: Text(
                                    "Select category",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                  ),
                                  items: commonProvider.categoryList.map((
                                    category,
                                  ) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(
                                        category.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    commonProvider.getSelectedCategory(value!);
                                    setState(() {
                                      isCategory = false;
                                    });
                                  },
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  "Paid By",
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                widget.currentExpense.state == 'draft'
                                    ? Column(
                                        children: [
                                          RadioMenuButton(
                                            value: "company_account",
                                            groupValue:
                                                commonProvider.paidBy.text,
                                            onChanged: (value) {
                                              commonProvider.changePaidBy(
                                                value!,
                                              );
                                            },
                                            child: Text("Company"),
                                          ),
                                          RadioMenuButton(
                                            value: "own_account",
                                            groupValue:
                                                commonProvider.paidBy.text,
                                            onChanged: (value) {
                                              commonProvider.changePaidBy(
                                                value!,
                                              );
                                            },
                                            child: Text("Self"),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: MoboColor.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),

                                        child: Text(
                                          commonProvider.paidBy.text,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),

                                const SizedBox(height: 20),

                                Text(
                                  "Manager",
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                textFormSearchListingWidget(
                                  isDark: isDark,
                                  error: false,
                                  controller: commonProvider.manager,
                                  readOnly: true,
                                  isLeading: false,
                                  isSearching: false,

                                  hintText: "Manager",
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "Company",
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                textFormSearchListingWidget(
                                  isDark: isDark,
                                  error: false,
                                  readOnly: true,
                                  isLeading: false,
                                  isSearching: true,
                                  controller: commonProvider.company,

                                  hintText: "Company",
                                  trailingIcon: HugeIcon(
                                    icon: HugeIcons.strokeRoundedArrowDown01,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// ---------------- Price block ----------------
                          simpleCardWidget(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  "Price",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                ),
                                const SizedBox(height: 20),

                                Text(
                                  "Total amount",
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),

                                textFormSearchListingWidget(
                                  isDark: isDark,
                                  error: isAmount,
                                  controller: commonProvider.priceController,
                                  readOnly: false,
                                  context: context,
                                  hintText: "Price",
                                  isLeading: false,
                                  isSearching: true,
                                  onSearchChanged: (_) {
                                    setState(() {
                                      isAmount = false;
                                    });
                                  },
                                ),

                                const SizedBox(height: 6),
                                Visibility(
                                  visible: isAmount,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Please enter a valid amount",
                                      style: MoboText.normal.copyWith(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10),

                                Text(
                                  "Tax amount",
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),

                                ListView(
                                  shrinkWrap: true,
                                  children: commonProvider.totalTax.map((item) {
                                    return CheckboxListTile(
                                      title: Text(
                                        item.name!,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      side: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,

                                        width: 1.0,

                                        /// Border width (size)
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      value: commonProvider.selectedTax
                                          .contains(item),
                                      onChanged: (bool? value) {
                                        value!
                                            ? commonProvider.addTax(item)
                                            : commonProvider.removeTax(item);
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const SizedBox(height: 20),

                          customCardWithHeading(
                            'Additional Information',

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  "Add reciept",
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),

                                expenseProvider.attachment == null
                                    ? Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              try {
                                                await expenseProvider
                                                    .selectFileFromDevice();
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Failed to pick file: ${e.toString()}",
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding: MoboPadding.pagePadding,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? Colors.grey[800]
                                                    : MoboColor.white,
                                              ),
                                              child: Row(
                                                children: [
                                                  HugeIcon(
                                                    icon: HugeIcons
                                                        .strokeRoundedAttachment02,
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      "please add your expense receipt",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelMedium
                                                          ?.copyWith(
                                                            color: isDark
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : simpleCardWidget(
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    expenseProvider
                                                        .attachment!
                                                        .name,
                                                    style: MoboText.h4,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    expenseProvider
                                                        .deleteAttachment();
                                                  },
                                                  icon: HugeIcon(
                                                    icon: HugeIcons
                                                        .strokeRoundedDelete02,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: openAttachment(
                                                expenseProvider.attachment!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                SizedBox(height: 10),

                                Text(
                                  "Notes (Optional)",
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 20),
                                textFormSearchListingWidget(
                                  isDark: isDark,
                                  error: false,
                                  controller: commonProvider.note,
                                  readOnly: false,
                                  isLeading: false,
                                  isSearching: true,
                                  hintText: "Add your comments..",
                                  isItNotes: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          submitButton(
                            onclick: () async {
                              bool valid = true;
                              if (commonProvider.selctedEmployee == null) {
                                valid = false;
                                isEmployee = true;
                              }
                              if (commonProvider.discriptionController.text
                                  .trim()
                                  .isEmpty) {
                                valid = false;
                                isDescription = true;
                              }
                              if (commonProvider.priceController.text
                                  .trim()
                                  .isEmpty) {
                                valid = false;
                                isDescription = true;
                              }
                              if (!valid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(
                                      child: Text(
                                        "Please check the required fields",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: MoboColor.redColor,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              if (valid) {
                                loadingDialog(
                                  context,
                                  "Updating expense",
                                  "Please wait while we updating Expense",
                                  LoadingAnimationWidget.fourRotatingDots(
                                    color: MoboColor.redColor,
                                    size: 30,
                                  ),
                                );
                                final newExpense = widget.currentExpense
                                    .copyWith(
                                      employeeId: [
                                        commonProvider.selctedEmployee!.id,
                                        commonProvider.selctedEmployee!.name,
                                      ],
                                      description: commonProvider.note.text
                                          .trim(),
                                      name: commonProvider
                                          .discriptionController
                                          .text
                                          .trim(),
                                      date: commonProvider.dateController.text,
                                      productId: [
                                        commonProvider.selectedCategory!.id,
                                        commonProvider.selectedCategory!.name,
                                      ],
                                      paymentMode: commonProvider.paidBy.text
                                          .trim(),
                                      totalAmount: double.tryParse(
                                        commonProvider.priceController.text
                                            .trim(),
                                      ),
                                      taxIds: commonProvider.selectedTax
                                          .map((tax) => tax.id)
                                          .toList(),
                                    );

                                try {
                                  final result = await expenseProvider
                                      .updateExpense(
                                        newExpense,
                                        gettingAttachment:
                                            expenseProvider.attachment,
                                      );
                                  if (result) {
                                    Provider.of<ExpenseProvider>(
                                      context,
                                      listen: false,
                                    ).emptyApproval();
                                    await Provider.of<ExpenseProvider>(
                                      context,
                                      listen: false,
                                    ).getExpenses(
                                      context,
                                      Provider.of<UserProvider>(
                                        context,
                                        listen: false,
                                      ).isAdmin,
                                    );

                                    await Provider.of<ExpenseProvider>(
                                      context,
                                      listen: false,
                                    ).loadExpenses();
                                    CustomSnackbar.showSuccess(
                                      context,
                                      "Updated  Successfully completed",
                                    );

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  } else {
                                    CustomSnackbar.showError(
                                      context,
                                      "Updating expense error on server side",
                                    );
                                  }
                                } catch (e) {
                                } finally {
                                  hideLoadingDialog(context);
                                }
                              }
                            },
                            title: "Update Expense",
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  ///initial calling
  initialCalling() async {
    try {
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );

      final commonProvider = Provider.of<CommonProvider>(
        context,
        listen: false,
      );

      await expenseProvider.getExpenseAttachment(widget.currentExpense.id);
      await commonProvider.getFullTax();

      await commonProvider.initialTax(widget.currentExpense.taxIds);
    } catch (e) {}
  }
}
