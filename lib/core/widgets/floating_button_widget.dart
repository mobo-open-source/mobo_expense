import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/provider/bottom_nav_provider.dart';
import 'package:provider/provider.dart';
import '../../features/home/add_expense/add_expenses_screen.dart';
import '../../features/home/home_screen.dart';
import '../constants/constants.dart';

Widget floatingActionButtonWidget(
  BuildContext context, {
  bool isAdmin = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  var renderOverlay = true;
  var visible = true;
  var switchLabelPosition = false;
  var rmicons = false;
  var closeManually = false;
  var useRAnimation = true;
  var isDialOpen = ValueNotifier<bool>(false);
  var speedDialDirection = SpeedDialDirection.up;
  var buttonSize = Size(55, 55);
  var childrenButtonSize = const Size(56.0, 56.0);
  return SpeedDial(
    animatedIcon: AnimatedIcons.menu_close,
    icon: Icons.add,
    animatedIconTheme: IconThemeData(size: 22.0),
    spacing: 3,
    mini: false,
    openCloseDial: isDialOpen,
    childPadding: const EdgeInsets.all(5),
    spaceBetweenChildren: 4,

    iconTheme: IconThemeData(color: Colors.white),
    buttonSize: buttonSize,
    foregroundColor: isDark ? Colors.black87 : Colors.white,
    overlayColor: Colors.black,
    overlayOpacity: 0.12,
    backgroundColor: isDark ? Colors.white : MoboColor.redColor,
    childrenButtonSize: childrenButtonSize,
    visible: visible,
    direction: speedDialDirection,
    switchLabelPosition: switchLabelPosition,
    closeManually: closeManually,
    renderOverlay: renderOverlay,
    onOpen: () => {},
    onClose: () => {},
    useRotationAnimation: useRAnimation,
    elevation: 8.0,
    animationCurve: Curves.elasticInOut,
    isOpenOnStart: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(15),
    ),
    childMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),

    children: [
      if (isAdmin)
        SpeedDialChild(
          child: !rmicons
              ? const HugeIcon(icon: HugeIcons.strokeRoundedInvoice)
              : null,
          backgroundColor: MoboColor.redColor,
          foregroundColor: Colors.white,
          label: 'Approvals',
          onTap: () {
            context.read<BottomNavProvider>().changeIndex(2);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
          },
        ),
      SpeedDialChild(
        child: !rmicons ? HugeIcon(icon: HugeIcons.strokeRoundedFileAdd) : null,
        backgroundColor: MoboColor.redColor,
        foregroundColor: Colors.white,
        label: 'Create  Expense',
        onTap: () {
          context.read<BottomNavProvider>().changeIndex(1);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpensesScreen()),
          );
        },
      ),
    ],
  );
}
