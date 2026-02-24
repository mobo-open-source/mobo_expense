import 'package:flutter/material.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:provider/provider.dart';

Widget reportWrapper({
  required Widget child,

  required CommonProvider commonProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CommonProvider>.value(value: commonProvider),
    ],
    child: MaterialApp(home: child),
  );
}
