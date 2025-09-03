import 'package:flutter/material.dart';
import 'build_utils.dart';

class ActionItem {
  final String name;
  final IconData icon;
  final VoidCallback? callback;
  ActionItem({
    required this.name,
    required this.icon,
    this.callback,
  });
}

class OperationBar extends StatelessWidget {
  final List<ActionItem> items;

  const OperationBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      margin: EdgeInsets.symmetric(
        horizontal: boardPaddingH(context),
        vertical: 10,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: items
            .map(
              (e) => TextButton.icon(
                icon: Icon(e.icon),
                label: Text(e.name),
                onPressed: e.callback,
              ),
            )
            .toList(),
      ),
    );
  }
}
