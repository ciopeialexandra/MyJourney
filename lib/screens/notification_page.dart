import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/common/page_heading.dart';
import 'package:myjorurney/screens/plan-trip_page.dart';
import '../data/globals.dart';
import '../data/plan.dart';
import '../data/request.dart';
import '../data/user.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  Future<List<Request>> _setRequestDetails() async{
    //verifies if there are any trip requests for this user and adds their details to a list
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    User? user = FirebaseAuth.instance.currentUser;
    String requestId = "";
    String userIdRequest = "";
    String userPhoneRequest = "";
    String userNameRequest = "";
    String userKeyRequest = "";
    String userEmailRequest = "";
    request = [];
    Request requestLocal = Request("", [], [],"");
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
          Plan localPlan = Plan("", "" ,"","",false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,"");
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
              userKeyRequest = userLocal.key.toString();
              userEmailRequest = userLocal.child("email").value!.toString();
            }
          }
          localPlan.days = planLocal.child("days").toString();
          localPlan.date = planLocal.child("date").toString();
          localPlan.budget = planLocal.child("budget").toString();
          if (planLocal.child("isBeach").toString() == "true") {
            localPlan.isSwimming = true;
          }
          if (planLocal.child("isCity").toString() == "true") {
            localPlan.isBigCity = true;
          }

          if (planLocal.child("isNightlife").toString() == "true") {
            localPlan.isNightlife = true;
          }
          if (planLocal.child("isHistorical").toString() == "true") {
            localPlan.isHistoricalHeritage = true;
          }
          if (planLocal.child("isNature").toString() == "true") {
            localPlan.isNature = true;
          }
          if (planLocal.child("isSki").toString() == "true") {
            localPlan.isSkiing = true;
          }
          if (planLocal.child("isTropical").toString() == "true") {
            localPlan.isTropical = true;
          }
          if(planLocal.child("isUnique").value!.toString()=="true") {
            localPlan.isUnique = true;
          }
          if(planLocal.child("isPopular").value!.toString()=="true") {
            localPlan.isPopular = true;
          }
          if(planLocal.child("isLuxury").value!.toString()=="true") {
            localPlan.isLuxury = true;
          }
          if(planLocal.child("isCruises").value!.toString()=="true") {
            localPlan.isCruises = true;
          }
          if(planLocal.child("isRomantic").value!.toString()=="true") {
            localPlan.isRomantic = true;
          }
          if(planLocal.child("isThermalSpa").value!.toString()=="true") {
            localPlan.isThermalSpa = true;
          }
          if(planLocal.child("isAdventure").value!.toString()=="true") {
            localPlan.isAdventure = true;
          }
          if(planLocal.child("isRelaxing").value!.toString()=="true") {
            localPlan.isRelaxing = true;
          }
          requestLocal.setPlan(localPlan);
          UserClass user = UserClass(userKeyRequest,userNameRequest,userEmailRequest,userPhoneRequest);
          requestLocal.user.add(user);
          request.add(requestLocal);
        }
      }
    } catch (error) {
      log(error.toString());
    }
    return request;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const PageHeading( title: "Notifications",),
        ),
        body: FutureBuilder<void>(
          future: _setRequestDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return ListView(
                children: <Widget>[
                  const SizedBox(height: 20,),
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
                              Container(
                                color: const Color(0xffdbe8e8),
                             height: 50,
                             child: Row(
                                children: [
                              Text(request[index].user[0].name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 20,
                                  fontFamily: 'NotoSerif'),),
                              const Text(" is inviting you on a trip", style: TextStyle(color: Colors.black,fontSize: 20,
                                  fontFamily: 'NotoSerif')),
                          ],
                              )
                              )

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
