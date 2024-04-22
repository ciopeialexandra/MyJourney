import 'package:myjorurney/data/plan.dart';

class Request{
  Plan plan;
  String userName;
  String phoneNumber;

  Request(this.plan,this.userName,this.phoneNumber);

  void setPlan(Plan plan) {
    this.plan = plan;
  }
  void setUserName(String userName) {
    this.userName = userName;
  }
  void setPhoneNumber(String phoneNumber) {
    this.phoneNumber = phoneNumber;
  }

}