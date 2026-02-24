import 'package:flutter/material.dart';
import 'package:mobo_expenses/core/widgets/simple_card.dart';

class customCardWithHeading extends StatelessWidget {
  final String heading;
  final Widget child;
  const customCardWithHeading(this.heading, this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return simpleCardWidget(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            heading,
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
