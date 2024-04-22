
class Plan {
  String budget;
  String date;
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
  String result;

  Plan(this.budget, this.date,this.isSkiing,this.isBigCity,this.isHistoricalHeritage,this.isSwimming,this.isShopping,this.isNature,this.isTropical,this.isThree,this.isSeven,this.isTen,this.result);

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
  void setPlanResult(String value) {
    result = value;
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
  String getPlanResult(){
    return result;
  }
  String getPlanTropical(){
    return result;
  }
  String getPlanThree(){
    return result;
  }
  String getPlanSeven(){
    return result;
  }
  String getPlanTen(){
    return result;
  }
  // DateTime getPlanStartDate(){
  //   return startDate;
  // }
  // DateTime getPlanEndDate(){
  //   return endDate;
  // }
}