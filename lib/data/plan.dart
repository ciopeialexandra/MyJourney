
class Plan {
  String? key;
  String budget;
  String date;
  String town;
  String days = "";
  bool isSkiing;
  bool isBigCity;
  bool isHistoricalHeritage;
  bool isSwimming;
  bool isShopping;
  bool isNature;
  bool isTropical;
  bool isNightlife;
  bool isUnique;
  bool isPopular;
  bool isLuxury;
  bool isCruises;
  bool isRomantic;
  bool isThermalSpa;
  bool isAdventure;
  bool isRelaxing;
  String userId;
  String voted = "no";

  Plan(this.key, this.budget, this.date, this.town,this.isThermalSpa,this.isAdventure,this.isRelaxing,this.isUnique,this.isPopular,this.isLuxury,this.isCruises,this.isRomantic,this.isSkiing,this.isBigCity,this.isHistoricalHeritage,this.isSwimming,this.isShopping,this.isNature,this.isTropical,this.isNightlife,this.userId);

  void setPlanKey(String? key) {
    this.key = key;
  }
  void setPlanBudget(String budget) {
    this.budget = budget;
  }
  void setPlanDate(String date) {
    this.date = date;
  }
  void setPlanUnique(bool value) {
    isUnique = value;
  }
  void setPlanPopular(bool value) {
    isPopular = value;
  }
  void setPlanLuxury(bool value) {
    isLuxury = value;
  }
  void setPlanCruises(bool value) {
    isCruises = value;
  }
  void setPlanRomantic(bool value) {
    isRomantic = value;
  }
  void setPlanRelaxing(bool value) {
    isRelaxing = value;
  }
  void setPlanThermalSpa(bool value) {
    isThermalSpa = value;
  }
  void setPlanAdventure(bool value) {
    isAdventure = value;
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
  void setPlanNightlife(bool value) {
    isNightlife = value;
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
  void setPlanDays(String value) {
    days = value;
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
  String getPlanDays(){
    return days;
  }
  bool getPlanNightlife(){
    return isNightlife;
  }
  bool getPlanUnique(){
    return isUnique;
  }
  bool getPlanPopular(){
    return isPopular;
  }
  bool getPlanLuxury(){
    return isLuxury;
  }
  bool getPlanCruises(){
    return isCruises;
  }
  bool getPlanRomantic(){
    return isRomantic;
  }
  bool getPlanThermalSpa(){
    return isThermalSpa;
  }
  bool getPlanAdventure(){
    return isAdventure;
  }
  bool getPlanRelaxing(){
    return isRelaxing;
  }
  // DateTime getPlanStartDate(){
  //   return startDate;
  // }
  // DateTime getPlanEndDate(){
  //   return endDate;
  // }
}