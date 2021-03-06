import 'dart:math';

import 'package:flutter/material.dart';

class RoundedShadow extends StatelessWidget {
  final Widget child;
  final Color? shadowColor;

  final double topLeftRadius;
  final double topRightRadius;
  final double bottomLeftRadius;
  final double bottomRightRadius;

  RoundedShadow(
      {Key? key,
      required this.shadowColor,
      this.topLeftRadius = 48,
      this.topRightRadius = 48,
      this.bottomLeftRadius = 48,
      this.bottomRightRadius = 48,
      required this.child})
      : super(key: key);

  RoundedShadow.fromRadius(double radius,
      {Key? key, required this.child, required this.shadowColor})
      : topLeftRadius = radius,
        topRightRadius = radius,
        bottomLeftRadius = radius,
        bottomRightRadius = radius;

  @override
  Widget build(BuildContext context) {
    var r = BorderRadius.only(
      topLeft: Radius.circular(topLeftRadius),
      topRight: Radius.circular(topRightRadius),
      bottomLeft: Radius.circular(bottomLeftRadius),
      bottomRight: Radius.circular(bottomRightRadius),
    );
    var sColor = shadowColor ?? Color(0x20000000);

    var maxRadius = [
      topLeftRadius,
      topRightRadius,
      bottomLeftRadius,
      bottomRightRadius
    ].reduce(max);
    return Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [BoxShadow(color: sColor, blurRadius: maxRadius * .5)],
      ),
      child: ClipRRect(borderRadius: r, child: child),
    );
  }
}
