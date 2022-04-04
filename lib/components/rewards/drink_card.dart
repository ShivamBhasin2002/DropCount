import 'dart:math';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'liquid_painter.dart';
import 'rounded_shadow.dart';
import 'syles.dart';
import 'demo_data.dart';

class DrinkListCard extends StatefulWidget {
  static double nominalHeightClosed = 96;
  static double nominalHeightOpen = 290;

  final Function(DrinkData) onTap;

  final bool isOpen;
  final DrinkData drinkData;
  final int earnedPoints;

  const DrinkListCard(
      {required Key key,
      required this.drinkData,
      required this.onTap,
      this.isOpen = false,
      this.earnedPoints = 100})
      : super(key: key);

  @override
  _DrinkListCardState createState() => _DrinkListCardState();
}

class _DrinkListCardState extends State<DrinkListCard>
    with TickerProviderStateMixin {
  bool _wasOpen = false;
  late Animation<double> _fillTween;
  late Animation<double> _pointsTween;
  late AnimationController _liquidSimController;

  LiquidSimulation _liquidSim1 = LiquidSimulation();
  LiquidSimulation _liquidSim2 = LiquidSimulation();

  @override
  void initState() {
    _liquidSimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    _liquidSimController.addListener(_rebuildIfOpen);

    _fillTween = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _liquidSimController,
          curve: const Interval(.12, .45, curve: Curves.easeOut)),
    );

    _pointsTween = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _liquidSimController,
          curve: const Interval(.1, .5, curve: Curves.easeOutQuart)),
    );
    super.initState();
  }

  @override
  void dispose() {
    _liquidSimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOpen != _wasOpen) {
      if (widget.isOpen) {
        _liquidSim1.start(_liquidSimController, true);
        _liquidSim2.start(_liquidSimController, false);

        _liquidSimController.forward(from: 0);
      }
      _wasOpen = widget.isOpen;
    }

    var pointsRequired = widget.drinkData.requiredPoints;
    var pointsValue = pointsRequired -
        _pointsTween.value * min(widget.earnedPoints, pointsRequired);

    double _maxFillLevel =
        min(1, widget.earnedPoints / widget.drinkData.requiredPoints);
    double fillLevel = _maxFillLevel;
    double cardHeight = widget.isOpen
        ? DrinkListCard.nominalHeightOpen
        : DrinkListCard.nominalHeightClosed;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        curve: !_wasOpen ? ElasticOutCurve(.9) : Curves.elasticOut,
        duration: Duration(milliseconds: !_wasOpen ? 1200 : 1500),
        height: cardHeight,
        child: RoundedShadow.fromRadius(
          12,
          shadowColor: Colors.grey.withOpacity(.2),
          child: Container(
            color: Colors.white,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                AnimatedOpacity(
                  opacity: widget.isOpen ? 1 : 0,
                  duration: Duration(milliseconds: 500),
                  child: _buildLiquidBackground(_maxFillLevel, fillLevel),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 24),
                        _buildTopContent(),
                        SizedBox(height: 12),
                        AnimatedOpacity(
                          duration: Duration(
                              milliseconds: widget.isOpen ? 1000 : 500),
                          curve: Curves.easeOut,
                          opacity: widget.isOpen ? 1 : 0,
                          child: _buildBottomContent(pointsValue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stack _buildLiquidBackground(double _maxFillLevel, double fillLevel) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Transform.translate(
          offset: Offset(
              0,
              DrinkListCard.nominalHeightOpen * 1.2 -
                  DrinkListCard.nominalHeightOpen *
                      _fillTween.value *
                      _maxFillLevel *
                      1.2),
          child: CustomPaint(
            painter: LiquidPainter(fillLevel, _liquidSim1, _liquidSim2,
                waveHeight: 100),
          ),
        ),
      ],
    );
  }

  Row _buildTopContent() {
    return Row(
      children: <Widget>[
        Image.asset(
          "images/coupon.png",
          fit: BoxFit.fitWidth,
          width: 50,
        ),
        SizedBox(width: 24),
        Expanded(
          child: Text(
            widget.drinkData.title.toUpperCase(),
            style: Styles.text(18, Colors.black, true),
          ),
        ),
        Icon(Icons.star, size: 20, color: AppColors.orangeAccent),
        SizedBox(width: 4),
        Text("${widget.drinkData.requiredPoints}",
            style: Styles.text(20, Colors.black, true))
      ],
    );
  }

  Column _buildBottomContent(double pointsValue) {
    bool isDisabled = widget.earnedPoints < widget.drinkData.requiredPoints;

    List<Widget> rowChildren = [];
    if (pointsValue == 0) {
      rowChildren.add(
          Text("Congratulations!", style: Styles.text(16, Colors.black, true)));
    } else {
      rowChildren.addAll([
        Text("You're only ", style: Styles.text(12, Colors.black, false)),
        Text(" ${pointsValue.round()} ",
            style: Styles.text(16, AppColors.orangeAccent, true)),
        Text(" points away", style: Styles.text(12, Colors.black, false)),
      ]);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        ),
        SizedBox(height: 16),
        Text(
          "Redeem your points for a cup of happiness! Our signature espresso is blanced with steamed milk and topped with a light layer of foam. ",
          textAlign: TextAlign.center,
          style: Styles.text(14, Colors.black, false, height: 1.5),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              spreadRadius: 4,
              blurRadius: 10,
              offset: Offset(0, 3),
            )
          ]),
          child: ButtonTheme(
            minWidth: 200,
            height: 40,
            child: Opacity(
              opacity: isDisabled ? .6 : 1,
              child: FlatButton(
                onPressed: isDisabled ? () {} : null,
                color: AppColors.orangeAccentButtonColor,
                disabledColor: AppColors.orangeAccentButtonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child:
                    Text("REDEEM", style: Styles.text(16, Colors.black, true)),
              ),
            ),
          ),
        )
      ],
    );
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap(widget.drinkData);
    }
  }

  void _rebuildIfOpen() {
    if (widget.isOpen) {
      setState(() {});
    }
  }
}
