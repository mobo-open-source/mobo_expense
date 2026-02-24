import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../constants/constants.dart';

Widget textFormWidget({
  final Function? onclick,
  required String hintText,
  required TextEditingController controller,
  required Widget icon,
  required bool isItPassword,
  required BuildContext context,
  bool? obscureText,
}) {
  return Consumer<AuthProvider>(
    builder: (context, authProvider, child) {
      return Container(
        constraints: BoxConstraints(minWidth: 400, maxWidth: 600),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Padding(padding: const EdgeInsets.only(left: 12), child: icon),
            Expanded(
              child: TextFormField(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),

                controller: controller,

                obscureText: isItPassword ? obscureText! : false,
                onChanged: (value) {
                  authProvider.changeErrorEmail(false);
                },

                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: hintText,
                  hintStyle: MoboText.body,
                ),
              ),
            ),
            isItPassword
                ? GestureDetector(
                    onTap: () {
                      onclick;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.remove_red_eye, color: Colors.grey),
                    ),
                  )
                : authProvider.emptyEmail
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedAlertCircle,
                      color: Colors.red,
                      size: 18,
                    ),
                  )
                : SizedBox(),
          ],
        ),
      );
    },
  );
}
