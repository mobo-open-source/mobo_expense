import 'dart:typed_data';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/custom_card_h.dart';
import '../../../core/widgets/simple_card.dart';
import '../../../core/widgets/space_btw_widget.dart';
import 'edit/edit_screen.dart';

class CategoryDetails extends StatefulWidget {
  final int categoryId;

  const CategoryDetails({super.key, required this.categoryId});

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  bool isLoading = true;

  Future<void> initialLoading() async {
    try {
      final commonProvider = Provider.of<CommonProvider>(
        context,
        listen: false,
      );

      await commonProvider.getFullTaxWithoutCompany();

      await commonProvider.getCategoryDetails(widget.categoryId);
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initialLoading();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommonProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
        title: Text(
          "Category Details",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          provider.categoriesFullModel == null
              ? const SizedBox()
              : IconButton(
                  key: Key("editing_screen"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCategoryScreen(
                        category: provider.categoriesFullModel!,
                      ),
                    ),
                  ),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: MoboPadding.pagePadding,
        child: Consumer<CommonProvider>(
          builder: (context, commonProvider, _) {
            if (isLoading) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CardLoading(
                    height: 100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }

            final category = commonProvider.categoriesFullModel!;

            return Column(
              children: [
                ///  BASIC INFO CARD
                simpleCardWidget(
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : MoboColor.redColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.defaultCode,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Cost Price",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(category.standardPrice.toString()),
                            const SizedBox(height: 6),
                            const Text(
                              "Sale Price",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(category.listPrice.toString()),
                          ],
                        ),
                      ),

                      ///  IMAGE / FIRST LETTER
                      CategoryImageWidget(
                        imageBytes: category.imageBytes,
                        name: category.name,
                      ),
                    ],
                  ),
                ),

                ///  CATEGORY & TAX
                simpleCardWidget(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      spaceBetweenWidget(
                        "Category",
                        category.categName ?? "No Category",
                      ),

                      spaceBetweenWidget(
                        "Purchase Taxes",
                        category.supplierTaxes.isNotEmpty
                            ? category.supplierTaxes
                            : "No taxes",
                      ),
                    ],
                  ),
                ),

                ///  GUIDELINES
                customCardWithHeading(
                  "Guidelines",
                  category.description.trim().isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "Guidelines are not added.",
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        )
                      : Text(category.description),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CategoryImageWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final String name;

  const CategoryImageWidget({
    super.key,
    required this.imageBytes,
    required this.name,
  });

  bool get _hasValidImage => imageBytes != null && imageBytes!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey[800] : Colors.grey[300],
      ),
      child: _hasValidImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageBytes!,
                fit: BoxFit.cover,

                ///  THIS PREVENTS CRASH
                errorBuilder: (context, error, stackTrace) {
                  return _fallbackLetter(isDark, firstLetter);
                },
              ),
            )
          : _fallbackLetter(isDark, firstLetter),
    );
  }

  Widget _fallbackLetter(bool isDark, String firstLetter) {
    return Center(
      child: Text(
        firstLetter,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
