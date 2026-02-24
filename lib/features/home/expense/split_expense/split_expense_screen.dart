import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/provider/split_expense_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/expense_card.dart';

class SplitExpenseScreen extends StatefulWidget {
  final int id;
  const SplitExpenseScreen({super.key, required this.id});

  @override
  State<SplitExpenseScreen> createState() => _SplitExpenseScreenState();
}

class _SplitExpenseScreenState extends State<SplitExpenseScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SplitExpenseProvider>().initialLoading(context, widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,

      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
        title: Text(
          "Expense Split Details",
          style: MoboText.h2.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
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
      body: Consumer<SplitExpenseProvider>(
        builder: (context, splitExpenseProvider, child) {
          return Padding(
            padding: MoboPadding.pagePadding,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  splitExpenseProvider.isLoading
                      ? ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(
                            6,
                            (_) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: CardLoading(
                                height: 150,
                                borderRadius: BorderRadius.circular(
                                  MoboRadius.card,
                                ),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: splitExpenseProvider.expenseList.length,
                          itemBuilder: (context, index) {
                            final expense =
                                splitExpenseProvider.expenseList[index];

                            return expenseCardWidget(
                              context,

                              /// UI DATA
                              name: expense.employeeId[1],
                              description: expense.name,
                              date: expense.date ?? "",
                              paidBy: expense.paymentMode,
                              status: expense.state,
                              amount: expense.totalAmount.toString(),

                              /// FULL MODEL
                              expense: expense,
                            );
                          },
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
