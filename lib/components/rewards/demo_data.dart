class DrinkData {
  final String title;
  final int requiredPoints;

  DrinkData(this.title, this.requiredPoints);
}

class DemoData {
  int earnedPoints = 150;
  List<DrinkData> drinks = [
    DrinkData("Coffee", 100),
    DrinkData("Tea", 150),
    DrinkData("Latte", 250),
    DrinkData("Frappuccino", 350),
    DrinkData("Pressed Juice", 450),
  ];
}
