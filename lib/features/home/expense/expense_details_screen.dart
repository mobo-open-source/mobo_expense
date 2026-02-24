import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/features/home/expense/payment_slip.dart';
import 'package:mobo_expenses/features/home/expense/split_expense/split_expense_screen.dart';
import 'package:mobo_expenses/features/home/expense/widget/bottom_sheet.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:mobo_expenses/services/expense_services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../shared/widgets/snackbars/custom_snackbar.dart';
import '../edit_expense/edit_expense.dart';
import '../invoice/invoice_screen.dart';
import 'helper/pop_up_menu_action.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final Expense expense;
  final Color bgColor;
  final Color statusColor;
  const ExpenseDetailsScreen({
    super.key,
    required this.expense,
    required this.bgColor,
    required this.statusColor,
  });

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  bool isLoading = true;

  String state = "";

  @override
  void initState() {
    /// TODO: implement initState
    super.initState();
    if (widget.expense.state == "approved") {
      initialCalling();
    } else {
      isLoading = false;
    }
  }

  ///initial calling
  Future<void> initialCalling() async {
    setState(() => isLoading = true);
    final services = ExpenseServices();
    final version = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).odooVersion;

    if (version == '18' || version == '17') {
      final res = await services.gettingState(widget.expense.id);
      state = res;
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userProvider = context.read<UserProvider>();
    final commonProvider = context.read<CommonProvider>();
    final expenseProvider = context.read<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
        title: Text(
          "Expense Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),

        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
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
        actions: [
          /// action buttons
          widget.expense.splitExpense.isEmpty
              ? SizedBox()
              : InkWell(
                  onTap: () async {
                    await ExpenseServices().gettingSplitExpense(
                      widget.expense.splitExpense[0],
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SplitExpenseScreen(
                          id: widget.expense.splitExpense[0],
                        ),
                      ),
                    );
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedPathfinderDivide,
                    color: isDark ? Colors.white : Colors.grey.shade700,
                  ),
                ),

          SizedBox(width: 25),
          widget.expense.state == 'posted' || widget.expense.state == 'paid'
              ? widget.expense.paymentMode != "own_account"
                    ? InkWell(
                        key: Key("payment_slip"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PaymentSlipPage(id: widget.expense.id),
                            ),
                          );
                        },

                        child: InkWell(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedInvoice02,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      )
                    : InkWell(
                        key: Key("invoice"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  InvoiceScreen(id: widget.expense.id),
                            ),
                          );
                        },

                        child: InkWell(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedInvoice02,
                            color: isDark ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      )
              : SizedBox.shrink(),

          userProvider.isAdmin
              ? widget.expense.state == 'posted' ||
                        widget.expense.state == 'paid' ||
                        widget.expense.state == 'approved' ||
                        widget.expense.state == 'done'
                    ? SizedBox()
                    : InkWell(
                        onTap: () async {
                          try {
                            await commonProvider.currentExpenseEmployee(
                              selected: true,
                              id: widget.expense.employeeId[0],
                            );
                            commonProvider.initial(widget.expense);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditExpense(currentExpense: widget.expense),
                              ),
                            );
                          } catch (e) {
                            CustomSnackbar.showError(
                              context,
                              "Please  check Expense in the selected company",
                            );
                          }
                        },
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedPencilEdit02,
                          color: isDark
                              ? Colors.white
                              : isDark
                              ? Colors.white
                              : Colors.grey.shade800,
                        ),
                      )
              : widget.expense.state == "draft"
              ? InkWell(
                  key: Key("Edit"),
                  onTap: () async {
                    await commonProvider.currentExpenseEmployee();

                    commonProvider.initial(widget.expense);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditExpense(currentExpense: widget.expense),
                      ),
                    );
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                  ),
                )
              : SizedBox(),

          userProvider.isAdmin
              ? PopupMenuButton(
                  enabled: !isLoading,
                  key: Key("PopupMenuAdmin"),

                  iconColor: isDark ? Colors.white : Colors.black,

                  onSelected: (String value) async {
                    gettingSelected(value, context, widget.expense);
                  },

                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(MoboRadius.card),
                  constraints: BoxConstraints(minWidth: 200),
                  itemBuilder: (context) {
                    List<PopupMenuEntry<String>> items = [
                      PopupMenuItem(
                        key: Key("popupdelete"),

                        value: "delete",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedDelete02,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ];

                    if (expenseProvider.odooVersion == "19") {
                      if (widget.expense.state == 'draft') {
                        items.addAll([
                          PopupMenuItem(
                            key: Key("submit_19"),
                            value: 'submit',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedUpload04,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Submit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'split',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedPathfinderDivide,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Split'),
                              ],
                            ),
                          ),
                        ]);
                      }

                      if (widget.expense.state == 'submitted') {
                        items.addAll([
                          PopupMenuItem(
                            key: Key("approve_19"),
                            value: 'approve',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedTick01,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Approve'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'refuse',
                            key: Key("refuse_19"),
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancel01,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Refuse'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            key: Key("reset_19"),
                            value: 'reset',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedResetPassword,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Reset'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'split',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedPathfinderDivide,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Split'),
                              ],
                            ),
                          ),
                        ]);
                      }

                      if (widget.expense.state == 'approved') {
                        items.addAll([
                          PopupMenuItem(
                            key: Key("journal_19"),
                            value: 'postJournal',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedBook04,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Post Journal'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            key: Key("refuse"),
                            value: 'refuse',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancel01,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Refuse'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            key: Key("reset_key"),
                            value: 'reset',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedResetPassword,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Reset'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            key: Key("split_approval"),
                            value: 'split',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedPathfinderDivide,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Split'),
                              ],
                            ),
                          ),
                        ]);
                      }

                      if (widget.expense.state == 'posted') {
                        items.add(
                          PopupMenuItem(
                            value: 'reset',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedResetPassword,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Reset'),
                              ],
                            ),
                          ),
                        );
                      }

                      if (widget.expense.state == 'paid') {
                        items.add(
                          PopupMenuItem(
                            value: 'reset',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedResetPassword,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Reset'),
                              ],
                            ),
                          ),
                        );
                      }

                      if (widget.expense.state == 'refused') {
                        items.add(
                          PopupMenuItem(
                            value: 'reset',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedResetPassword,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Reset'),
                              ],
                            ),
                          ),
                        );
                      }
                    } else {
                      if (widget.expense.state == 'draft') {
                        items.addAll([
                          PopupMenuItem(
                            key: Key("report"),
                            value: 'report',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedUpload04,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Create Report'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'split',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedPathfinderDivide,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Split'),
                              ],
                            ),
                          ),
                        ]);
                      }
                      if (widget.expense.state == 'reported') {
                        items.addAll([
                          PopupMenuItem(
                            key: Key("submit"),
                            value: 'submit',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedUpload04,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Submit to Manager'),
                              ],
                            ),
                          ),
                        ]);
                      }
                      if (widget.expense.state == 'submitted') {
                        items.addAll([
                          PopupMenuItem(
                            key: Key("approving"),
                            value: 'approve',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedUpload04,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Approve'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            key: Key("refusing"),
                            value: 'refuse',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancel01,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Refuse'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            key: Key("resetting"),
                            value: 'reset',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedResetPassword,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Reset'),
                              ],
                            ),
                          ),
                        ]);
                      }
                      if (widget.expense.state == 'approved') {
                        state == 'post'
                            ? items.addAll([
                                PopupMenuItem(
                                  value: 'reset',
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons
                                            .strokeRoundedResetPassword,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 10),
                                      Text('Reset'),
                                    ],
                                  ),
                                ),
                              ])
                            : items.addAll([
                                PopupMenuItem(
                                  value: 'postJournal',
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedBook04,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 10),
                                      Text('Post Journal'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'refuse',
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedCancel01,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 10),
                                      Text('Refuse'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'reset',
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons
                                            .strokeRoundedResetPassword,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 10),
                                      Text('Reset'),
                                    ],
                                  ),
                                ),
                              ]);
                      }

                      if (widget.expense.state == 'refused') {
                        items.add(
                          PopupMenuItem(
                            value: 'reset',
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedResetPassword,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 10),
                                Text('Reset'),
                              ],
                            ),
                          ),
                        );
                      }
                    }

                    return items;
                  },
                )
              : PopupMenuButton(
                  onSelected: (String value) async {
                    gettingSelected(value, context, widget.expense);
                  },

                  color: Colors.white,
                  borderRadius: BorderRadius.circular(MoboRadius.card),
                  itemBuilder: (context) {
                    List<PopupMenuEntry<String>> items = [
                      PopupMenuItem(
                        value: "delete",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedDelete02,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ];

                    if (widget.expense.state == 'draft') {
                      items.addAll([
                        PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedUpload04,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 10),
                              Text('Create Report'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'split',
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedPathfinderDivide,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 10),
                              Text('Split'),
                            ],
                          ),
                        ),
                      ]);
                    }
                    if (widget.expense.state == 'reported') {
                      items.addAll([
                        PopupMenuItem(
                          value: 'submit',
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedUpload04,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 10),
                              Text('Submit to Manager'),
                            ],
                          ),
                        ),
                      ]);
                    }

                    if (widget.expense.state == 'submitted') {
                      items.addAll([
                        PopupMenuItem(
                          value: 'reset',
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedResetPassword,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Reset',
                                style: MoboText.h4.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }

                    return items;
                  },
                ),
        ],
      ),
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
      body: Padding(
        padding: MoboPadding.pagePadding,
        child: Column(
          children: [
            isLoading
                ? Expanded(
                    child: Column(
                      children: const [
                        CardLoading(height: 100),
                        SizedBox(height: 20),
                        CardLoading(height: 100),
                        SizedBox(height: 20),
                        CardLoading(height: 100),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              MoboRadius.card,
                            ),
                            color: isDark ? Colors.grey[800] : Colors.white,
                            boxShadow: [MoboShadows.soft],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            widget.expense.name,
                                            style: TextStyle(
                                              fontSize: 23,
                                              color: isDark
                                                  ? Colors.white
                                                  : MoboColor.redColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: widget.bgColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    MoboRadius.button,
                                                  ),
                                            ),
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              widget.expense.state,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: widget.statusColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Text(
                                        widget.expense.employeeId.length > 1
                                            ? widget.expense.employeeId[1]
                                                  .toString()
                                            : '',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 5),

                                Row(
                                  children: [
                                    Text(
                                      "${widget.expense.companyId[1].toString()}",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Text("Paid : "),
                                    Text(
                                      widget.expense.paymentMode ==
                                              "own_account"
                                          ? " Self paid"
                                          : " company",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.expense.date,
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),

      bottomSheet: isLoading
          ? SizedBox.shrink()
          : ExpenseBottomSheet(expense: widget.expense),
    );
  }
}
