import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/dialog_box.dart';

void loadingDialog(
  BuildContext context,
  String title,
  String subTitle,
  Widget icon,
) {
  dialogBox(
    context,
    title,
    icon,
    Text(
      subTitle,

      style: MoboText.nav.copyWith(color: Colors.black54),
      textAlign: TextAlign.center,
    ),
  );
}

///hide loading dialog
void hideLoadingDialog(BuildContext context) {
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
