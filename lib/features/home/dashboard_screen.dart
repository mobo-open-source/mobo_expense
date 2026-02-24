import 'dart:developer';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../core/widgets/analytic_card.dart';
import '../../core/widgets/barchart_card.dart';
import '../../core/widgets/business_card.dart';
import '../../shared/widgets/snackbars/custom_snackbar.dart';
import '../profile/providers/profile_provider.dart';

class DashboardScreen extends StatefulWidget {
  final bool istest;
  const DashboardScreen({super.key, this.istest = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.istest) return;

    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoading());
  }

  Future<void> _initialLoading() async {
    final expense = context.read<ExpenseProvider>();
    final user = context.read<UserProvider>();
    final common = context.read<CommonProvider>();

    try {
      if (!expense.isInitialLoading) {
        return;
      }
      expense.setInitialLoading(true);
      await user.getUserDetails(context);
      await expense.getOdooVersion();
      await expense.getExpenses(context, user.isAdmin);
      await common.getCompanyWiseCategories();
      await expense.gettingPurchaseJournal();
      await common.getAllCategory(reset: true);
      await common.getFullTax();
    } catch (e) {
      CustomSnackbar.showError(context, e.toString());
    } finally {
      expense.setInitialLoading(false);
      expense.markInitialLoaded();
    }
  }

  ///dashboard skeleton
  Widget dashboardSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardLoading(height: 110, borderRadius: BorderRadius.circular(12)),
        const SizedBox(height: 20),

        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (_, i) => CardLoading(
              width: 250,
              height: 150,
              margin: const EdgeInsets.only(right: 12),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: 4,
          itemBuilder: (_, __) =>
              CardLoading(height: 120, borderRadius: BorderRadius.circular(12)),
        ),

        const SizedBox(height: 20),

        CardLoading(height: 220, borderRadius: BorderRadius.circular(12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    final userProvider = context.read<UserProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
      body: Consumer<ExpenseProvider>(
        builder: (context, expense, child) {
          if (expense.isInitialLoading) {
            return RefreshIndicator(
              onRefresh: () async {},
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: MoboPadding.pagePadding,
                  child: dashboardSkeleton(),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await expense.getExpenses(context, userProvider.isAdmin);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: MoboPadding.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    expense.isInitialLoading
                        ? CardLoading(
                            height: 100,
                            borderRadius: BorderRadius.circular(10),
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                MoboRadius.card,
                              ),
                              color: MoboColor.redColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                                top: 28,
                                bottom: 28,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${userProvider.getGreeting()} ${profileProvider.userData!['name']?.toString() ?? 'Unknown User'}!!!",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                          ),
                                          Text(
                                            "Manage Your Expense Operation Efficiently",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  profileProvider.userAvatar == null ||
                                          profileProvider.userAvatar!.isEmpty
                                      ? CircleAvatar(
                                          radius: 34,
                                          backgroundColor: isDark
                                              ? Colors.grey[700]
                                              : Colors.grey[300],
                                          child: HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedUserCircle,
                                            size: 30,
                                            color: isDark
                                                ? Colors.grey[500]
                                                : Colors.grey[600],
                                          ),
                                        )
                                      : ClipOval(
                                          child: Image.memory(
                                            profileProvider.userAvatar!,
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor: isDark
                                                        ? Colors.grey[700]
                                                        : Colors.grey[300],
                                                    child: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedUserCircle,
                                                      size: 30,
                                                      color: isDark
                                                          ? Colors.grey[500]
                                                          : Colors.grey[600],
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),

                    SizedBox(height: 20),

                    userProvider.isLoading
                        ? Column(
                            children: [
                              SizedBox(
                                height: 160,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index) => CardLoading(
                                    width: 250,
                                    height: 150,
                                    margin: EdgeInsets.only(right: 10),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing: 20,
                                      childAspectRatio: 1.2,
                                    ),
                                itemCount: 4,
                                itemBuilder: (context, index) => CardLoading(
                                  height: 100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          )
                        : userProvider.user == null
                        ? Center(
                            child: Column(
                              children: [
                                SizedBox(height: 200),
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedLicenseNo,
                                  size: 50,
                                ),
                                SizedBox(height: 40),
                                Text("Employee  not founded"),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Expense Analytics",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                              ),
                              SizedBox(height: 20),

                              userProvider.isLoading || expense.isLoading
                                  ? userProvider.isAdmin
                                        ? SizedBox(
                                            height: 160,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 5,
                                              itemBuilder: (context, index) =>
                                                  CardLoading(
                                                    width: 250,
                                                    height: 150,
                                                    margin: EdgeInsets.only(
                                                      right: 10,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                  ),
                                            ),
                                          )
                                        : GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  mainAxisSpacing: 20,
                                                  crossAxisSpacing: 20,
                                                  childAspectRatio: 1.2,
                                                ),
                                            itemCount: 4,
                                            itemBuilder: (context, index) =>
                                                CardLoading(
                                                  height: 100,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                          )
                                  : userProvider.isAdmin == false
                                  ? GridView(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 16,
                                            crossAxisSpacing: 16,
                                            childAspectRatio: 1.1,
                                          ),
                                      children: [
                                        businessCardWidget(
                                          context: context,
                                          title: "Expense",
                                          subtitle: "Total  Expense",
                                          amount: expense.totalExpenses
                                              .toStringAsFixed(2),
                                          icon: HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedInvoice02,
                                            size: 20,
                                            color: Colors.green.shade800,
                                          ),
                                          bgColor: Colors.green.shade100,
                                        ),
                                        businessCardWidget(
                                          context: context,
                                          title: "To Submit",
                                          subtitle: "Drafted Expense",
                                          amount: expense.totalAmountToSubmit
                                              .toStringAsFixed(2),
                                          icon: HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedLicenseDraft,
                                            size: 20,
                                            color: Colors.blue.shade800,
                                          ),
                                          bgColor: Colors.blue.shade100,
                                        ),
                                        businessCardWidget(
                                          context: context,
                                          title: "Waiting Reimbursement",
                                          subtitle: "Approved Expense",
                                          amount: expense.waitingReimbursement
                                              .toStringAsFixed(2),
                                          icon: HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedLoading03,
                                            size: 20,
                                            color: Colors.green.shade800,
                                          ),
                                          bgColor: Colors.green.shade100,
                                        ),

                                        businessCardWidget(
                                          context: context,
                                          title: "Waiting Approval",
                                          subtitle: 'Submitted Expense',
                                          amount: expense.totalApproved
                                              .toString(),
                                          icon: HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedLoading01,
                                            size: 20,
                                            color: Colors.yellow.shade800,
                                          ),
                                          bgColor: Colors.yellow.shade100,
                                        ),
                                        businessCardWidget(
                                          context: context,
                                          title: "Approved",
                                          subtitle: 'Total No. Approved',
                                          amount: expense.totalApprovedMy
                                              .toString(),
                                          icon: HugeIcon(
                                            icon: HugeIcons.strokeRoundedTick02,
                                            size: 20,
                                            color: Colors.green.shade800,
                                          ),
                                          bgColor: Colors.green.shade100,
                                        ),
                                        businessCardWidget(
                                          context: context,
                                          title: "Rejected",
                                          subtitle: 'Total No. Rejected',
                                          amount: expense.totalNoRefused
                                              .toString(),
                                          icon: HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedMultiplicationSign,
                                            size: 20,
                                            color: Colors.red.shade800,
                                          ),
                                          bgColor: Colors.red.shade100,
                                        ),
                                        businessCardWidget(
                                          context: context,
                                          title: "Submitted",
                                          subtitle: 'Total No. Submitted',
                                          amount: expense.totalNoSubmitted
                                              .toString(),
                                          icon: HugeIcon(
                                            icon:
                                                HugeIcons.strokeRoundedUpload04,
                                            size: 20,
                                            color: Colors.blue.shade800,
                                          ),
                                          bgColor: Colors.blue.shade100,
                                        ),
                                        businessCardWidget(
                                          context: context,
                                          title: "Paid",
                                          subtitle: 'Total No. Paid',
                                          amount: expense.totalNoPaid
                                              .toString(),
                                          icon: HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedNotebook02,
                                            size: 20,
                                            color: Colors.blue.shade800,
                                          ),
                                          bgColor: Colors.blue.shade100,
                                        ),
                                      ],
                                    )
                                  : SizedBox(
                                      height: 165,

                                      child: ListView(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          analyticCardWidget(
                                            title: "Expenses",
                                            amount: expense.totalExpenses
                                                .toStringAsFixed(2),
                                            dollar: true,
                                            color: Colors.green,
                                            sub: "Total Expense",
                                          ),
                                          analyticCardWidget(
                                            title: "To Submit",
                                            amount: expense.totalAmountToSubmit
                                                .toStringAsFixed(2),
                                            dollar: true,
                                            color: Colors.blue,
                                            sub: "Drafted Expense",
                                          ),
                                          analyticCardWidget(
                                            title: "Waiting Reimbursement",
                                            amount: expense.waitingReimbursement
                                                .toStringAsFixed(2),
                                            dollar: true,
                                            color: Colors.cyan,
                                            sub: "Approved Expense",
                                          ),
                                          analyticCardWidget(
                                            title: "Waiting Approval",
                                            amount: expense.totalAmountWaiting
                                                .toStringAsFixed(2),
                                            dollar: true,
                                            color: Colors.orangeAccent,
                                            sub: "Submitted Expense",
                                          ),

                                          analyticCardWidget(
                                            title: "Approved",
                                            amount: expense.totalApprovedMy
                                                .toString(),
                                            dollar: false,
                                            color: Colors.green,
                                            sub: "Total No. Approved",
                                          ),

                                          analyticCardWidget(
                                            title: "Paid",
                                            amount: expense.totalNoPaid
                                                .toString(),
                                            dollar: false,
                                            color: Colors.green,
                                            sub: "Total No. Paid",
                                          ),
                                          analyticCardWidget(
                                            title: "Posted",
                                            amount: expense.totalPosted
                                                .toString(),
                                            dollar: false,
                                            color: Colors.green,
                                            sub: "Total No. Posted",
                                          ),
                                          analyticCardWidget(
                                            title: "Submitted",
                                            amount: expense.totalNoSubmitted
                                                .toString(),
                                            dollar: false,
                                            color: Colors.orangeAccent,
                                            sub: "Total No. submitted",
                                          ),
                                          analyticCardWidget(
                                            title: "Rejected",
                                            amount: expense.totalNoRefused
                                                .toString(),
                                            dollar: false,
                                            color: Colors.red,
                                            sub: "Total No. Rejected",
                                          ),
                                        ],
                                      ),
                                    ),
                              SizedBox(height: 15),
                              expense.companyExpense.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Business Overview",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                              ),
                                        ),
                                        SizedBox(height: 20),
                                        expense.isLoading
                                            ? GridView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      mainAxisSpacing: 20,
                                                      crossAxisSpacing: 20,
                                                      childAspectRatio: 1.2,
                                                    ),
                                                itemCount: 4,
                                                itemBuilder: (context, index) =>
                                                    CardLoading(
                                                      height: 100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                              )
                                            : GridView(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      mainAxisSpacing: 16,
                                                      crossAxisSpacing: 16,
                                                      childAspectRatio: 1.1,
                                                    ),
                                                children: [
                                                  businessCardWidget(
                                                    context: context,
                                                    title: "Expense",
                                                    subtitle:
                                                        "Total Company Expense",
                                                    amount: expense
                                                        .totalCompanyExpense
                                                        .toStringAsFixed(2),
                                                    icon: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedOffice,
                                                      size: 20,
                                                      color: Colors.green,
                                                    ),
                                                    bgColor: Colors
                                                        .lightGreen
                                                        .shade100,
                                                  ),
                                                  businessCardWidget(
                                                    context: context,
                                                    title: "Rejected",
                                                    subtitle:
                                                        "Total No.Rejected By Company",
                                                    amount: expense
                                                        .totalCompanyRefused
                                                        .toString(),
                                                    icon: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedCancelCircle,
                                                      size: 20,
                                                      color: Colors.red,
                                                    ),
                                                    bgColor:
                                                        Colors.red.shade100,
                                                  ),
                                                  businessCardWidget(
                                                    context: context,
                                                    title: "Pending",
                                                    subtitle:
                                                        "Total No. pending Approvals",
                                                    amount: expense
                                                        .pendingApprovalNo
                                                        .toString(),
                                                    icon: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedLoading01,
                                                      size: 20,
                                                      color: Colors.blue,
                                                    ),
                                                    bgColor:
                                                        Colors.blue.shade100,
                                                  ),

                                                  businessCardWidget(
                                                    context: context,
                                                    title: "Approved",
                                                    subtitle:
                                                        'Total No. Approved',
                                                    amount: expense
                                                        .totalApproved
                                                        .toString(),
                                                    icon: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedTick02,
                                                      size: 20,
                                                      color: Colors.green,
                                                    ),
                                                    bgColor:
                                                        Colors.green.shade100,
                                                  ),
                                                ],
                                              ),

                                        SizedBox(height: 20),
                                        Text(
                                          "Analytics & Insights",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                              ),
                                        ),
                                        SizedBox(height: 20),

                                        barChartCard(
                                          expense.departmentExpense,
                                          context,
                                        ),
                                        SizedBox(height: 15),
                                      ],
                                    )
                                  : userProvider.isAdmin
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Business Overview",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                              ),
                                        ),
                                        SizedBox(height: 20),
                                        expense.isLoading
                                            ? GridView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      mainAxisSpacing: 20,
                                                      crossAxisSpacing: 20,
                                                      childAspectRatio: 1.2,
                                                    ),
                                                itemCount: 4,
                                                itemBuilder: (context, index) =>
                                                    CardLoading(
                                                      height: 100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                              )
                                            : GridView(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      mainAxisSpacing: 16,
                                                      crossAxisSpacing: 16,
                                                      childAspectRatio: 1.1,
                                                    ),
                                                children: [
                                                  businessCardWidget(
                                                    context: context,
                                                    title: "Expense",
                                                    subtitle:
                                                        "Total Company Expense",
                                                    amount: expense
                                                        .totalCompanyExpense
                                                        .toStringAsFixed(2),
                                                    icon: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedOffice,
                                                      size: 20,
                                                      color: Colors.green,
                                                    ),
                                                    bgColor: Colors
                                                        .lightGreen
                                                        .shade100,
                                                  ),
                                                  businessCardWidget(
                                                    context: context,
                                                    title: "Rejected",
                                                    subtitle:
                                                        "Total No.Rejected By Company",
                                                    amount: expense
                                                        .totalCompanyRefused
                                                        .toString(),
                                                    icon: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedCancelCircle,
                                                      size: 20,
                                                      color: Colors.red,
                                                    ),
                                                    bgColor:
                                                        Colors.red.shade100,
                                                  ),
                                                  businessCardWidget(
                                                    context: context,
                                                    title: "Pending",
                                                    subtitle:
                                                        "Total No. pending Approvals",
                                                    amount: expense
                                                        .pendingApprovalNo
                                                        .toString(),
                                                    icon: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedLoading01,
                                                      size: 20,
                                                      color: Colors.blue,
                                                    ),
                                                    bgColor:
                                                        Colors.blue.shade100,
                                                  ),

                                                  businessCardWidget(
                                                    context: context,
                                                    title: "Approved",
                                                    subtitle:
                                                        'Total No. Approved',
                                                    amount: expense
                                                        .totalApproved
                                                        .toString(),
                                                    icon: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedTick02,
                                                      size: 20,
                                                      color: Colors.green,
                                                    ),
                                                    bgColor:
                                                        Colors.green.shade100,
                                                  ),
                                                ],
                                              ),

                                        SizedBox(height: 20),
                                        Text(
                                          "Analytics & Insights",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                              ),
                                        ),
                                        SizedBox(height: 20),

                                        barChartCard(
                                          expense.departmentExpense,
                                          context,
                                        ),
                                        SizedBox(height: 15),
                                      ],
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(height: 15),
                              SizedBox(height: 15),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
