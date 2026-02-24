import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_expenses/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/loading.dart';
import '../../../core/utils/show_back_dialog.dart';
import '../../../core/utils/snackbar.dart';
import '../../../core/widgets/button_widget.dart';
import '../../../core/widgets/textform_search_listing.dart';
import '../../../services/payment_services.dart';
import '../home_screen.dart';
import 'model/journal_payment_model.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final int paymentMethodLineId;
  final String title;
  final int id;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.paymentMethodLineId,
    required this.title,
    required this.id,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final searchController = TextEditingController();
  final amountController = TextEditingController();
  late final TextEditingController dateController;
  late final TextEditingController memoController;
  final paymentMethodController = TextEditingController();
  final receiptController = TextEditingController();

  int selectedJournalId = 0;
  int paymentId = 0;

  @override
  void initState() {
    super.initState();

    dateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
    );

    memoController = TextEditingController(text: widget.title);
    amountController.text = widget.amount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    searchController.dispose();
    amountController.dispose();
    dateController.dispose();
    memoController.dispose();
    paymentMethodController.dispose();
    receiptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        /// back dialog box
        bool confirm = await showBackDialog(
          context,
          title: 'Payment',
          subtitle:
              "You have unsaved data that will be lost if you leave this page. Are you sure?",
          leftButtonName: "Stay",
          rightButtonName: "Leave",
          function: () => Navigator.pop(context, true),
        );

        if (confirm) {
          Navigator.pop(context, result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Register Payment"),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: MoboPadding.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///  Journal
                _sectionTitle("Journal"),
                TypeAheadField<JournalPaymentModel>(
                  controller: searchController,
                  loadingBuilder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                  itemBuilder: (context, journal) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: MoboColor.redColor.withOpacity(0.1),
                      child: Text(journal.name[0]),
                    ),
                    title: Text(journal.name),
                  ),
                  onSelected: (journal) {
                    searchController.text = journal.name;
                    selectedJournalId = journal.id;
                  },
                  builder: (context, controller, focusNode) {
                    return TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: controller,
                      focusNode: focusNode,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Journal is required';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Search Journal',
                      ),
                    );
                  },
                  suggestionsCallback: (pattern) async {
                    final services = PaymentServices();
                    return await services.getJournal(
                      authProvider.client!,
                      model: 'account.journal',
                      typed: pattern,
                      isItJournal: true,
                    );
                  },
                ),

                const SizedBox(height: 16),

                /// Amount
                _sectionTitle("Amount"),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter amount',
                  ),
                ),

                const SizedBox(height: 16),

                ///  Payment Date
                _sectionTitle("Payment Date"),
                textFormSearchListingWidget(
                  isDark: isDark,

                  controller: dateController,
                  readOnly: true,
                  context: context,
                  date: true,
                  error: false,

                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDateTime,
                    color: Colors.black,
                  ),
                  hintText: "Select Date",
                  isLeading: false,
                  isSearching: false,
                ),

                const SizedBox(height: 16),

                ///  Memo
                _sectionTitle("Memo"),
                TextFormField(
                  readOnly: true,
                  controller: memoController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Memo is required';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Add memo',
                  ),
                ),

                const SizedBox(height: 16),

                ///  Payment Method
                _sectionTitle("Payment Method"),
                TypeAheadField<JournalPaymentModel>(
                  controller: paymentMethodController,
                  loadingBuilder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                  itemBuilder: (context, journal) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: MoboColor.redColor.withOpacity(0.1),
                      child: Text(journal.name[0]),
                    ),
                    title: Text(journal.name),
                  ),
                  onSelected: (journal) {
                    paymentMethodController.text = journal.name;
                    paymentId = journal.id;
                  },
                  builder: (context, controller, focusNode) {
                    return TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: controller,
                      focusNode: focusNode,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Payment method is required';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Search method',
                      ),
                    );
                  },
                  suggestionsCallback: (pattern) async {
                    final services = PaymentServices();
                    return await services.getJournal(
                      authProvider.client!,
                      model: 'account.payment.method.line',
                      typed: pattern,
                    );
                  },
                ),

                const SizedBox(height: 16),

                ///  Receipt
                _sectionTitle("Receipt"),
                TextFormField(
                  controller: receiptController,

                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Add receipt reference',
                  ),
                ),

                const SizedBox(height: 50),

                ///  PAY BUTTON
                buttonWidget(
                  onclick: _onPayPressed,
                  title: "PAY",
                  clickable: true,
                  isLoading: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///  Pay button logic
  void _onPayPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (paymentId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

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
      final services = PaymentServices();

      final authProvider = context.read<AuthProvider>();

      final response = await services.getActiveIds(
        authProvider.client!,
        widget.id,
      );

      final resModel = response['res_model'];
      final activeContext = response['context'];

      await services.createPaymentWizard(
        client: authProvider.client!,
        journalId: selectedJournalId,
        paymentMethodLineId: widget.paymentMethodLineId,
        amount: double.parse(amountController.text.trim()),
        context: activeContext,
      );
      showSnackBar(
        context,
        'Payed Succesfully ',
        backgroundColor: Colors.green,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
    } finally {
      hideLoadingDialog(context);
    }

    /// TODO: Call Odoo register payment API
  }

  ///  Section Title Widget
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title, style: MoboText.h3),
    );
  }
}
