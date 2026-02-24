import 'package:odoo_rpc/odoo_rpc.dart';

import '../features/home/invoice/model/journal_payment_model.dart';

class PaymentServices {
  ///fetch payment journal
  Future fetchPaymentJournals(OdooClient client) async {
    final result = await client.callKw({
      'model': 'account.move',
      'method': 'action_register_payment',
      'args': [
        [84],
      ],

      'kwargs': {},
    });
  }

  ///fetch journal
  getJournal(
    OdooClient client, {
    required String model,
    String typed = '',
    bool isItJournal = false,
  }) async {
    try {
      final List domain = [
        ['company_id', '=', 1],
      ];

      if (isItJournal) {
        domain.add([
          'type',
          'in',
          ['bank'],
        ]);
      }

      if (typed.trim().isNotEmpty) {
        domain.add(["name", 'ilike', typed]);
      }
      final result = await client.callKw({
        'model': model,
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': domain,
          'fields': ['id', 'name'],
        },
      });

      final res = result as List;
      final journalList = res
          .map((item) => JournalPaymentModel.fromJson(item))
          .toList();

      return journalList;
    } catch (e) {}
  }

  ///fetch active ids
  Future getActiveIds(OdooClient client, int invoiceId) async {
    try {
      final res = await client.callKw({
        'model': 'account.move',
        'method': 'action_register_payment',
        'args': [
          [invoiceId],
        ],

        'kwargs': {},
      });

      return res;
    } catch (e) {}
  }

  ///create payment wizard

  Future createPaymentWizard({
    required OdooClient client,
    required int journalId,
    required int paymentMethodLineId,

    required double amount,

    required Map<String, dynamic> context,
  }) async {
    try {
      final wizardId = await client.callKw({
        'model': 'account.payment.register',
        'method': 'create',
        'args': [
          {
            'journal_id': journalId,
            'payment_method_line_id': paymentMethodLineId,
            'amount': amount,
          },
        ],
        'kwargs': {'context': context},
      });

      await client.callKw({
        'model': 'account.payment.register',
        'method': 'action_create_payments',
        'args': [
          [wizardId],
        ],
        'kwargs': {},
      });
    } catch (e) {}
  }
}
