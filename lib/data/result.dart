
class Result {
  String image = "";
  String itinerary = "";
  String cityAndCountry = "";
  int numberOfLikes = 0;
  String key = "";
  String budgetSpending = "";

  Result(this.image, this.itinerary, this.cityAndCountry,this.key,this.budgetSpending);

  void setResultImage(String image) {
    this.image = image;
  }
  void setResultItinerary(String itinerary) {
    this.itinerary = itinerary;
  }
  void setResultCityAndCountry(String cityAndCountry) {
    this.cityAndCountry = cityAndCountry;
  }
}