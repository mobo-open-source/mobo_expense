import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/expense_card.dart';
import '../../core/widgets/pagination/pagination_controller.dart';
import '../../provider/expense_provider.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  @override
  void initState() {
    /// TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initialLoading());
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Expense Approval",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    PaginationControls(
                      canGoToPreviousPage:
                          expenseProvider.canGoPreviousApproval,
                      canGoToNextPage: expenseProvider.canGoNextApproval,
                      onPreviousPage: () =>
                          expenseProvider.previousPageApproval(
                            isAdmin: true,
                            isApproved: true,
                          ),
                      onNextPage: () => expenseProvider.nextPageApproval(
                        admin: true,
                        isApproved: true,
                      ),
                      paginationText: expenseProvider.paginationTextApproval,
                      isDark: isDark,
                      theme: Theme.of(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await expenseProvider.loadExpensesApproval(
            isApproved: true,
            admin: true,
            reset: true,
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: MoboPadding.pagePadding,
            child: Column(
              children: [
                expenseProvider.isLoading
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return CardLoading(
                            height: 150,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            margin: EdgeInsets.only(bottom: 10),
                          );
                        },
                      )
                    : expenseProvider.approvalExpense.isEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.10,
                              ),
                              SizedBox(
                                height: 200,
                                child: Lottie.asset(
                                  'assets/lotties/empty ghost.json',
                                ),
                              ),
                              Text("No Expense Founded", style: MoboText.h2),
                              SizedBox(height: 20),
                              Text(
                                "No Expense found.There no expense  for approvals",
                                style: MoboText.h4,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: expenseProvider.approvalExpense.length,
                        itemBuilder: (context, index) {
                          final singleItems =
                              expenseProvider.approvalExpense[index];

                          return expenseCardWidget(
                            context,
                            expense: singleItems,
                            name: singleItems.employeeId[1],
                            description: singleItems.name,
                            date: singleItems.date,
                            paidBy: singleItems.paymentMode,
                            amount: singleItems.totalAmount.toString(),
                            status: singleItems.state,
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///initial loading

  Future initialLoading() async {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );

    if (expenseProvider.approvalExpense.isEmpty) {
      await expenseProvider.loadExpensesApproval(
        isApproved: true,
        admin: true,
        reset: true,
      );
    }
  }
}
