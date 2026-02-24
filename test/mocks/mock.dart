import 'package:mobo_expenses/model/expense_attachment_model.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mobo_expenses/services/common_service.dart';
import 'package:mobo_expenses/services/expense_services.dart';
import 'package:mocktail/mocktail.dart';

class MockServices extends Mock implements ExpenseServices {}

class MockCommonServices extends Mock implements CommonServices {}

class FakeExpense extends Fake implements Expense {}

class FakeExpenseAttachment extends Fake implements ExpenseAttachmentModel {}
