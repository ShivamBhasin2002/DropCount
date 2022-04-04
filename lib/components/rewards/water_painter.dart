import 'dart:math';

import 'package:flutter/material.dart';

class LiquidSimulation {
  int curveCount = 4;
  List<Offset> endPoints = [];
  List<Animation<double>> ctrlAnimation = [];
  List<Offset> ctrlPoints = [];

  late double duration;
  double endPtY1 = 1;
  double xOffset = 0;
  late double time;
  double endPtX1 = .5;

  final ElasticOutCurve _ease = ElasticOutCurve(.3);

  late double hzScale;
  late double hzOffset;

  void start(AnimationController controller, bool flipY) {
    controller.addListener(updateControlPointsFromTweens);

    var gap = 1 / (curveCount * 2.0);

    hzScale = 1.25 + Random().nextDouble() * .5;
    hzOffset = -.2 + Random().nextDouble() * .4;

    endPoints.clear();

    endPoints.insert(0, Offset(0, 0));
    for (var i = 1; i < curveCount; i++) {
      endPoints.add(Offset(gap * i * 2, 0));
    }

    endPoints.add(Offset(1, 0));

    ctrlPoints.clear();
    for (var i = 0; i < curveCount + 1; i++) {
      var height = (.5 + Random().nextDouble() * .5) *
          (i % 2 == 0 ? 1 : -1) *
          (flipY ? -1 : 1);

      var animSequence = TweenSequence([
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 0),
          weight: 10.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: height)
              .chain(CurveTween(curve: Curves.linear)),
          weight: 10.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: height, end: 0)
              .chain(CurveTween(curve: _ease)),
          weight: 60.0,
        )
      ]).animate(controller);
      ctrlAnimation.add(animSequence);
      ctrlPoints.add(Offset(gap + gap * i * 2, height));
    }
  }

  List<Offset> updateControlPointsFromTweens() {
    for (var i = 0; i < ctrlPoints.length; i++) {
      var o = ctrlPoints[i];
      ctrlPoints[i] = Offset(o.dx, ctrlAnimation[i].value);
    }
    return ctrlPoints;
  }
}

class LiquidPainter extends CustomPainter {
  final double fillLevel;
  final LiquidSimulation simulation1;
  final LiquidSimulation simulation2;
  final double waveHeight;

  LiquidPainter(this.fillLevel, this.simulation1, this.simulation2,
      {this.waveHeight = 200});

  @override
  void paint(Canvas canvas, Size size) {
    _drawLiquidSim(
        simulation1, canvas, size, 0, Color.fromARGB(255, 94, 172, 236));
    _drawLiquidSim(
        simulation2, canvas, size, 5, Color.fromARGB(255, 94, 172, 236));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void _drawLiquidSim(LiquidSimulation simulation, Canvas canvas, Size size,
      double offsetY, Color color) {
    canvas.scale(simulation.hzScale, 1);
    canvas.translate(simulation.hzOffset * size.width, offsetY);

    var path = Path()
      ..moveTo(size.width * 1.25, 0)
      ..lineTo(size.width * 1.25, size.height)
      ..lineTo(-size.width * .25, size.height)
      ..lineTo(-size.width * .25, 0);

    for (var i = 0; i < simulation.curveCount; i++) {
      var ctrlPt = sizeOffset(simulation.ctrlPoints[i], size);
      var endPt = sizeOffset(simulation.endPoints[i + 1], size);
      path.quadraticBezierTo(ctrlPt.dx, ctrlPt.dy, endPt.dx, endPt.dy);
    }
    canvas.drawPath(path, Paint()..color = color);

    canvas.translate(-simulation.hzOffset * size.width, -offsetY);
    canvas.scale(1 / simulation.hzScale, 1);
  }

  void _drawOffsets(LiquidSimulation simulation, Canvas canvas, Size size) {
    var floor = size.height;
    simulation1.endPoints.forEach((pt) {
      canvas.drawCircle(sizeOffset(pt, size), 4, Paint()..color = Colors.red);
    });
    simulation1.ctrlPoints.forEach((pt) {
      canvas.drawCircle(sizeOffset(pt, size), 4, Paint()..color = Colors.green);
    });
  }

  Offset sizeOffset(Offset pt, Size size) {
    return Offset(pt.dx * size.width, waveHeight * pt.dy);
  }
}
