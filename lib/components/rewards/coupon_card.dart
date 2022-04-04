import 'dart:math';
import 'package:flutter/material.dart';
import '../../main.dart';
import 'water_painter.dart';
import 'rounded_shadow.dart';
import 'styles.dart';
import 'demo_data.dart';

class CouponListCard extends StatefulWidget {
  static double heightClosed = 96;
  static double heightOpen = 290;

  final Function(CouponData) onClick;

  final bool isopen;
  final CouponData couponData;
  final int streak;

  const CouponListCard(
      {required Key key,
      required this.couponData,
      required this.onClick,
      this.isopen = false,
      this.streak = 100})
      : super(key: key);

  @override
  _CouponListCardState createState() => _CouponListCardState();
}

class _CouponListCardState extends State<CouponListCard>
    with TickerProviderStateMixin {
  bool _wasOpened = false;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late AnimationController _animation3;

  LiquidSimulation _liquidSim1 = LiquidSimulation();
  LiquidSimulation _liquidSim2 = LiquidSimulation();

  @override
  void initState() {
    _animation3 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    _animation3.addListener(_rebuildIfOpen);

    _animation1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animation3,
          curve: const Interval(.12, .45, curve: Curves.easeOut)),
    );

    _animation2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animation3,
          curve: const Interval(.1, .5, curve: Curves.easeOutQuart)),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animation3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isopen != _wasOpened) {
      if (widget.isopen) {
        _liquidSim1.start(_animation3, true);
        _liquidSim2.start(_animation3, false);

        _animation3.forward(from: 0);
      }
      _wasOpened = widget.isopen;
    }

    var requiredPoints = widget.couponData.streakPoints;
    var valuePoints =
        requiredPoints - _animation2.value * min(widget.streak, requiredPoints);

    double _maxFilled = min(1, widget.streak / widget.couponData.streakPoints);
    double filledLevel = _maxFilled;
    double cardHeight =
        widget.isopen ? CouponListCard.heightOpen : CouponListCard.heightClosed;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        curve: !_wasOpened ? ElasticOutCurve(.9) : Curves.elasticOut,
        duration: Duration(milliseconds: !_wasOpened ? 1200 : 1500),
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
                  opacity: widget.isopen ? 1 : 0,
                  duration: Duration(milliseconds: 500),
                  child: _buildLiquidBackground(_maxFilled, filledLevel),
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
                              milliseconds: widget.isopen ? 1000 : 500),
                          curve: Curves.easeOut,
                          opacity: widget.isopen ? 1 : 0,
                          child: _buildBottomContent(valuePoints),
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

  Stack _buildLiquidBackground(double _maxFilled, double filledLevel) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Transform.translate(
          offset: Offset(
              0,
              CouponListCard.heightOpen * 1.2 -
                  CouponListCard.heightOpen *
                      _animation1.value *
                      _maxFilled *
                      1.2),
          child: CustomPaint(
            painter: LiquidPainter(filledLevel, _liquidSim1, _liquidSim2,
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
            widget.couponData.couponTitle.toUpperCase(),
            style: Styles.text(18, Colors.black, true),
          ),
        ),
        Icon(Icons.star, size: 20, color: AppColors.blueAccent),
        SizedBox(width: 4),
        Text("${widget.couponData.streakPoints}",
            style: Styles.text(20, Colors.black, true))
      ],
    );
  }

  Column _buildBottomContent(double valuePoints) {
    bool isDisabled = widget.streak < widget.couponData.streakPoints;

    List<Widget> rowChildren = [];
    if (valuePoints == 0) {
      rowChildren.add(Text("Congratulations!!!",
          style: Styles.text(16, Colors.black, true)));
    } else {
      rowChildren.addAll([
        Text("You are only ", style: Styles.text(12, Colors.black, false)),
        Text(" ${valuePoints.round()} ",
            style: Styles.text(16, AppColors.blueAccent, true)),
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
          "Redeem your points for a gift for you, your family and your friends and enjoy your day while saving water",
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
                color: AppColors.blueAccentButtonColor,
                disabledColor: AppColors.blueAccentButtonColor,
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
    if (widget.onClick != null) {
      widget.onClick(widget.couponData);
    }
  }

  void _rebuildIfOpen() {
    if (widget.isopen) {
      setState(() {});
    }
  }
}
