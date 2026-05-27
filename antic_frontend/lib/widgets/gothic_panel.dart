import 'package:flutter/material.dart';

class GothicPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const GothicPanel({super.key, required this.child, this.padding = const EdgeInsets.all(24)});

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFF2E2E2E);

    return Stack(
      children: [
        Positioned(
          top: -12,
          left: 12,
          child: Text(
            '✠',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 115),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Positioned(
          top: -12,
          right: 12,
          child: Text(
            '✠',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 115),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0A0A),
                  Color(0xFF0F0F0F),
                ],
              ),
              border: Border.all(color: border, width: 2),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 60,
                  color: Colors.black54,
                  offset: Offset(0, 0),
                ),
                BoxShadow(
                  blurRadius: 30,
                  spreadRadius: -10,
                  color: Color(0xFF000000),
                ),
              ],
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

