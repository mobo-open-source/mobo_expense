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
import '../../../../core/widgets/custom_card_h.dart';
import '../../../../core/widgets/simple_card.dart';
import '../../../../core/widgets/submit_button.dart';
import '../../../../shared/widgets/snackbars/custom_snackbar.dart';
import '../../home_screen.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final costController = TextEditingController();
  final saleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final taxController = TextEditingController();
  final reInvoicingExpense = TextEditingController();
  List<TaxModel> selectedTax = [];

  List<TaxModel> selectedSaleTax = [];

  Uint8List? selectedImage;

  bool get isFormValid => nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    nameController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  Future<void> _initialLoad() async {
    final provider = context.read<CommonProvider>();
    try {
      provider.changingLoading(true);
      await provider.gettingProductCategory();
      await provider.getFullTaxWithoutCompany();
    } finally {
      provider.changingLoading(false);
    }
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
    reInvoicingExpense.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => selectedImage = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<CommonProvider>();

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : MoboColor.white,
        elevation: 0,
        title: Text(
          "Create Category",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
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
        child: provider.isLoading
            ? _buildLoading()
            : _buildForm(isDark, provider),
      ),
    );
  }

  ///  Loading UI
  Widget _buildLoading() {
    return ListView(
      children: List.generate(
        5,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CardLoading(
            height: 180,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  ///  Form UI
  Widget _buildForm(bool isDark, CommonProvider provider) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            /// Category info
            simpleCardWidget(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Category Information",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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

                  SizedBox(height: 5),
                  Text("Internal code"),
                  SizedBox(height: 5),

                  _textField(
                    controller: codeController,
                    label: "Eg: CTG,PDR...",
                    isDark: isDark,
                  ),

                  const SizedBox(height: 10),

                  Text("Parent Category"),
                  SizedBox(height: 5),

                  provider.productCategoryLoading
                      ? const CardLoading(height: 60)
                      : DropdownButtonFormField2<dynamic>(
                          isExpanded: true,
                          hint: const Text("Select Parent Category"),
                          items: provider.productCategory
                              .map(
                                (cat) => DropdownMenuItem<dynamic>(
                                  value: cat,
                                  child: Text(cat['display_name']),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            categoryController.text = value['id'].toString();
                          },
                          dropdownStyleData: _dropdownStyle(isDark),
                          decoration: _dropdownDecoration(isDark),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Pricing
            simpleCardWidget(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pricing", style: MoboText.h3),
                  const SizedBox(height: 15),

                  Text("Price"),
                  SizedBox(height: 5),

                  _textField(
                    controller: costController,
                    label: "Cost Price",
                    keyboardType: TextInputType.number,
                    isDark: isDark,
                  ),

                  Text("Sale Price"),
                  SizedBox(height: 5),

                  _textField(
                    controller: saleController,
                    label: "Sale Price",
                    keyboardType: TextInputType.number,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 10),

                  Text("Purchase Tax"),
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

                              /// update text field
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
                  provider.gettingfulltaxloading
                      ? const CardLoading(height: 80)
                      : DropdownButtonFormField2<TaxModel>(
                          isExpanded: true,

                          hint: const Text("Select Tax"),

                          items: provider.totalTaxWithoutCompany.map((tax) {
                            return DropdownMenuItem<TaxModel>(
                              value: tax,
                              enabled: false,
                              child: StatefulBuilder(
                                builder: (context, menuSetState) {
                                  final isSelected = selectedTax.contains(tax);

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
                              color: isDark ? Colors.grey[900] : Colors.white,
                            ),
                          ),

                          decoration: _dropdownDecoration(isDark),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Image
            customCardWithHeading(
              "Other Information",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category Image(optional)"),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        image: selectedImage != null
                            ? DecorationImage(
                                image: MemoryImage(selectedImage!),
                                fit: BoxFit.contain,
                              )
                            : null,
                      ),
                      child: selectedImage == null
                          ? const Center(child: Text("Tap to add image"))
                          : null,
                    ),
                  ),

                  SizedBox(height: 10),
                  Text("Guideline"),
                  SizedBox(height: 5),

                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      fillColor: MoboColor.white,
                      filled: true,

                      hintText: "eg: Hotels:only week days..",
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Submit Button
            submitButton(
              title: "Create Category",
              color: isFormValid ? MoboColor.redColor : Colors.black,
              onclick: isFormValid ? _submit : null,
              active: isFormValid,
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// Submit
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      CustomSnackbar.showWarning(context, "Please fill required fields");
      return;
    }

    final data = {
      'name': nameController.text,
      'default_code': codeController.text,
      'standard_price': double.tryParse(costController.text) ?? 0,
      'lst_price': double.tryParse(saleController.text) ?? 0,
      'description': descriptionController.text,
    };

    if (categoryController.text.isNotEmpty) {
      data['categ_id'] = int.parse(categoryController.text);
    }
    if (taxController.text.isNotEmpty) {
      data['supplier_taxes_id'] = selectedTax.map((id) => [4, id.id]).toList();
    }
    if (selectedImage != null) {
      data['image_1920'] = base64Encode(selectedImage!);
    }

    try {
      loadingDialog(
        context,
        "Creating category",
        "Please wait",
        LoadingAnimationWidget.fourRotatingDots(
          color: MoboColor.redColor,
          size: 30,
        ),
      );

      final result = await context.read<CommonProvider>().submitCategory(
        data: data,
        name: nameController.text.trim(),
      );

      if (result) {
        await context.read<CommonProvider>().getAllCategory(reset: true);
        hideLoadingDialog(context);

        CustomSnackbar.showSuccess(context, "Category created successfully");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (_) => false,
        );
      } else {
        hideLoadingDialog(context);
        CustomSnackbar.showError(context, "Failed to create category");
      }
    } catch (e) {
      hideLoadingDialog(context);
      CustomSnackbar.showError(context, "Failed to create category");
    }
  }

  ///  Inputs
  Widget _textField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    bool isDark = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,

        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? Colors.grey[800] : MoboColor.white,
          hint: Text(label),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  DropdownStyleData _dropdownStyle(bool isDark) => DropdownStyleData(
    maxHeight: 300,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: isDark ? Colors.grey[900] : Colors.white,
    ),
  );

  InputDecoration _dropdownDecoration(bool isDark) => InputDecoration(
    filled: true,
    fillColor: isDark ? Colors.grey[800] : MoboColor.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}
