import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/plan-trip_page.dart';
import '../data/globals.dart';
import '../data/plan.dart';
import '../data/request.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  Future<List<Request>> _setRequestDetails() async{
    //verifies if there are any trip requests for this user and adds their details to a list
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    User? user = FirebaseAuth.instance.currentUser;
    String requestId = "";
    String userIdRequest = "";
    String userPhoneRequest = "";
    String userNameRequest = "";
    request = [];
    Request requestLocal = Request("", [], [], []);
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var planLocal in snapshot.children) {
        if (planLocal
            .child("userId")
            .value!
            .toString() == user?.uid
            && planLocal
                .child("budget")
                .value!
                .toString().isEmpty) { //aici cautam daca userul curent are vreun request deschis
          Plan localPlan = Plan("", "" ,"","",false,false,false,false,false,false,false,false,false,false,"");
          requestId = planLocal.child("requestId").value!.toString();
          requestLocal.key = requestId;
          DataSnapshot requestPlan = await ref.child('plan').get();
          localPlan.setPlanKey(planLocal.key);
          for (var requestLocal in requestPlan.children) { //cautam in db plan-ul userului care a trimis requestul
            if(requestLocal.child("requestId").value!.toString() == requestId&&requestLocal.key!=planLocal.key){
             userIdRequest = requestLocal.child("userId").value!.toString();
            }
          }
          DataSnapshot requestUser = await ref.child('user').get();
          for (var userLocal in requestUser.children) {
            if(userLocal.key == userIdRequest ){ //cautam in user user-ul care a trimis requestul
             userPhoneRequest = userLocal.child("telephone").value!.toString();
             userNameRequest = userLocal.child("name").value!.toString();
            }
          }
          localPlan.date = planLocal.child("date").toString();
          localPlan.budget = planLocal.child("budget").toString();
           if (planLocal.child("isBeach").toString() == "true") {
             localPlan.isSwimming = true;
           }
           else
             {
               localPlan.isSwimming = false;
             }
          if (planLocal.child("isCity").toString() == "true") {
            localPlan.isBigCity = true;
          }
          else
          {
            localPlan.isBigCity = false;
          }
          if (planLocal.child("isHistorical").toString() == "true") {
            localPlan.isHistoricalHeritage = true;
          }
          else
          {
            localPlan.isHistoricalHeritage = false;
          }
          if (planLocal.child("isNature").toString() == "true") {
            localPlan.isNature = true;
          }
          else
          {
            localPlan.isNature = false;
          }
          if (planLocal.child("isSki").toString() == "true") {
            localPlan.isSkiing = true;
          }
          else
          {
            localPlan.isSkiing = false;
          }
          if (planLocal.child("isTropical").toString() == "true") {
            localPlan.isTropical = true;
          }
          else
          {
            localPlan.isTropical = false;
          }
          requestLocal.setPlan(localPlan);
          requestLocal.setPhoneNumber(userPhoneRequest);
          requestLocal.setUserName(userNameRequest);
          request.add(requestLocal);
        }
      }
    } catch (error) {
      print(error);
    }
    return request;
  }
  Widget _animatedText(){
    return DefaultTextStyle(
      style: const TextStyle(
          fontSize: 20.0,
          color: Colors.black
      ),
      child: AnimatedTextKit(
        animatedTexts : [
          TyperAnimatedText('Your notifications:'),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }
  void navigateToPlan() {
    isPlanRequest = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const PlanTripPage(),
      ),
    );
  }
  Widget _title() {
    return const Text("My Journey");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _title(),
        ),
        body: FutureBuilder<void>(
          future: _setRequestDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _animatedText(),
                  ),
                  ListView.separated(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: request.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          requestIndex = index;
                          navigateToPlan();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(request[index].phoneNumber[0]), // aici  ar trebui afisati toti userii de la care vine requestul,nu doar de la primul
                              Text(request[index].userName[0]),
                            ],
                          ),
                        ),
                      );
                    }, separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),

                ],
              );
            }
          },
        )
    );
  }
}
