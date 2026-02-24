import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_expenses/features/home/add_expense/widget/adding_form.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/loading.dart';
import '../../../core/utils/show_back_dialog.dart';
import '../../../core/utils/snackbar.dart';
import '../../../core/widgets/common_result_pannel.dart';
import '../../../core/widgets/custom_card_h.dart';
import '../../../core/widgets/employee_card.dart';
import '../../../core/widgets/open_attachment.dart';
import '../../../core/widgets/simple_card.dart';
import '../../../core/widgets/submit_button.dart';
import '../../../core/widgets/textform_search_listing.dart';
import '../../../model/employee.dart';
import '../../../provider/bottom_nav_provider.dart';
import '../../../shared/widgets/snackbars/custom_snackbar.dart';
import '../home_screen.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({super.key});

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<CommonProvider>(
        context,
        listen: false,
      ).currentExpenseEmployee();
    });

    setState(() {
      titleController.addListener(() => setState(() {}));
      amountController.addListener(() => setState(() {}));
      dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => initialCalling());
  }

  bool isEmployee = false;
  bool isDescription = false;
  bool isCategory = false;

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final note = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    /// TODO: implement dispose
    super.dispose();
    titleController.dispose();
    amountController.dispose();
    dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
        elevation: 0,

        /// title
        title: Text(
          "Create Expense",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),

        /// leading
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: MoboPadding.pagePadding,
        child: SingleChildScrollView(
          child: Consumer<CommonProvider>(
            builder: (context, commonProvider, child) {
              final isActive = commonProvider.isFormReady(
                title: titleController.text,
                amount: amountController.text,
                date: dateController.text,
              );

              return Column(
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
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 10),
                        userProvider.isAdmin
                            ? commonProvider.isLoading
                                  ? CardLoading(
                                      height: 50,
                                      borderRadius: BorderRadius.circular(8),
                                    )
                                  : commonProvider.selctedEmployee != null
                                  ? employeeCardWidget(
                                      employee: commonProvider.selctedEmployee!,
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
                                        commonProvider.gettingTypedList(value);
                                      },
                                      icon: HugeIcon(
                                        icon:
                                            HugeIcons.strokeRoundedUserSearch02,
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
                                    )
                            : commonProvider.selctedEmployee != null
                            ? employeeCardWidget(
                                employee: commonProvider.selctedEmployee!,
                                istrailing: false,
                              )
                            : Text("Employee not found"),

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

                  SizedBox(height: 20),

                  Form(
                    key: formKey,
                    child: AddingForm(
                      selectedExpenseCategory: commonProvider.selectedCategory,
                      selectedTax: commonProvider.selectedTax,

                      taxAmount: commonProvider.taxAmount,
                      catogoryList: commonProvider.categoryList,
                      taxes: commonProvider.totalTax,
                      title: titleController,
                      date: dateController,
                      amount: amountController,
                      gettingTax: (value) {
                        commonProvider.gettingTaxAmount(
                          commonProvider.selectedTax,
                          value,
                        );
                      },
                      taxSelection: (value) {
                        commonProvider.selectTax(value);
                      },
                      categorySelection: (value) {
                        commonProvider.getSelectedCategory(value);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  customCardWithHeading(
                    "Payed By",
                    Column(
                      children: [
                        RadioMenuButton(
                          value: "company_account",
                          groupValue: commonProvider.paidBy.text,
                          onChanged: (value) {
                            commonProvider.changePaidBy(value!);
                          },
                          child: Text(
                            "Company",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        RadioMenuButton(
                          value: "own_account",
                          groupValue: commonProvider.paidBy.text,
                          onChanged: (value) {
                            commonProvider.changePaidBy(value!);
                          },
                          child: Text("Self", style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

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
                            color: isDark ? Colors.white : Colors.black87,
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
                                            behavior: SnackBarBehavior.floating,
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
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            expenseProvider.attachment!.name,
                                            style: MoboText.h4,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            expenseProvider.deleteAttachment();
                                          },
                                          icon: HugeIcon(
                                            icon:
                                                HugeIcons.strokeRoundedDelete02,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),

                        textFormSearchListingWidget(
                          isDark: isDark,
                          error: false,
                          controller: note,
                          readOnly: false,
                          isLeading: false,
                          isSearching: true,
                          hintText: "Add your comments..",
                          isItNotes: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  submitButton(
                    onclick: isActive
                        ? () async {
                            if (formKey.currentState!.validate()) {
                              if (commonProvider.selctedEmployee == null) {
                                showSnackBar(
                                  context,
                                  "Please Select Employee",
                                  backgroundColor: Colors.red,
                                );
                                return;
                              }

                              bool confirm = await showBackDialog(
                                context,
                                title: 'Add Expense?',
                                subtitle: "Are you sure you want to Add?",
                                leftButtonName: "Cancel",
                                rightButtonName: "Submit",
                                function: () {
                                  Navigator.pop(context, true);
                                },
                              );

                              if (confirm) {
                                loadingDialog(
                                  context,
                                  "Adding Expense",
                                  "Please wait while we adding ",
                                  LoadingAnimationWidget.fourRotatingDots(
                                    color: MoboColor.redColor,
                                    size: 30,
                                  ),
                                );

                                final result = await context
                                    .read<ExpenseProvider>()
                                    .submitExpense(
                                      paymentBy: commonProvider.paidBy.text,
                                      employeeId:
                                          commonProvider.selctedEmployee!.id,
                                      name: titleController.text,
                                      amount: double.parse(
                                        amountController.text,
                                      ),
                                      taxId: commonProvider.selectedTax
                                          .map((e) => e.id)
                                          .toList(),
                                      date: dateController.text,
                                      categoryId:
                                          commonProvider.selectedCategory!.id,
                                      notes: note.text.isEmpty ? "" : note.text,
                                      attachment: expenseProvider.attachment,
                                    );

                                if (result) {
                                  final bottom = Provider.of<BottomNavProvider>(
                                    context,
                                    listen: false,
                                  );
                                  bottom.changeIndex(1);

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
                                    "Successfully added Expense",
                                  );

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                } else {
                                  CustomSnackbar.showError(
                                    context,
                                    "Some Server Issue when adding Expense",
                                  );

                                  hideLoadingDialog(context);
                                }
                                return;
                              }
                            }

                            CustomSnackbar.showWarning(
                              context,
                              "Please check the required field",
                            );
                          }
                        : null,
                    title: "Create Expense",
                    color: MoboColor.redColor,
                  ),
                  SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  ///initial loading
  initialCalling() async {
    try {
      final userProver = Provider.of<UserProvider>(context, listen: false);

      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );
      expenseProvider.expenseInitial();

      final commonProvider = Provider.of<CommonProvider>(
        context,
        listen: false,
      );

      commonProvider.disposeInTax();

      await commonProvider.getFullTax();
    } catch (e) {}
  }
}
