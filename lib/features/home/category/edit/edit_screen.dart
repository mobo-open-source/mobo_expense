import 'dart:convert';
import 'dart:typed_data';
import 'package:card_loading/card_loading.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_expenses/model/tax_model.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/utils/loading.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/widgets/custom_card_h.dart';
import '../../../../core/widgets/simple_card.dart';
import '../../../../core/widgets/submit_button.dart';
import '../../../../model/categories_full.dart';
import '../../../../shared/widgets/snackbars/custom_snackbar.dart';
import '../../home_screen.dart';

class EditCategoryScreen extends StatefulWidget {
  final CategoriesFullModel category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final costController = TextEditingController();
  final saleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final taxController = TextEditingController();

  Uint8List? selectedImage;
  int? selectedCategoryId;
  List<TaxModel> selectedTax = [];
  List<int> previousTaxIds = [];

  bool get hasCategory =>
      selectedCategoryId != null && categoryController.text.isNotEmpty;

  bool get hasTax => selectedTax != null && taxController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();

    final cat = widget.category;
    nameController.text = cat.name;
    codeController.text = cat.defaultCode;
    costController.text = cat.standardPrice.toString();
    saleController.text = cat.listPrice.toString();
    descriptionController.text = cat.description;

    selectedCategoryId = cat.categId;
    selectedImage = cat.imageBytes;

    if (cat.categId != null && cat.categName != null) {
      categoryController.text = cat.categName!;
    }

    if (cat.taxId != null && cat.supplierTaxes.isNotEmpty) {
      previousTaxIds = List<int>.from(cat.taxId!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommonProvider>().gettingProductCategory();
      context.read<CommonProvider>().getFullTax();

      final commonProvider = context.read<CommonProvider>();
      if (previousTaxIds.isNotEmpty &&
          commonProvider.totalTaxWithoutCompany.isNotEmpty) {
        setState(() {
          selectedTax = commonProvider.totalTaxWithoutCompany
              .where((tax) => previousTaxIds.contains(tax.id))
              .toList();

          taxController.text = selectedTax
              .map((e) => e.name ?? '')
              .where((n) => n.isNotEmpty)
              .join(', ');
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    costController.dispose();
    saleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    taxController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      selectedImage = await image.readAsBytes();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commonProvider = context.watch<CommonProvider>();

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
        elevation: 0,
        title: Text(
          "Edit Category",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: MoboPadding.pagePadding,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// CATEGORY INFO
                simpleCardWidget(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Category Information",
                        style: MoboText.h3.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text("Name"),
                      SizedBox(height: 5),

                      _textField(
                        controller: nameController,
                        label: "Category Name",
                        required: true,
                        isDark: isDark,
                      ),
                      Text("Internal Code"),
                      SizedBox(height: 5),

                      _textField(
                        controller: codeController,
                        label: "Eg:PDR,EXR..",
                        isDark: isDark,
                      ),

                      const SizedBox(height: 10),

                      Text("Parent Category"),
                      SizedBox(height: 5),

                      commonProvider.productCategoryLoading
                          ? const CardLoading(height: 60)
                          : hasCategory
                          ? _selectedWithDelete(
                              text: categoryController.text,
                              isDark: isDark,
                              onDelete: () {
                                setState(() {
                                  selectedCategoryId = null;
                                  categoryController.clear();
                                });
                              },
                            )
                          : DropdownButtonFormField2<Map<String, dynamic>>(
                              isExpanded: true,
                              hint: const Text("Select Parent Category"),
                              items: commonProvider.productCategory.map((cat) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: cat,
                                  child: Text(cat['display_name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  selectedCategoryId = value['id'];
                                  categoryController.text =
                                      value['display_name'] ?? '';
                                });
                              },
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDark
                                      ? Colors.grey[900]
                                      : Colors.white,
                                ),
                              ),
                              decoration: _dropdownDecoration(isDark),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// PRICING
                simpleCardWidget(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pricing",
                        style: MoboText.h3.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text("Cost Price"),
                      SizedBox(height: 5),

                      _textField(
                        controller: costController,
                        label: "Cost Price",
                        keyboardType: TextInputType.number,
                        isDark: isDark,
                      ),

                      Text("Sale Prices"),
                      SizedBox(height: 5),

                      _textField(
                        controller: saleController,
                        label: "Sale Price",
                        keyboardType: TextInputType.number,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 5),

                      Text("Sale Tax"),
                      SizedBox(height: 5),

                      if (selectedTax.isNotEmpty) ...[
                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedTax.map((tax) {
                            return Chip(
                              label: Text(tax.name ?? ''),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  selectedTax.remove(tax);

                                  ///update text field
                                  taxController.text = selectedTax
                                      .map((e) => e.name ?? '')
                                      .where((n) => n.isNotEmpty)
                                      .join(', ');
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 5),

                      commonProvider.gettingfulltaxloading
                          ? const CardLoading(height: 80)
                          : DropdownButtonFormField2<TaxModel>(
                              isExpanded: true,

                              hint: const Text("Select Tax"),

                              items: commonProvider.totalTaxWithoutCompany.map((
                                tax,
                              ) {
                                return DropdownMenuItem<TaxModel>(
                                  value: tax,
                                  enabled: false,

                                  /// important
                                  child: StatefulBuilder(
                                    builder: (context, menuSetState) {
                                      final isSelected = selectedTax.contains(
                                        tax,
                                      );

                                      return CheckboxListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(tax.name ?? ''),
                                        value: isSelected,

                                        onChanged: (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              if (!selectedTax.contains(tax)) {
                                                selectedTax.add(tax);
                                              }
                                            } else {
                                              selectedTax.remove(tax);
                                            }

                                            /// show selected names
                                            taxController.text = selectedTax
                                                .map((e) => e.name ?? '')
                                                .where((n) => n.isNotEmpty)
                                                .join(', ');
                                          });

                                          menuSetState(() {});
                                        },
                                      );
                                    },
                                  ),
                                );
                              }).toList(),

                              onChanged: (_) {},

                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDark
                                      ? Colors.grey[900]
                                      : Colors.white,
                                ),
                              ),

                              decoration: _dropdownDecoration(isDark),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// IMAGE
                customCardWithHeading(
                  "Other Information",
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Category Image(optional)"),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey[800]
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            image: selectedImage != null
                                ? DecorationImage(
                                    image: MemoryImage(selectedImage!),
                                    fit: BoxFit.fitHeight,
                                  )
                                : null,
                          ),
                          child: selectedImage == null
                              ? Center(
                                  child: Text(
                                    "Tap to add image",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (selectedImage != null)
                        TextButton(
                          onPressed: () => setState(() => selectedImage = null),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedDelete02,
                                color: MoboColor.redColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Remove Image",
                                style: TextStyle(color: MoboColor.redColor),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 20),
                      Text("Guideline(optional)"),
                      SizedBox(height: 5),

                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: MoboColor.white,
                          hintText: "eg:hotels:only week days..",
                          helperStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                submitButton(
                  title: "Update Category",
                  color: MoboColor.redColor,
                  onclick: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// UI HELPERS

  Widget _selectedWithDelete({
    required String text,
    required bool isDark,
    required VoidCallback onDelete,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey.shade300,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
        ),
        IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedDelete02,
            color: Colors.red,
          ),
          onPressed: onDelete,
        ),
      ],
    );
  }

  ///text field widget
  Widget _textField({
    required TextEditingController controller,
    String label = "__",
    bool required = false,
    bool isDark = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,

        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hint: Text(label),
          filled: true,
          fillColor: isDark ? Colors.grey[800] : MoboColor.white,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(bool isDark) => InputDecoration(
    filled: true,
    fillColor: isDark ? Colors.grey[800] : MoboColor.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );

  ///submit function
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      showSnackBar(
        context,
        "Please fill required fields",
        backgroundColor: Colors.red,
      );
      return;
    }

    final Map<String, dynamic> data = {
      'name': nameController.text.trim(),
      'default_code': codeController.text.trim(),
      'standard_price': double.tryParse(costController.text) ?? 0,
      'lst_price': double.tryParse(saleController.text) ?? 0,
      'description': descriptionController.text.trim(),
      'image_1920': selectedImage != null
          ? base64Encode(selectedImage!)
          : false,
    };

    if (selectedCategoryId != null) data['categ_id'] = selectedCategoryId;

    if (selectedTax.isNotEmpty) {
      data['supplier_taxes_id'] = [
        [6, 0, selectedTax.map((e) => e.id).toList()],
      ];
    } else if (previousTaxIds.isNotEmpty) {
      data['supplier_taxes_id'] = previousTaxIds.map((id) => [3, id]).toList();
    }

    loadingDialog(
      context,
      "Updating categories",
      "Please wait",
      LoadingAnimationWidget.fourRotatingDots(
        color: MoboColor.redColor,
        size: 30,
      ),
    );

    final result = await context.read<CommonProvider>().updateCategory(
      id: widget.category.id,
      data: data,
    );
    if (result) {
      await context.read<CommonProvider>().getAllCategory(reset: true);
      hideLoadingDialog(context);
      CustomSnackbar.showSuccess(context, "Category updated successfully");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (_) => false,
      );
    } else {
      hideLoadingDialog(context);
      CustomSnackbar.showError(context, "Some server error occured");
    }
  }
}
