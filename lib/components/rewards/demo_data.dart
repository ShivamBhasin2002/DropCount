class CouponData {
  final String couponTitle;
  final int streakPoints;

  CouponData(this.couponTitle, this.streakPoints);
}

class DemoData {
  int streak = 150;
  List<CouponData> drinks = [
    CouponData("Google Play", 100),
    CouponData("PUBG", 150),
    CouponData("MPL", 250),
    CouponData("Firebase Credits", 350),
    CouponData("GCP", 450),
  ];
}
