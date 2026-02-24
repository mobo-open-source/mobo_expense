import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:mobo_expenses/features/home/category/widget/category_card.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/pagination/pagination_controller.dart';
import '../widget/floating_category.dart';
import 'category_details.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Future<void> _initialLoad() async {
    try {
      if (context.read<CommonProvider>().categoryList.isEmpty) {
        await context.read<CommonProvider>().getAllCategory(reset: true);
        await context.read<CommonProvider>().getFullTaxWithoutCompany();
      }
    } catch (e, st) {}
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<CommonProvider>();

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: floatingActionButtonAddingCategory(context),

      body: RefreshIndicator(
        onRefresh: () async {
          await provider.getAllCategory(reset: true);
          await context.read<CommonProvider>().getFullTaxWithoutCompany();
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Expense Category",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
                  child: PaginationControls(
                    canGoToPreviousPage: provider.canGoPrevious,
                    canGoToNextPage: provider.canGoNext,
                    onPreviousPage: provider.previousPage,
                    onNextPage: provider.nextPage,
                    paginationText: provider.paginationText,
                    isDark: isDark,
                    theme: Theme.of(context),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 6),
                child: _buildBody(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Decide UI
  Widget _buildBody(CommonProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingGrid();
    }

    if (provider.categoryList.isEmpty) {
      return const Center(
        child: Text('No categories found', style: TextStyle(fontSize: 16)),
      );
    }

    return _buildCategoryGrid(provider);
  }

  /// Loading skeleton
  Widget _buildLoadingGrid() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, __) => CardLoading(
        height: double.infinity,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Category grid
  Widget _buildCategoryGrid(CommonProvider provider) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: provider.categoryList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index >= provider.categoryList.length) {
          return const SizedBox.shrink();
        }

        final category = provider.categoryList[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          key: Key("push_btn"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryDetails(categoryId: category.id),
              ),
            );
          },
          child: CategoryCardWidget(
            name: category.name,
            defaultCode: category.defaultCode ?? '',
            bytes: category.imageBytes,
          ),
        );
      },
    );
  }
}
