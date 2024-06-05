import 'package:myjorurney/data/plan.dart';
import 'package:myjorurney/data/user.dart';

class Request{
  String key;
  String status;
  List<Plan> plan;
  List<UserClass> user;

  Request(this.key,this.plan,this.user,this.status);

  void setKey(String key) {
    this.key = key;
  }
  void setPlan(Plan plan) {
    this.plan.add(plan);
  }
  void setUser(UserClass user) {
    this.user.add(user);
  }

}