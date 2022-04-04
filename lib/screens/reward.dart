import 'dart:ui';
import 'package:flutter/material.dart';

import '../main.dart';
import '../components/rewards/styles.dart';
import '../components/rewards/demo_data.dart';
import '../components/rewards/rounded_shadow.dart';
import '../components/rewards/coupon_card.dart';

class Rewards extends StatefulWidget {
  @override
  _RewardsState createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> {
  double _listPadding = 20;
  CouponData? _selectedDrink;
  ScrollController _scrollController = ScrollController();
  late List<CouponData> _drinks;
  late int _earnedPoints;

  @override
  void initState() {
    var demoData = DemoData();
    _drinks = demoData.drinks;
    _earnedPoints = demoData.streak;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).size.aspectRatio > 1;
    double headerHeight =
        MediaQuery.of(context).size.height * (isLandscape ? .25 : .2);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Theme(
        data: ThemeData(fontFamily: "Poppins", primarySwatch: Colors.orange),
        child: Stack(
          children: <Widget>[
            ListView.builder(
              padding: EdgeInsets.only(bottom: 40, top: headerHeight + 10),
              itemCount: _drinks.length,
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              itemBuilder: (context, index) => _buildListItem(index),
            ),
            _buildTopBg(headerHeight),
            _buildTopContent(headerHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: _listPadding / 2, horizontal: _listPadding),
      child: CouponListCard(
        streak: _earnedPoints,
        couponData: _drinks[index],
        isopen: _drinks[index] == _selectedDrink,
        onClick: _handleDrinkTapped,
        key: Key(index.toString()),
      ),
    );
  }

  Widget _buildTopBg(double height) {
    return Container(
      alignment: Alignment.topCenter,
      height: height,
      child: RoundedShadow(
          topLeftRadius: 0,
          topRightRadius: 0,
          shadowColor: Colors.white.withOpacity(.2),
          child: Container(
            width: double.infinity,
            child: Image.asset(
              "images/rewardHeader.png",
              fit: BoxFit.fill,
            ),
          )),
    );
  }

  Widget _buildTopContent(double height) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: EdgeInsets.all(height * .08),
          constraints: BoxConstraints(maxHeight: height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("My Rewards",
                  style: Styles.text(height * .13, Colors.white, true)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.star,
                      color: AppColors.StarAccent, size: height * .2),
                  SizedBox(width: 8),
                  Text("$_earnedPoints",
                      style: Styles.text(height * .3, Colors.white, true)),
                ],
              ),
              Text("Your Points Balance",
                  style: Styles.text(height * .1, Colors.white, false)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDrinkTapped(CouponData data) {
    setState(() {
      if (_selectedDrink == data) {
        _selectedDrink = _drinks[0];
      } else {
        _selectedDrink = data;
        var selectedIndex = _drinks.indexOf(_selectedDrink ?? _drinks[0]);
        var closedHeight = CouponListCard.heightClosed;
        var offset =
            selectedIndex * (closedHeight + _listPadding) - closedHeight * .35;
        _scrollController.animateTo(offset,
            duration: Duration(milliseconds: 700), curve: Curves.easeOutQuad);
      }
    });
  }
}
