import 'package:flutter/material.dart';

class GothicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GothicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? Theme.of(context).dividerColor;

    final card = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: border, width: 1),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black54,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

