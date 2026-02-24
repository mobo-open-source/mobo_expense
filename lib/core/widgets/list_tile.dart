import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/provider/auth_provider.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';

Widget listTile({required String dbname}) {
  return Consumer<AuthProvider>(
    builder: (context, authProvider, _) {
      return GestureDetector(
        onTap: () {
          authProvider.showHideDatabase();
        },
        child: Container(
          height: 55,
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MoboRadius.input),
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedDatabase,
                size: 20,
                color: Colors.grey,
              ),
              SizedBox(width: 10),

              Text(
                authProvider.selectedDb,
                style: MoboText.body.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01),
            ],
          ),
        ),
      );
    },
  );
}
