import 'package:flutter/material.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/snackbar.dart';
import '../../../provider/common_provider.dart';
import '../../../provider/user_provider.dart';
import 'category_screen.dart';
import 'company_category_screen.dart';
import 'company_department.dart';
import 'company_report_screen.dart';
import 'employees_report.dart';
import 'monthly_report.dart';
import 'paid_report.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int selectedIndex = 0;
  String odooVersion = '';

  Future<void> initialLoading() async {
    try {
      final commonProvider = Provider.of<CommonProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final version = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).odooVersion;

      setState(() {
        odooVersion = version;
      });

      if (commonProvider.monthlyExpenseList.isEmpty) {
        commonProvider.changingLoading(true);

        await commonProvider.getMonthlyBasisReport();
        await commonProvider.getPaidExpenseReport();
        await commonProvider.getCategoryReport();

        if (userProvider.isAdmin) {
          await commonProvider.getCompanyMonthlyExpense();
          await commonProvider.getCompanyWiseCategories();
          if (version.contains('19')) await commonProvider.getCompanyWiseDepartment();
          await commonProvider.getCompanyEmployees();
        }
      }
    } catch (e) {
      showSnackBar(context, "Error occurred fetching report");
    } finally {
      Provider.of<CommonProvider>(
        context,
        listen: false,
      ).changingLoading(false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initialLoading());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commonProvider = context.watch<CommonProvider>();
    final userProvider = context.watch<UserProvider>();

    final tabs = userProvider.isAdmin
        ? [
            "Monthly Report",
            "Category",
            "Reimbursement",
            "Company",
            "All category",
            if (odooVersion.contains('19')) "Department",
            "Employees",
          ]
        : ["Monthly Report", "Category", "Reimbursement"];

    final pages = userProvider.isAdmin
        ? [
            const MonthlyReport(),
            CategoryScreen(categoryReport: commonProvider.categoryReportList),
            const PaidReport(),
            const CompanyReportScreen(),
            CompanyCategoryScreen(
              categoryReport: commonProvider.companyCategoryReportList,
            ),

            if (odooVersion.contains('19'))
              CompanyDepartment(
                companyDepartment: commonProvider.companyDepartmentList,
              ),
            EmployeesReport(
              companyEmployeeReport: commonProvider.employeesReportLis,
            ),
          ]
        : [
            const MonthlyReport(),
            CategoryScreen(categoryReport: commonProvider.categoryReportList),
            const PaidReport(),
          ];

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 10),
        child: Column(
          children: [
            SizedBox(
              height: 36,
              child: ListView.separated(
                key: Key("top List"),
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black
                            : (isDark ? Colors.white : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey : Colors.grey.shade600),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: IndexedStack(index: selectedIndex, children: pages),
            ),
          ],
        ),
      ),
    );
  }
}
