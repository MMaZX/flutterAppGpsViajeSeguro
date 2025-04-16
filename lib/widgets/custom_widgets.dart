import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CardCustom extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String subtitle;
  const CardCustom(
      {super.key,
      required this.iconData,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ShadCard(
        backgroundColor: Colors.transparent,
        rowMainAxisAlignment: MainAxisAlignment.start,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: ShadImage.square(iconData, size: 18),
        ),
        padding: const EdgeInsets.all(15),
        title: Text(
          title,
          style: theme.p.copyWith(
            height: 0,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        description: Text(subtitle),
      ),
    );
  }
}
