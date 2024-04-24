import 'package:myjorurney/data/plan.dart';

class Request{
  List<Plan> plan;
  List<String> userName;
  List<String> phoneNumber;

  Request(this.plan,this.userName,this.phoneNumber);

  void setPlan(Plan plan) {
    this.plan.add(plan);
  }
  void setUserName(String userName) {
    this.userName.add(userName);
  }
  void setPhoneNumber(String phoneNumber) {
    this.phoneNumber.add(phoneNumber);
  }

}