import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/constants.dart';

dialogBoxWithTextField(
  BuildContext context,
  GlobalKey<FormState> formKey,
  TextEditingController controller,
  VoidCallback function,
) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        key: Key("refuse_dailog"),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 60,
                width: 60,

                decoration: BoxDecoration(
                  color: MoboColor.redColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(12),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedAlert02,
                  color: MoboColor.redColor,
                ),
              ),
              SizedBox(height: 10),

              Text(
                "Refuse Expense",
                style: MoboText.h3.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some thing ';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MoboColor.redColor.withAlpha(20),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Enter the reason",
                    hintStyle: MoboText.body,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(120, 40),

                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text(
                      "cancel",
                      style: MoboText.normal.copyWith(color: Colors.black),
                    ),
                  ),

                  ElevatedButton(
                    key: Key("refuse_btn"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(120, 40),

                      backgroundColor: MoboColor.redColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: function,
                    child: Text(
                      "Refuse",
                      style: MoboText.h3.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
