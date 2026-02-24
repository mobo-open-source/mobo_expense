import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/constants.dart';

///showing back dialog method

Future<bool> showBackDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String leftButtonName,
  required String rightButtonName,
  required VoidCallback function,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: isDark ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
                      color: isDark
                          ? Colors.red
                          : MoboColor.redColor.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(12),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedAlert02,
                      color: isDark ? Colors.white : MoboColor.redColor,
                    ),
                  ),
                  SizedBox(height: 10),

                  Text(
                    title,
                    style: MoboText.h3.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: MoboText.normal.copyWith(
                      color: isDark ? Colors.white : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: Key("fail"),

                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(120, 40),

                            backgroundColor: MoboColor.white,

                            side: BorderSide(
                              color: Colors.grey.shade400,

                              ///  border color
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text(
                            leftButtonName,
                            style: MoboText.normal.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),

                      Expanded(
                        child: ElevatedButton(
                          key: Key("Success"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 40),

                            backgroundColor: MoboColor.redColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: function,
                          child: Text(
                            rightButtonName,
                            style: MoboText.h3.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ) ??
      false;
}
