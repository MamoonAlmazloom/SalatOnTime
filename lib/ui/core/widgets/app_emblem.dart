import 'package:flutter/material.dart';

/// The launcher artwork (white mosque + gold clock) as an in-app emblem.
///
/// The source PNG is an adaptive-icon foreground, so the drawing sits inside
/// a large transparent safe zone; the scale crops that padding away. Meant
/// for gradient/emerald surfaces — the mosque itself is white.
class AppEmblem extends StatelessWidget {
  const AppEmblem({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: Transform.scale(
          scale: 1.55,
          child: Image.asset(
            'assets/icon/icon_foreground.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
