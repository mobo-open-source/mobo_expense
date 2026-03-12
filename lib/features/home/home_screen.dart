import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/features/home/report/report_screen.dart';
import 'package:mobo_expenses/provider/bottom_nav_provider.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/constants.dart';
import '../../core/routing/page_transition.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/odoo_session_manager.dart';
import '../../core/widgets/floating_add_expense.dart';
import '../../core/widgets/floating_button_widget.dart';
import '../../provider/user_provider.dart';
import '../../shared/widgets/snackbars/custom_snackbar.dart';
import '../company/providers/company_provider.dart';
import '../company/widgets/company_selector_widget.dart';
import '../profile/pages/profile_screen.dart';
import '../profile/providers/profile_provider.dart';
import 'approval_screen.dart';
import 'category/categories_screen.dart';
import 'dashboard_screen.dart';
import 'expense/expenses_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isTest;

  const HomeScreen({super.key, this.isTest = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();



    if (widget.isTest == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<CompanyProvider>().initialize();
          context.read<ProfileProvider>().fetchUserProfile();

        }
      });


      OdooSessionManager.getCurrentSession().then((session) {
        ConnectivityService.instance.setCurrentServerUrl(session?.serverUrl);
        if (mounted) {
          setState(() {
            _isLoadingSession = false;
          });
        }
      });
    }
  }



  bool _isLoadingSession = true;

  Future<void> _validateSession() async {
    try {
      final isValid = await OdooSessionManager.isSessionValid();
      if (!isValid && mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/server_setup', (route) => false);
      } else if (mounted) {
        final session = await OdooSessionManager.getCurrentSession();
      }
    } catch (e) {}
  }

  static final List<Widget> _screens = <Widget>[
    DashboardScreen(),
    ExpensesScreen(),
    ApprovalScreen(),
    CategoriesScreen(),
    ReportScreen(),
  ];

  static final List<Widget> _screensUser = <Widget>[
    DashboardScreen(),
    ExpensesScreen(),
    ReportScreen(),
  ];

  final List<String> _title = [
    'Dashboard',
    'Expense',
    'Approval',
    'Category',
    'Report',
  ];
  final List<String> _titleUser = ['Dashboard', 'Expense', 'Report'];

  @override
  void dispose() {
    if (!widget.isTest) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.isTest) return;

    if (state == AppLifecycleState.resumed) {
      _validateSession();

      if (mounted) {
        context.read<ProfileProvider>().fetchUserProfile(forceRefresh: true);
      }
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bottom = context.watch<BottomNavProvider>();

    final List<BottomNavigationBarItem> bottomNavAdmin = [
      BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDashboardSquare02,
          size: 23,
        ),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedInvoice03, size: 23),
        label: 'Expense',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedValidationApproval,
          size: 23,
        ),
        label: 'Approval',
      ),

      BottomNavigationBarItem(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedPackage, size: 23),
        label: 'Category',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedAnalytics01, size: 23),
        label: 'Report',
      ),
    ];
    final List<BottomNavigationBarItem> bottomNavUser = [
      BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDashboardSquare02,
          size: 23,
        ),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedInvoice03, size: 23),
        label: 'Expense',
      ),

      BottomNavigationBarItem(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedAnalytics01, size: 23),
        label: 'Report',
      ),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,

        title: userProvider.isAdmin
            ? Text(
                _title[bottom.index],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              )
            : Text(
                _titleUser[bottom.index],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

        actions: _buildProfileActions(context),
        actionsPadding: EdgeInsets.symmetric(horizontal: 5),
      ),
      body: Consumer<BottomNavProvider>(
        builder: (context, bottomNavProvider, child) {
          return userProvider.isAdmin
              ? _screens.elementAt(bottomNavProvider.index)
              : _screensUser.elementAt(bottomNavProvider.index);
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: widget.isTest
          ? const SizedBox.shrink()
          : gettingFloatingAction(bottom.index, isAdmin: userProvider.isAdmin),

      bottomNavigationBar: Consumer<BottomNavProvider>(
        builder: (context, bottomProvider, child) {
          return SnakeNavigationBar.color(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            elevation: 2,

            unselectedItemColor: isDark ? Colors.white : Colors.grey[800],
            selectedItemColor: isDark ? Colors.white : MoboColor.redColor,
            snakeViewColor: MoboColor.redColor,
            showSelectedLabels: true,
            currentIndex: bottomProvider.index,
            showUnselectedLabels: true,
            onTap: (index) => bottomProvider.changeIndex(index),
            snakeShape: SnakeShape.indicator,
            selectedLabelStyle: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),

            items: userProvider.isAdmin ? bottomNavAdmin : bottomNavUser,
          );
        },
      ),
    );
  }

  List<Widget> _buildProfileActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      /// Company selector
      CompanySelectorWidget(
        onCompanyChanged: () async {
          if (!mounted) return;
          final userProvider = context.read<UserProvider>();
          final expense = context.read<ExpenseProvider>();
          final commonProvider = context.read<CommonProvider>();
          final bottom = context.read<BottomNavProvider>();

          try {
            expense.reset();
            commonProvider.reset();
            expense.changeLoading(true);

            expense.initialExpense();
            await expense.expenseInitial();

            await expense.getOdooVersion();
            expense.changeFkTogle(0);

            await expense.getExpenses(context, userProvider.isAdmin);
            expense.initialExpense();

            await expense.loadExpenses(reset: true);

            await expense.loadExpensesApproval(
              isApproved: true,
              admin: true,
              reset: true,
            );

            await commonProvider.getFullTax();

            await expense.gettingPurchaseJournal();
            await commonProvider.getAllCategory(reset: true);

            await commonProvider.getMonthlyBasisReport();
            await commonProvider.getPaidExpenseReport();
            await commonProvider.getCategoryReport();
            final session = await OdooSessionManager.getCurrentSession();

            final version = session!.odooSession.serverVersion;
            if (userProvider.isAdmin) {
              await commonProvider.getCompanyMonthlyExpense();
              await commonProvider.getCompanyWiseCategories();
              if (version == '19')
                await commonProvider.getCompanyWiseDepartment();
              await commonProvider.getCompanyEmployees();
            }

            /// Get the newly selected company name for better feedback
            final provider = context.read<CompanyProvider>();
            final companyName =
                provider.selectedCompany?['name']?.toString() ?? 'company';

            /// Refresh profile data
            await context.read<ProfileProvider>().fetchUserProfile(
              forceRefresh: true,
            );

            /// Show success message
            CustomSnackbar.showSuccess(context, 'Switched to $companyName');
          } catch (e) {
          } finally {
            expense.changeLoading(false);
          }
        },
      ),
      Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final userAvatar = profileProvider.userAvatar;
          final isLoading = profileProvider.isLoading && userAvatar == null;

          return IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('avatar_loading'),
                      width: 32,
                      height: 32,
                      child: Shimmer.fromColors(
                        baseColor: isDark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                        highlightColor: isDark
                            ? Colors.grey[600]!
                            : Colors.grey[200]!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    )
                  : (userAvatar != null
                        ? ClipOval(
                            child: Image.memory(
                              profileProvider.userAvatar!,
                              height: 30,
                              width: 30,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return CircleAvatar(
                                  radius: 15,
                                  backgroundColor: isDark
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedUserCircle,
                                    size: 30,
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          )
                        : CircleAvatar(
                            key: const ValueKey('avatar_placeholder'),
                            radius: 16,
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUserCircle,
                              color: isDark ? Colors.white70 : Colors.black54,
                              size: 18,
                            ),
                          )),
            ),
            onPressed: () {
              Navigator.push(
                context,
                dynamicRoute(context, const ProfileScreen()),
              ).then((_) {
                /// Refresh profile data after returning from profile screen
                if (mounted) {
                  context.read<ProfileProvider>().fetchUserProfile(
                    forceRefresh: true,
                  );
                }
              });
            },
          );
        },
      ),
    ];
  }

  Widget gettingFloatingAction(int index, {bool isAdmin = false}) {
    switch (index) {
      case 0:
        return floatingActionButtonWidget(context, isAdmin: isAdmin);
      case 1:
        return floatingActionButtonAddingExpense(context);

      default:
        return SizedBox();
    }
  }
}
