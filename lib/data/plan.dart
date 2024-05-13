
class Plan {
  String? key;
  String budget;
  String date;
  String town;
  bool isSkiing;
  bool isBigCity;
  bool isHistoricalHeritage;
  bool isSwimming;
  bool isShopping;
  bool isNature;
  bool isTropical;
  bool isThree;
  bool isSeven;
  bool isTen;
  String userId;
  String voted = "no";

  Plan(this.key, this.budget, this.date, this.town,this.isSkiing,this.isBigCity,this.isHistoricalHeritage,this.isSwimming,this.isShopping,this.isNature,this.isTropical,this.isThree,this.isSeven,this.isTen,this.userId);

  void setPlanKey(String? key) {
    this.key = key;
  }
  void setPlanBudget(String budget) {
    this.budget = budget;
  }
  void setPlanDate(String date) {
    this.date = date;
  }
  void setPlanSki(bool value) {
    isSkiing = value;
  }
  void setPlanCity(bool value) {
    isBigCity = value;
  }
  void setPlanHistorical(bool value) {
    isHistoricalHeritage = value;
  }
  void setPlanSwim(bool value) {
    isSwimming = value;
  }
  void setPlanShopping(bool value) {
    isShopping = value;
  }
  void setPlanNature(bool value) {
    isNature = value;
  }
  void setPlanTown(String value) {
    town = value;
  }
  void setPlanTropical(bool value) {
    isTropical = value;
  }
  void setPlanThree(bool value) {
    isThree = value;
  }
  void setPlanSeven(bool value) {
    isSeven = value;
  }
  void setPlanTen(bool value) {
    isTen = value;
  }
  // void setPlanStartDate(DateTime value) {
  //   startDate = value;
  // }
  // void setPlanEndDate(DateTime value) {
  //   endDate = value;
  // }
  String? getPlanKey(){
    return key;
  }
  String getPlanBudget(){
    return budget;
  }
  String getPlanDate(){
    return date;
  }
  bool getPlanSki(){
    return isSkiing;
  }
  bool getPlanCity(){
    return isBigCity;
  }
  bool getPlanHistorical(){
    return isHistoricalHeritage;
  }
  bool getPlanSwim(){
    return isSwimming;
  }
  bool getPlanShopping(){
    return isShopping;
  }
  bool getPlanNature(){
    return isNature;
  }
  String getPlanTown(){
    return town;
  }
  bool getPlanTropical(){
    return isTropical;
  }
  bool getPlanThree(){
    return isThree;
  }
  bool getPlanSeven(){
    return isSeven;
  }
  bool getPlanTen(){
    return isTen;
  }
  // DateTime getPlanStartDate(){
  //   return startDate;
  // }
  // DateTime getPlanEndDate(){
  //   return endDate;
  // }
}