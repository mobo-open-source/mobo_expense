import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:mobo_expenses/features/home/expense/widget/active_filter_badge.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/common_result_pannel.dart';
import '../../../core/widgets/employee_card.dart';
import '../../../core/widgets/expense_card.dart';
import '../../../core/widgets/pagination/pagination_controller.dart';
import '../../../core/widgets/textform_search_listing.dart';
import '../../../model/employee.dart';
import '../../review/services/review_service.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    /// TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialLoading();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ReviewService().checkAndShowRating(context);
    });
  }

  FocusNode searchNode = FocusNode();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final userProvider = context.read<UserProvider>();
    final commonProvider = context.watch<CommonProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
            child: Consumer<ExpenseProvider>(
              builder: (context, value, child) {
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    border: Border.all(
                      width: 1,
                      color: searchNode.hasFocus
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),

                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextField(
                    onChanged: (value) async {
                      if (commonProvider.domain.isEmpty) {
                        await expenseProvider.gettingSearchedExpense(
                          value,
                          admin: expenseProvider.fkTogle == 0 ? false : true,
                          reset: true,
                        );
                      } else {
                        await expenseProvider.gettingSearchedExpense(
                          value,
                          filter: commonProvider.domain,
                          admin: expenseProvider.fkTogle == 0 ? false : true,
                          reset: true,
                        );
                      }
                    },
                    controller: searchController,
                    focusNode: searchNode,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      focusedBorder: InputBorder.none,
                      hintText: 'Search expense...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white : Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),

                      border: InputBorder.none,
                      prefixIconConstraints: const BoxConstraints(minWidth: 45),

                      prefixIcon: InkWell(
                        key: const Key('filter_button'),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedFilterHorizontal,
                          color: isDark ? Colors.white : Colors.black,
                          size: 18,
                        ),
                        onTap: () async {
                          commonProvider.changing(true);
                          if (commonProvider.domain.isEmpty) {
                            try {
                              await context
                                  .read<CommonProvider>()
                                  .currentExpenseEmployee();
                            } catch (e) {}
                          }

                          showModalBottomSheet(
                            backgroundColor: isDark
                                ? Colors.grey[900]
                                : Colors.white,
                            isScrollControlled: true,
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width,

                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.75,
                            ),

                            context: context,

                            builder: (BuildContext ctx) {
                              return Consumer<CommonProvider>(
                                builder: (context, provider, child) {
                                  return SafeArea(
                                    child: Padding(
                                      padding: EdgeInsets.all(30),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 20),
                                                  Text(
                                                    "Filter",
                                                    key: const Key(
                                                      'filter_bottom_sheet_title',
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  Text(
                                                    "Employee",
                                                    style: TextStyle(
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),

                                                  provider.isLoading
                                                      ? CardLoading(height: 50)
                                                      : Column(
                                                          children: [
                                                            provider.selctedEmployee !=
                                                                    null
                                                                ? employeeCardWidget(
                                                                    employee:
                                                                        provider
                                                                            .selctedEmployee!,
                                                                    istrailing:
                                                                        userProvider
                                                                            .isAdmin,
                                                                    trailingFunction: () {
                                                                      provider
                                                                          .gettingTypedList(
                                                                            "",
                                                                          );
                                                                      provider
                                                                          .removingEmployee();
                                                                    },
                                                                  )
                                                                : textFormSearchListingWidget(
                                                                    error:
                                                                        false,
                                                                    isDark:
                                                                        isDark,
                                                                    trailingFunction: () {
                                                                      provider.changing(
                                                                        provider
                                                                            .isShow,
                                                                      );
                                                                    },
                                                                    readOnly:
                                                                        false,
                                                                    isLeading:
                                                                        true,
                                                                    isSearching:
                                                                        true,
                                                                    controller:
                                                                        provider
                                                                            .employeeController,
                                                                    onSearchChanged:
                                                                        (
                                                                          value,
                                                                        ) {
                                                                          provider.gettingTypedList(
                                                                            value,
                                                                          );
                                                                        },
                                                                    icon: HugeIcon(
                                                                      icon: HugeIcons
                                                                          .strokeRoundedUserSearch02,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    hintText:
                                                                        "Type to search  employees",
                                                                    trailingIcon:
                                                                        !provider
                                                                            .isShow
                                                                        ? HugeIcon(
                                                                            icon:
                                                                                HugeIcons.strokeRoundedArrowDown01,
                                                                            color:
                                                                                Colors.black,
                                                                          )
                                                                        : HugeIcon(
                                                                            icon:
                                                                                HugeIcons.strokeRoundedArrowUp01,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                  ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),

                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            CommonResultPanel<
                                                              Employee
                                                            >(
                                                              visible: provider
                                                                  .isShow,
                                                              isLoading: provider
                                                                  .isLoading,
                                                              items: provider
                                                                  .employeeList,
                                                              height: 250,
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 2,
                                                                    right: 2,
                                                                    top: 2,
                                                                  ),
                                                              itemBuilder:
                                                                  (
                                                                    context,
                                                                    employee,
                                                                  ) => employeeCardWidget(
                                                                    employee:
                                                                        employee,
                                                                    istrailing:
                                                                        false,
                                                                  ),
                                                              onTap: (employee) {
                                                                provider
                                                                    .addEmployee(
                                                                      employee,
                                                                    );
                                                              },
                                                            ),
                                                          ],
                                                        ),

                                                  commonProvider
                                                              .selectedCategoryList
                                                              .isNotEmpty ||
                                                          commonProvider
                                                              .fromDateController
                                                              .text
                                                              .isNotEmpty
                                                      ? Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Active Filter",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,

                                                                color: MoboColor
                                                                    .redColor,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),

                                                            Wrap(
                                                              spacing: 10,
                                                              runSpacing: 10,
                                                              children: commonProvider.selectedCategoryList.map((
                                                                single,
                                                              ) {
                                                                final isSelected =
                                                                    commonProvider
                                                                        .selectedCategoryList
                                                                        .contains(
                                                                          single,
                                                                        );

                                                                return GestureDetector(
                                                                  onTap: () =>
                                                                      commonProvider
                                                                          .toggleSelection(
                                                                            single,
                                                                          ),
                                                                  child: AnimatedContainer(
                                                                    duration: const Duration(
                                                                      milliseconds:
                                                                          180,
                                                                    ),
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          isDark
                                                                          ? Colors.red.shade50
                                                                          : Colors.red.shade50,

                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                      border: Border.all(
                                                                        color:
                                                                            isSelected
                                                                            ? Colors.grey.shade300
                                                                            : isDark
                                                                            ? Colors.grey
                                                                            : Colors.grey.shade300,
                                                                        width:
                                                                            isSelected
                                                                            ? 1
                                                                            : 1,
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                          single
                                                                              .name,
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color:
                                                                                isSelected
                                                                                ? Colors.black
                                                                                : Colors.black87,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        isSelected
                                                                            ? HugeIcon(
                                                                                icon: HugeIcons.strokeRoundedMultiplicationSign,
                                                                                color: Colors.black,
                                                                                size: 15,
                                                                              )
                                                                            : SizedBox.shrink(),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                            SizedBox(height: 5),

                                                            commonProvider
                                                                    .fromDateController
                                                                    .text
                                                                    .trim()
                                                                    .isNotEmpty
                                                                ? GestureDetector(
                                                                    onTap: () {
                                                                      commonProvider.changeDate(
                                                                        commonProvider
                                                                            .fromDateController,
                                                                        "",
                                                                      );
                                                                    },
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .red
                                                                            .shade50,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                        border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade300,
                                                                        ),
                                                                      ),
                                                                      child: Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              8.0,
                                                                            ),
                                                                        child: Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Text(
                                                                              "Date:${commonProvider.fromDateController.text}",
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),

                                                                            HugeIcon(
                                                                              icon: HugeIcons.strokeRoundedMultiplicationSign,
                                                                              color: Colors.black,
                                                                              size: 15,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : SizedBox.shrink(),
                                                          ],
                                                        )
                                                      : SizedBox.shrink(),

                                                  SizedBox(height: 10),
                                                  Text(
                                                    "Category",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),

                                                  SizedBox(height: 20),

                                                  Wrap(
                                                    spacing: 10,
                                                    runSpacing: 10,
                                                    children: commonProvider.categoryList.map((
                                                      single,
                                                    ) {
                                                      final isSelected =
                                                          commonProvider
                                                              .selectedCategoryList
                                                              .contains(single);

                                                      return GestureDetector(
                                                        onTap: () =>
                                                            commonProvider
                                                                .toggleSelection(
                                                                  single,
                                                                ),
                                                        child: AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    180,
                                                              ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 15,
                                                                vertical: 8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: isSelected
                                                                ? MoboColor
                                                                      .redColor
                                                                : isDark
                                                                ? Colors
                                                                      .red
                                                                      .shade50
                                                                : Colors
                                                                      .red
                                                                      .shade50,

                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            border: Border.all(
                                                              color: isSelected
                                                                  ? Colors.white
                                                                  : isDark
                                                                  ? Colors.grey
                                                                  : Colors
                                                                        .grey
                                                                        .shade300,
                                                              width: isSelected
                                                                  ? 1
                                                                  : 1,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              isSelected
                                                                  ? HugeIcon(
                                                                      icon: HugeIcons
                                                                          .strokeRoundedTick02,
                                                                      color: Colors
                                                                          .black,
                                                                      size: 15,
                                                                    )
                                                                  : SizedBox.shrink(),
                                                              isSelected
                                                                  ? SizedBox(
                                                                      width: 10,
                                                                    )
                                                                  : SizedBox.shrink(),

                                                              Text(
                                                                single.name,
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color:
                                                                      isSelected
                                                                      ? Colors
                                                                            .black
                                                                      : Colors
                                                                            .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),

                                                  SizedBox(height: 30),
                                                  Text(
                                                    "Date",
                                                    style: MoboText.h4
                                                        .copyWith(),
                                                  ),
                                                  SizedBox(height: 20),
                                                  textFormSearchListingWidget(
                                                    isBorder: true,

                                                    error: false,
                                                    isDark: isDark,
                                                    controller: commonProvider
                                                        .fromDateController,
                                                    readOnly: true,
                                                    context: context,
                                                    date: true,
                                                    icon: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedCalendar04,
                                                      size: 20,
                                                    ),
                                                    hintText: "Date",
                                                    isLeading:
                                                        commonProvider
                                                            .fromDateController
                                                            .text
                                                            .isNotEmpty
                                                        ? true
                                                        : false,
                                                    trailingIcon: Icon(
                                                      Icons.delete,
                                                    ),
                                                    trailingFunction: () {
                                                      commonProvider.changeDate(
                                                        commonProvider
                                                            .fromDateController,
                                                        "",
                                                      );
                                                    },

                                                    isSearching: false,
                                                  ),

                                                  SizedBox(height: 20),
                                                ],
                                              ),
                                            ),
                                          ),

                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                OutlinedButton(
                                                  key: Key("filter_cancel"),
                                                  style: OutlinedButton.styleFrom(
                                                    minimumSize: Size(120, 40),

                                                    side: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 0.5,
                                                    ),

                                                    backgroundColor:
                                                        Colors.white,

                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    commonProvider
                                                        .clearFilter();
                                                    commonProvider
                                                        .currentExpenseEmployee();
                                                    expenseProvider
                                                        .changeFkTogle(0);

                                                    Navigator.pop(
                                                      context,
                                                      false,
                                                    );

                                                    await expenseProvider
                                                        .loadExpenses(
                                                          reset: true,
                                                        );
                                                  },
                                                  child: Text(
                                                    "Clear all",
                                                    style: MoboText.normal
                                                        .copyWith(
                                                          color: Colors.black,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(width: 20),

                                                Expanded(
                                                  child: ElevatedButton(
                                                    key: Key("filter_apply"),
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: Size(
                                                        120,
                                                        40,
                                                      ),

                                                      backgroundColor:
                                                          MoboColor.redColor,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      setState(() {
                                                        searchController.text =
                                                            '';
                                                      });
                                                      expenseProvider
                                                          .changeFkTogle(0);
                                                      Navigator.pop(context);

                                                      await commonProvider.getFilteredItems(
                                                        commonProvider
                                                            .selectedCategoryList,
                                                        commonProvider
                                                            .fromDateController
                                                            .text,
                                                        context,

                                                        id:
                                                            commonProvider
                                                                    .selctedEmployee ==
                                                                null
                                                            ? 0
                                                            : commonProvider
                                                                  .selctedEmployee!
                                                                  .id,
                                                      );
                                                    },
                                                    child: Text(
                                                      "Apply",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),

                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            userProvider.isAdmin
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ActiveFiltersBadge(
                        count: commonProvider.domain.length,
                        theme: Theme.of(context),
                      ),
                      Container(
                        width: 102,
                        height: 30,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(
                            MoboRadius.circle,
                          ),
                        ),
                        child: Row(
                          children: List.generate(2, (index) {
                            final isSelected = expenseProvider.fkTogle == index;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (expenseProvider.fkTogle == index) return;

                                  expenseProvider.changeFkTogle(index);
                                  commonProvider.clearFilter();
                                  getTotal(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      MoboRadius.circle,
                                    ),
                                  ),
                                  child: Text(
                                    index == 0 ? 'My' : 'All',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),

            SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                userProvider.isAdmin == false
                    ? ActiveFiltersBadge(
                        count: commonProvider.domain.length <= 1
                            ? 0
                            : commonProvider.domain.length - 1,
                        theme: Theme.of(context),
                      )
                    : SizedBox(),
                PaginationControls(
                  canGoToPreviousPage: expenseProvider.canGoPrevious,
                  canGoToNextPage: expenseProvider.canGoNext,
                  onPreviousPage: () => expenseProvider.previousPage(
                    isAdmin: expenseProvider.fkTogle == 0 ? false : true,
                  ),
                  onNextPage: () => expenseProvider.nextPage(
                    admin: expenseProvider.fkTogle == 0 ? false : true,
                  ),
                  paginationText: expenseProvider.paginationText,
                  isDark: isDark,
                  theme: Theme.of(context),
                ),
              ],
            ),
            SizedBox(height: 6),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  commonProvider.clearFilter();
                  if (expenseProvider.fkTogle == 0) {
                    if (searchController.text.trim().isEmpty) {
                      await expenseProvider.loadExpenses();
                    } else {
                      await expenseProvider.gettingSearchedExpense(
                        searchController.text.trim(),
                      );
                    }
                  } else {
                    if (searchController.text.trim().isEmpty) {
                      await expenseProvider.loadExpenses(admin: true);
                    } else {
                      await expenseProvider.gettingSearchedExpense(
                        searchController.text.trim(),
                        admin: true,
                      );
                    }
                  }
                },
                child: expenseProvider.isLoading
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return CardLoading(
                            height: 150,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            margin: EdgeInsets.only(bottom: 10),
                          );
                        },
                      )
                    : expenseProvider.expenses.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 50),
                                  SizedBox(
                                    height: 180,
                                    child: Lottie.asset(
                                      'assets/lotties/empty ghost.json',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text("No Expense Found", style: MoboText.h2),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Text(
                                      "No expense found. Try adjusting your filter settings.",
                                      style: MoboText.h4,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: Size(120, 40),

                                          side: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 0.5,
                                          ),

                                          backgroundColor: Colors.white,

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          commonProvider.clearFilter();
                                          commonProvider
                                              .currentExpenseEmployee();
                                          setState(() {
                                            searchController.text = '';
                                          });

                                          if (expenseProvider.fkTogle == 0) {
                                            if (searchController.text
                                                .trim()
                                                .isEmpty) {
                                              await expenseProvider
                                                  .loadExpenses();
                                            } else {
                                              await expenseProvider
                                                  .gettingSearchedExpense(
                                                    searchController.text
                                                        .trim(),
                                                  );
                                            }
                                          } else {
                                            if (searchController.text
                                                .trim()
                                                .isEmpty) {
                                              await expenseProvider
                                                  .loadExpenses(admin: true);
                                            } else {
                                              await expenseProvider
                                                  .gettingSearchedExpense(
                                                    searchController.text
                                                        .trim(),
                                                    admin: true,
                                                  );
                                            }
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedFilterRemove,
                                              size: 15,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              "Clear Filters",
                                              style: TextStyle(
                                                color: MoboColor.redColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 20),

                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(120, 40),

                                          backgroundColor: MoboColor.redColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (commonProvider.domain.isEmpty) {
                                            await expenseProvider
                                                .gettingSearchedExpense(
                                                  searchController.text.trim(),
                                                  admin:
                                                      expenseProvider.fkTogle ==
                                                          0
                                                      ? false
                                                      : true,
                                                  reset: true,
                                                );
                                          } else {
                                            await expenseProvider.loadExpenses(
                                              filter:
                                                  commonProvider.domain.isEmpty
                                                  ? const []
                                                  : commonProvider.domain,
                                              reset: true,
                                            );
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedRefresh,
                                              size: 13,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              "Retry",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: expenseProvider.loadedExpense.length,
                        itemBuilder: (context, index) {
                          final singleItems =
                              expenseProvider.loadedExpense[index];

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
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///initial loading method
  Future initialLoading() async {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final commonProvider = Provider.of<CommonProvider>(context, listen: false);

    try {
      if (expenseProvider.loadedExpense.isEmpty) {
        expenseProvider.changeLoading(true);
        await expenseProvider.getOdooVersion();

        commonProvider.clearFilter();

        await expenseProvider.loadExpenses(reset: true);
        await commonProvider.currentExpenseEmployee();
      }

      expenseProvider.changeFkTogle(expenseProvider.fkTogle);

      commonProvider.disposeInTax();
      await expenseProvider.getOdooVersion();

      await commonProvider.getFullTax();

      if (expenseProvider.loadedExpense.isEmpty) {
        getTotal(0);
      }
    } catch (e) {
    } finally {
      expenseProvider.changeLoading(false);
    }
  }

  ///get total

  Future getTotal(int index) async {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );

    if (index == 0) {
      await expenseProvider.loadExpenses(reset: true);

      return;
    } else {
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );
      expenseProvider.loadExpenses(admin: true, reset: true);
    }
  }
}
