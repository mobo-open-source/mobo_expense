import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/services/payment_reciept.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/services/odoo_session_manager.dart';
import '../../../core/utils/loading.dart';
import '../../../core/widgets/submit_button.dart';

class PaymentSlipPage extends StatefulWidget {
  final int id;

  const PaymentSlipPage({super.key, required this.id});

  @override
  State<PaymentSlipPage> createState() => _PaymentSlipPageState();
}

class _PaymentSlipPageState extends State<PaymentSlipPage> {
  initialLoading() async {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );

    expenseProvider.gettingInvoice(widget.id, context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initialLoading());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Slip", style: MoboText.h2),

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
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final payslip = expenseProvider.paySlip;

          if (expenseProvider.invoiceLoading) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CardLoading(height: 100),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CardLoading(height: 100),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CardLoading(height: 100),
                  ),
                ],
              ),
            );
          }

          if (payslip == null || payslip.isEmpty) {
            return const Center(child: Text("No payment data found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MoboRadius.card),
                    color: Colors.white,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payslip['name'] ?? "-",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: MoboColor.redColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    payslip['state'] ?? "-",
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

                        _spaceBetween("Memo", payslip['memo'] ?? "-"),

                        const SizedBox(height: 10),
                        _spaceBetween(
                          "Bill Date",
                          payslip['date']?.toString() ?? "-",
                        ),

                        const SizedBox(height: 10),
                        _spaceBetween(
                          "Journal",
                          payslip['journal_id'] is List
                              ? payslip['journal_id'][1]
                              : "-",
                        ),

                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Amount",
                              style: MoboText.h3.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "₹ ${((payslip['amount'] as num?) ?? 0).toStringAsFixed(2)}",
                              style: MoboText.h3.copyWith(
                                fontWeight: FontWeight.w700,
                                color: MoboColor.redColor,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                        submitButton(
                          leading: HugeIcon(
                            icon: HugeIcons.strokeRoundedFileDownload,
                            color: Colors.white,
                          ),
                          title: "Download",
                          color: MoboColor.redColor,
                          onclick: () async {
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
                              final services = OdooPdfDownloader();

                              final session =
                                  await OdooSessionManager.getCurrentSession();
                              final pdf = await services.downloadPaymentPdf(
                                odooUrl: session!.serverUrl,
                                sessionId: session.sessionId,
                                paymentId: payslip['id'],
                              );

                              await OpenFile.open(pdf.path);
                            } catch (e) {
                            } finally {
                              hideLoadingDialog(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _spaceBetween(String title, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title)),
        Flexible(child: Text(content)),
      ],
    );
  }

  Widget _responsiveRow(
    String title,
    String value, {
    bool isBold = false,
    bool isMultiline = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
