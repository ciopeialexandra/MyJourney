import 'package:myjorurney/data/plan.dart';

class Request{
  String key;
  List<Plan> plan;
  List<String> userName;
  List<String> phoneNumber;

  Request(this.key,this.plan,this.userName,this.phoneNumber);

  void setKey(String key) {
    this.key = key;
  }
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