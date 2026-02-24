import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/odoo_session_manager.dart';
import '../../../../core/utils/dialog_box_text_field.dart';
import '../../../../core/utils/error/custom_error_dailog.dart';
import '../../../../core/utils/error/error_detectort.dart';
import '../../../../core/utils/loading.dart';
import '../../../../core/utils/show_back_dialog.dart';
import '../../../../core/widgets/dialog_box.dart';
import '../../../../core/widgets/textform_search_listing.dart';
import '../../../../model/employee.dart';
import '../../../../model/journal_model.dart';
import '../../../../provider/common_provider.dart';
import '../../../../provider/expense_provider.dart';
import '../../../../provider/user_provider.dart';
import '../../../../services/expense_services.dart';
import '../../../../shared/widgets/snackbars/custom_snackbar.dart';
import '../../home_screen.dart';

gettingSelected(String value, BuildContext context, Expense expense) async {
  final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
  final expenseServices = ExpenseServices();

  final formKey = GlobalKey<FormState>();

  ///delete case
  if (value == "delete") {
    bool confirm = await showBackDialog(
      context,
      title: 'Delete Expense?',
      subtitle:
          "Are you sure you want to delete ${expense.name} expense?This action is permanent and cannot be undone",
      leftButtonName: "Cancel",
      rightButtonName: "Delete",
      function: () {
        Navigator.pop(context, true);
      },
    );
    if (confirm) {
      loadingDialog(
        context,
        "Deleting",
        "Please wait while we are deleting..",
        LoadingAnimationWidget.fourRotatingDots(
          color: MoboColor.redColor,
          size: 30,
        ),
      );

      try {
        final result = await expenseProvider.deleteExpense(expense.id);

        if (result) {
          expenseProvider.emptyApproval();
          await expenseProvider.getExpenses(
            context,
            Provider.of<UserProvider>(context, listen: false).isAdmin,
          );
          await expenseProvider.loadExpenses();
          CustomSnackbar.showSuccess(context, "deleted Successfully ");

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          hideLoadingDialog(context);
          CustomSnackbar.showError(context, "Server issue");
        }
        hideLoadingDialog(context);
      } catch (e) {
        hideLoadingDialog(context);
        final errorType = detectErrorType(e);

        final errorMessage = e
            .toString()
            .split("message:")
            .last
            .split(",")
            .first
            .trim();

        CustomErrorDialog.show(context, errorType, message: errorMessage);
      }
    }
  } else if (value == 'report') {
    bool confirm = await showBackDialog(
      context,
      title: 'Create report?',
      subtitle: "Are you sure you want to Create ${expense.name}?",
      leftButtonName: "Cancel",
      rightButtonName: "Create",
      function: () {
        Navigator.pop(context, true);
      },
    );
    if (confirm) {
      loadingDialog(
        context,
        "Submitting Expense",
        "Please wait while we submitting expense",
        LoadingAnimationWidget.fourRotatingDots(
          color: MoboColor.redColor,
          size: 30,
        ),
      );

      try {
        final result = await expenseProvider.buttonAction(
          'action_submit_expenses',
          'hr.expense',
          expense.id,
        );
        if (result) {
          await expenseProvider.getExpenses(context, true);
          await expenseProvider.loadExpenses();
          CustomSnackbar.showSuccess(
            context,
            "Expense State updated Successfully",
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          CustomSnackbar.showError(
            context,
            "Expense State not Succesfully updated",
          );
        }
      } catch (e) {
        hideLoadingDialog(context);
        final errorType = detectErrorType(e);

        final errorMessage = e
            .toString()
            .split("message:")
            .last
            .split(",")
            .first
            .trim();

        CustomErrorDialog.show(context, errorType, message: errorMessage);
      }
    }
  } else if (value == 'submit') {
    bool confirm = await showBackDialog(
      context,
      title: 'Submit Expense?',
      subtitle: "Are you sure you want to Submit ${expense.name}?",
      leftButtonName: "Cancel",
      rightButtonName: "Submit",
      function: () {
        Navigator.pop(context, true);
      },
    );

    if (confirm) {
      loadingDialog(
        context,
        "Submitting Expense",
        "Please wait while we submitting expense",
        LoadingAnimationWidget.fourRotatingDots(
          color: MoboColor.redColor,
          size: 30,
        ),
      );

      try {
        final version = Provider.of<ExpenseProvider>(
          context,
          listen: false,
        ).odooVersion;

        if (version == '19') {
          final result = await expenseProvider.buttonAction(
            'action_submit',
            'hr.expense',
            expense.id,
          );
          if (result) {
            await expenseProvider.getExpenses(context, true);
            await expenseProvider.loadExpenses();

            CustomSnackbar.showSuccess(
              context,
              "Expense State updated Successfully",
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            CustomSnackbar.showError(
              context,
              "Expense State not Succesfully updated",
            );
          }
        } else {
          final id = await expenseServices.gettingIdExpenseSheet(expense.id);

          final result = await expenseProvider.buttonAction(
            'action_submit_sheet',
            'hr.expense.sheet',
            id,
          );
          if (result) {
            await expenseProvider.getExpenses(context, true);
            await expenseProvider.loadExpenses();
            CustomSnackbar.showSuccess(
              context,
              "Expense State updated Successfully",
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            CustomSnackbar.showError(
              context,
              "Expense State not Succesfully updated",
            );
          }
        }
      } catch (e) {
        hideLoadingDialog(context);
        final errorType = detectErrorType(e);

        final errorMessage = e
            .toString()
            .split("message:")
            .last
            .split(",")
            .first
            .trim();

        CustomErrorDialog.show(context, errorType, message: errorMessage);
      }
    }
  } else if (value == 'approve') {
    bool confirm = await showBackDialog(
      context,
      title: 'Submit Approve?',
      subtitle: "Are you sure you want to Approve ${expense.name}?",
      leftButtonName: "Cancel",
      rightButtonName: "Approve",
      function: () {
        Navigator.pop(context, true);
      },
    );

    if (confirm) {
      loadingDialog(
        context,
        "Approving Expense",
        "Please wait while Approving",
        LoadingAnimationWidget.fourRotatingDots(
          color: MoboColor.redColor,
          size: 30,
        ),
      );

      try {
        final version = Provider.of<ExpenseProvider>(
          context,
          listen: false,
        ).odooVersion;

        if (version == '19') {
          final result = await expenseProvider.buttonAction(
            'action_approve',
            'hr.expense',
            expense.id,
          );
          if (result) {
            expenseProvider.emptyApproval();

            await expenseProvider.getExpenses(context, true);
            await expenseProvider.loadExpenses();
            CustomSnackbar.showSuccess(
              context,
              "Expense State updated Successfully",
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            CustomSnackbar.showError(
              context,
              "Expense State not Succesfully updated",
            );
          }
        } else {
          final id = await expenseServices.gettingIdExpenseSheet(expense.id);

          final result = await expenseProvider.buttonAction(
            'action_approve_expense_sheets',
            'hr.expense.sheet',
            id,
          );
          if (result) {
            expenseProvider.emptyApproval();

            await expenseProvider.getExpenses(context, true);
            await expenseProvider.loadExpenses();

            CustomSnackbar.showSuccess(
              context,
              "Expense State updated Successfully",
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            CustomSnackbar.showError(
              context,
              "Expense State not Succesfully updated",
            );
          }
        }

        hideLoadingDialog(context);
      } catch (e) {
        hideLoadingDialog(context);
        final errorType = detectErrorType(e);

        final errorMessage = e
            .toString()
            .split("message:")
            .last
            .split(",")
            .first
            .trim();

        CustomErrorDialog.show(context, errorType, message: errorMessage);
      }
    }
  } else if (value == 'reset') {
    bool confirm = await showBackDialog(
      context,
      title: 'Submit reset?',
      subtitle: "Are you sure you want to Rest ${expense.name}?",
      leftButtonName: "Cancel",
      rightButtonName: "reset",
      function: () {
        Navigator.pop(context, true);
      },
    );

    if (confirm) {
      loadingDialog(
        context,
        "Resetting Expense",
        "Please wait while we resetting ..",
        LoadingAnimationWidget.fourRotatingDots(
          color: MoboColor.redColor,
          size: 30,
        ),
      );

      try {
        final version = Provider.of<ExpenseProvider>(
          context,
          listen: false,
        ).odooVersion;
        if (version == "19") {
          final result = await expenseProvider.buttonAction(
            'action_reset',
            'hr.expense',
            expense.id,
          );
          if (result) {
            expenseProvider.emptyApproval();

            await expenseProvider.getExpenses(context, true);
            await expenseProvider.loadExpenses();
            CustomSnackbar.showSuccess(
              context,
              "Expense State updated Successfully",
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            CustomSnackbar.showError(
              context,
              "Expense State not Succesfully updated",
            );
          }
        } else {
          final id = await expenseServices.gettingIdExpenseSheet(expense.id);

          final result = await expenseProvider.buttonAction(
            'action_reset_expense_sheets',
            'hr.expense.sheet',
            id,
          );
          if (result) {
            expenseProvider.emptyApproval();
            await expenseProvider.getExpenses(context, true);
            await expenseProvider.loadExpenses();
            CustomSnackbar.showSuccess(
              context,
              "Expense State updated Successfully",
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            CustomSnackbar.showError(
              context,
              "Expense State not Succesfully updated",
            );
          }
        }
      } catch (e) {
        hideLoadingDialog(context);
        final errorType = detectErrorType(e);

        final errorMessage = e
            .toString()
            .split("message:")
            .last
            .split(",")
            .first
            .trim();

        CustomErrorDialog.show(context, errorType, message: errorMessage);
      }
    }
  } else if (value == 'refuse') {
    bool confirm = await showBackDialog(
      context,
      title: 'Submit refuse?',
      subtitle: "Are you sure you want to Refuse ${expense.name}?",
      leftButtonName: "Cancel",
      rightButtonName: "refuse",
      function: () {
        Navigator.pop(context, true);
      },
    );

    if (confirm) {
      expenseProvider.clearRefuseReason();

      await dialogBoxWithTextField(
        context,
        formKey,
        expenseProvider.refuseReasonController,
        () async {
          if (formKey.currentState!.validate()) {
            loadingDialog(
              context,
              "Refusing",
              "Please wait while Refusing",
              LoadingAnimationWidget.fourRotatingDots(
                color: MoboColor.redColor,
                size: 30,
              ),
            );

            final version = Provider.of<ExpenseProvider>(
              context,
              listen: false,
            ).odooVersion;

            try {
              if (version == '19') {
                await expenseProvider.refuseAction(
                  expense.id,
                  context,
                  expenseProvider.refuseReasonController.text.trim(),
                );
              } else {
                final id = await expenseServices.gettingIdExpenseSheet(
                  expense.id,
                );

                await expenseProvider.refuseAction(
                  id,
                  context,
                  expenseProvider.refuseReasonController.text.trim(),
                );
              }
            } catch (e) {
              hideLoadingDialog(context);
              final errorType = detectErrorType(e);

              final errorMessage = e
                  .toString()
                  .split("message:")
                  .last
                  .split(",")
                  .first
                  .trim();

              CustomErrorDialog.show(context, errorType, message: errorMessage);
            }
          }
        },
      );
    }
  } else if (value == 'postJournal') {
    try {
      loadingDialog(
        context,
        "Posting Journal",
        "Please wait for fetching journal",
        LoadingAnimationWidget.fourRotatingDots(
          color: MoboColor.redColor,
          size: 30,
        ),
      );
      await expenseProvider.gettingPurchaseJournal();

      Navigator.pop(context);
      expenseProvider.initialJournal();
      expenseProvider.changeErrorJournal(false);

      if (expense.paymentMode == 'own_account') {
        bool confirm = await showBackDialog(
          context,
          title: 'Submit Journal?',
          subtitle: "Are you sure you want to Post Journal ${expense.name}?",
          leftButtonName: "Cancel",
          rightButtonName: "Post",
          function: () {
            Navigator.pop(context, true);
          },
        );

        if (confirm) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          final version = Provider.of<ExpenseProvider>(
            context,
            listen: false,
          ).odooVersion;

          if (version == '19') {
            dialogBox(
              context,
              "Post Expenses",
              HugeIcon(icon: HugeIcons.strokeRoundedBook04, color: Colors.red),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: DropdownMenu<JournalModel>(
                      label: Text(
                        expenseProvider.selectedJournal!.displayName!,
                        style: MoboText.h4,
                      ),
                      width: double.infinity,
                      inputDecorationTheme: const InputDecorationTheme(
                        border: OutlineInputBorder(),
                      ),
                      onSelected: (value) {
                        expenseProvider.changeErrorJournal(false);
                        expenseProvider.selectedJournal = value;
                      },

                      menuStyle: MenuStyle(
                        backgroundColor: WidgetStateProperty.all(
                          MoboColor.white,
                        ),
                        minimumSize: WidgetStateProperty.all(Size(300, 200)),
                        maximumSize: WidgetStateProperty.all(Size(300, 400)),
                      ),

                      dropdownMenuEntries: expenseProvider.totalJournal.map((
                        journal,
                      ) {
                        return DropdownMenuEntry<JournalModel>(
                          value: journal,
                          label: journal.displayName ?? '',
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 10),
                  textFormSearchListingWidget(
                    isDark: isDark,
                    error: false,
                    controller: expenseProvider.journalDateController,
                    readOnly: true,
                    context: context,
                    date: true,
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedDateTime),
                    hintText: "Date",
                    isLeading: false,
                    isSearching: false,
                  ),
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        key: Key("post_cancel"),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(120, 40),

                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text(
                          "cancel",
                          style: MoboText.normal.copyWith(color: Colors.black),
                        ),
                      ),

                      ElevatedButton(
                        key: Key("post_confirm"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(120, 40),

                          backgroundColor: MoboColor.redColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          loadingDialog(
                            context,
                            "Journal Posting",
                            "Please wait while Posting",
                            LoadingAnimationWidget.fourRotatingDots(
                              color: MoboColor.redColor,
                              size: 30,
                            ),
                          );

                          try {
                            final result = await expenseProvider
                                .postJournalAction(
                                  expense.id,
                                  expenseProvider.selectedJournal!.id!,
                                  expenseProvider.journalDateController.text,
                                );

                            if (result) {
                              await expenseProvider.getExpenses(
                                context,
                                Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).isAdmin,
                              );

                              await expenseProvider.loadExpenses();

                              CustomSnackbar.showSuccess(
                                context,
                                ' Successfully Posted journal',
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
                                "Error  in the Posting Journal",
                              );
                            }
                          } catch (e) {
                            Navigator.of(context, rootNavigator: true).pop();

                            CustomSnackbar.showError(
                              context,
                              '${e.toString().split("message:").last.split(",").first.trim()}',
                            );
                          } finally {
                            hideLoadingDialog(context);
                          }
                        },
                        child: Text(
                          "Post",
                          style: MoboText.h3.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (version == '17') {
            loadingDialog(
              context,
              "Journal Posting",
              "Please wait while Posting",
              LoadingAnimationWidget.fourRotatingDots(
                color: MoboColor.redColor,
                size: 30,
              ),
            );
            final id = await expenseServices.gettingIdExpenseSheet(expense.id);

            try {
              final result = await expenseProvider.buttonAction(
                'action_sheet_move_create',
                'hr.expense.sheet',
                id,
              );
              if (result) {
                await expenseProvider.getExpenses(context, true);
                await expenseProvider.loadExpenses();
                CustomSnackbar.showSuccess(
                  context,
                  "Expense State updated Successfully",
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              } else {
                CustomSnackbar.showError(
                  context,
                  "Expense State not Succesfully updated",
                );
              }
            } catch (e) {
              CustomSnackbar.showError(
                context,
                '${e.toString().split("message:").last.split(",").first.trim()}',
              );
            } finally {
              hideLoadingDialog(context);
            }
          } else {
            loadingDialog(
              context,
              "Journal Posting",
              "Please wait while Posting",
              LoadingAnimationWidget.fourRotatingDots(
                color: MoboColor.redColor,
                size: 30,
              ),
            );
            final id = await expenseServices.gettingIdExpenseSheet(expense.id);

            try {
              final result = await expenseProvider.buttonAction(
                'action_sheet_move_post',
                'hr.expense.sheet',
                id,
              );
              if (result) {
                await expenseProvider.getExpenses(context, true);
                await expenseProvider.loadExpenses();
                CustomSnackbar.showSuccess(
                  context,
                  "Expense State updated Successfully",
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              } else {
                CustomSnackbar.showError(
                  context,
                  "Expense State not Succesfully updated",
                );
              }
            } catch (e) {
              hideLoadingDialog(context);
              final errorType = detectErrorType(e);

              final errorMessage = e
                  .toString()
                  .split("message:")
                  .last
                  .split(",")
                  .first
                  .trim();

              CustomErrorDialog.show(context, errorType, message: errorMessage);
            }
          }
        }
      } else {
        dialogBox(
          context,
          "Post Expense",
          HugeIcon(icon: HugeIcons.strokeRoundedBook04, color: Colors.red),
          Column(
            children: [
              Text(
                "Are you sure you want to post journal?",
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(120, 40),

                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text(
                      "cancel",
                      style: MoboText.normal.copyWith(color: Colors.black),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(120, 40),

                      backgroundColor: MoboColor.redColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      loadingDialog(
                        context,
                        "Journal Posting",
                        "Please wait while Posting",
                        LoadingAnimationWidget.fourRotatingDots(
                          color: MoboColor.redColor,
                          size: 30,
                        ),
                      );

                      final session =
                          await OdooSessionManager.getCurrentSession();

                      final version = session!.odooSession.serverVersion;

                      try {
                        if (version == '19') {
                          final result = await expenseProvider
                              .postJournalAction(
                                expense.id,
                                expenseProvider.selectedJournal!.id!,
                                expenseProvider.journalDateController.text,
                                isPaidBySelf: false,
                              );
                          if (result) {
                            await expenseProvider.getExpenses(
                              context,
                              Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).isAdmin,
                            );

                            await expenseProvider.loadExpenses();

                            CustomSnackbar.showSuccess(
                              context,
                              ' Successfully Posted journal',
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
                              "Error in the post Journal",
                            );
                          }
                        } else {
                          final id = await expenseServices
                              .gettingIdExpenseSheet(expense.id);
                          final result = await expenseProvider.buttonAction(
                            'action_sheet_move_post',
                            'hr.expense.sheet',
                            id,
                          );
                          if (result) {
                            await expenseProvider.getExpenses(context, true);
                            await expenseProvider.loadExpenses();
                            CustomSnackbar.showSuccess(
                              context,
                              "Expense State updated Successfully",
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => HomeScreen()),
                              (Route<dynamic> route) => false,
                            );
                          } else {
                            CustomSnackbar.showError(
                              context,
                              "Expense State not Succesfully updated",
                            );
                          }
                        }
                      } catch (e) {
                        hideLoadingDialog(context);
                        final errorType = detectErrorType(e);

                        final errorMessage = e
                            .toString()
                            .split("message:")
                            .last
                            .split(",")
                            .first
                            .trim();

                        CustomErrorDialog.show(
                          context,
                          errorType,
                          message: errorMessage,
                        );
                      }
                    },
                    child: Text(
                      "Post",
                      style: MoboText.h3.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (expenseProvider.totalJournal.isEmpty) {
        CustomSnackbar.showWarning(
          context,
          "Journal is Empty so please ensure the company have journal",
        );
        return;
      }

      final errorType = detectErrorType(e);

      final errorMessage = e
          .toString()
          .split("message:")
          .last
          .split(",")
          .first
          .trim();

      CustomErrorDialog.show(context, errorType, message: errorMessage);
    }
  } else if (value == 'split') {
    bool confirm = await showBackDialog(
      context,
      title: 'Split Expense?',
      subtitle: "Are you sure you want to Split ${expense.name} expense?",
      leftButtonName: "Cancel",
      rightButtonName: "Split",
      function: () {
        Navigator.pop(context, true);
      },
    );
    if (confirm) {
      loadingDialog(
        context,
        "Splitting expense",
        "Please wait while we splitting you expense",
        LoadingAnimationWidget.fourRotatingDots(
          color: MoboColor.redColor,
          size: 30,
        ),
      );

      try {
        await expenseProvider.splitExpense(expense.id);
      } catch (e) {
        hideLoadingDialog(context);
        final errorType = detectErrorType(e);

        final errorMessage = e
            .toString()
            .split("message:")
            .last
            .split(",")
            .first
            .trim();

        CustomErrorDialog.show(context, errorType, message: errorMessage);
      }

      dialogBox(
        context,
        "Split Expense",
        HugeIcon(
          icon: HugeIcons.strokeRoundedPathfinderDivide,
          color: Colors.grey.shade700,
        ),

        Column(
          children: [
            const SizedBox(height: 12),

            /// HEADER

            /// LIST
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenseProvider.splitExpenseList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final split = expenseProvider.splitExpenseList[index];

                return Row(
                  children: [
                    /// EMPLOYEE FIELD
                    Expanded(
                      flex: 3,
                      child: TypeAheadField<Employee>(
                        controller: split.nameController,
                        suggestionsCallback: (pattern) {
                          return context
                              .read<CommonProvider>()
                              .gettingTypedListEmployee(pattern);
                        },
                        itemBuilder: (context, employee) {
                          return ListTile(title: Text(employee.name));
                        },
                        onSelected: (employee) {
                          split.nameController.text = employee.name ?? '';
                          split.employeeName = employee.name;
                          split.employeeId = employee.id;
                        },
                        builder: (context, controller, focusNode) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Employee',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// AMOUNT
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          split.amountController.text,
                          style: MoboText.h4,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            /// ACTIONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      hideLoadingDialog(context);
                      Navigator.pop(context, false);
                    },
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    key: Key("split"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      backgroundColor: MoboColor.redColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        loadingDialog(
                          context,
                          "Splitting expense",
                          "Please wait while we splitting you expense",
                          LoadingAnimationWidget.fourRotatingDots(
                            color: MoboColor.redColor,
                            size: 30,
                          ),
                        );

                        for (final split in expenseProvider.splitExpenseList) {
                          split.syncFromControllers();
                        }

                        final invalid = expenseProvider.splitExpenseList.any(
                          (e) => e.employeeId == null,
                        );

                        if (invalid) {
                          CustomSnackbar.showError(
                            context,
                            'Please select employee',
                          );
                          return;
                        }

                        final linesEdited = await ExpenseServices()
                            .editingSplitLines(
                              expenseProvider.splitExpenseList,
                            );

                        if (linesEdited) {
                          await ExpenseServices().submitSplitting(
                            expenseProvider.wizardId,
                          );

                          await context.read<ExpenseProvider>().loadExpenses();

                          CustomSnackbar.showSuccess(
                            context,
                            'Split successful',
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => HomeScreen()),
                            (_) => false,
                          );
                        }
                      } catch (e) {
                        hideLoadingDialog(context);
                        final errorType = detectErrorType(e);

                        final errorMessage = e
                            .toString()
                            .split("message:")
                            .last
                            .split(",")
                            .first
                            .trim();

                        CustomErrorDialog.show(
                          context,
                          errorType,
                          message: errorMessage,
                        );
                      }
                    },
                    child: const Text("Split"),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
