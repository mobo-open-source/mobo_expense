import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';

class CommonResultPanel<T> extends StatelessWidget {
  final bool visible;
  final bool isLoading;
  final List<T> items;
  final double height;
  final Widget Function(BuildContext, T) itemBuilder;
  final void Function(T)? onTap;
  final Widget? loadingBuilder;
  final Widget? emptyBuilder;
  final EdgeInsets padding;

  const CommonResultPanel({
    super.key,
    required this.visible,
    required this.isLoading,
    required this.items,
    required this.itemBuilder,
    this.onTap,
    this.height = 250,
    this.loadingBuilder,
    this.emptyBuilder,
    this.padding = const EdgeInsets.only(left: 2, right: 2, top: 2),
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: height,
          child: isLoading
              ? (loadingBuilder ?? _defaultLoading())
              : (items.isEmpty
                    ? (emptyBuilder ?? _defaultEmpty())
                    : _buildList()),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: padding,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final row = itemBuilder(context, item);
        if (onTap == null) return row;
        return GestureDetector(onTap: () => onTap!(item), child: row);
      },
    );
  }

  Widget _defaultLoading() {
    return ListView(
      padding: padding,
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: CardLoading(
            height: 75,
            borderRadius: BorderRadius.circular(MoboRadius.card),
          ),
        ),
      ),
    );
  }

  Widget _defaultEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('No results', style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}
