import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_expenses/features/home/invoice/payment_screen.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/loading.dart';
import '../../../core/utils/show_back_dialog.dart';

class InvoiceScreen extends StatefulWidget {
  final int id;
  const InvoiceScreen({super.key, required this.id});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  void initState() {
    /// TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initialLoading());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final expenseProvider = context.watch<ExpenseProvider>();
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
        elevation: 0,
        title: Text(
          "Invoice Details",
          style: TextStyle(
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w800,
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
        actions: [
          PopupMenuButton(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MoboRadius.card),
            iconColor: isDark ? Colors.white : Colors.black,
            onSelected: (String value) async {
              if (value == "print") {
                loadingDialog(
                  context,
                  "Generating PDF",
                  "Please wait while we prepare your document",
                  LoadingAnimationWidget.fourRotatingDots(
                    color: MoboColor.redColor,
                    size: 30,
                  ),
                );

                try {
                  final pdf = await expenseProvider.downloadInvoice(
                    expenseProvider.invoice!.id!,
                  );

                  await OpenFile.open(pdf.path);
                } catch (e) {
                } finally {
                  hideLoadingDialog(context);
                }
              } else if (value == 'payment') {
                bool confirm = await showBackDialog(
                  context,
                  title: 'Pay Expense?',
                  subtitle: "Are you sure you want to Pay?",
                  leftButtonName: "Cancel",
                  rightButtonName: "Pay",
                  function: () {
                    Navigator.pop(context, true);
                  },
                );
                if (confirm) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        amount: expenseProvider.invoice!.amountDue!,
                        paymentMethodLineId: 1,
                        id: expenseProvider.invoice!.id!,
                        title: expenseProvider.invoice!.ref!,
                      ),
                    ),
                  );
                }
              }
            },

            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: "print",
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedFileDownload,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Print",
                        style: MoboText.h4.copyWith(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),

      bottomSheet: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          if (expenseProvider.invoice == null) {
            return const SizedBox.shrink();
          }

          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  offset: Offset(0, -3),
                  color: Colors.black26,
                ),
              ],
            ),
            child: Column(
              children: [
                _row(
                  "Untaxed Amount",
                  expenseProvider.invoice!.amountUntaxed,
                  context,
                ),
                _row("Tax Amount", expenseProvider.invoice!.taxAmount, context),
                const SizedBox(height: 10),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primary,
                    child: _row(
                      "Total Amount",
                      expenseProvider.invoice!.amount,
                      context,
                      isWhite: true,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      ///invoice screen body
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return Padding(
            padding: MoboPadding.pagePadding,
            child: SingleChildScrollView(
              child: expenseProvider.invoiceLoading
                  ? ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(
                        5,
                        (_) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CardLoading(
                            height: 200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  : expenseProvider.invoice == null
                  ? ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(
                        5,
                        (_) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CardLoading(
                            height: 200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            expenseProvider.invoice!.name!,
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: isDark
                                                  ? Colors.white
                                                  : MoboColor.redColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            expenseProvider
                                                .invoice!
                                                .partnerName!
                                                .split(',')
                                                .last
                                                .trim(),
                                            style: MoboText.h3,
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                    ),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            expenseProvider.invoice!.state!,
                                            style: MoboText.h4.copyWith(
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  children: [
                                    Text("Bill ref:  "),
                                    Text(expenseProvider.invoice!.ref!),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Journal:  "),
                                    Text(expenseProvider.invoice!.journalName!),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      expenseProvider.invoice!.invoiceDate,
                                      style: TextStyle(
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const SizedBox(height: 40),

                        const SizedBox(height: 200),

                        /// breathing room at the bottom
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  ///initial loading method

  initialLoading() async {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );

    expenseProvider.gettingInvoice(widget.id, context);
  }

  Widget _row(
    String label,
    dynamic value,
    BuildContext context, {
    bool isWhite = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isWhite
                  ? Colors.white
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isWhite
                  ? Colors.white
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  ///invoice line row widget
  Widget invoiceLineRow(String title, String qty, String amount) {
    return Row(
      children: [
        Expanded(child: Text(title, style: MoboText.h4)),
        SizedBox(
          width: 80,
          child: Text(qty, textAlign: TextAlign.right, style: MoboText.h4),
        ),
        SizedBox(
          width: 100,
          child: Text(amount, textAlign: TextAlign.right, style: MoboText.h4),
        ),
      ],
    );
  }
}
