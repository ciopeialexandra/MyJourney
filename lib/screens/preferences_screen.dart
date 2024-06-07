import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/plan-result_page.dart';
import 'package:uuid/uuid.dart';

import '../data/globals.dart';
import 'home_page.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  List<Contact> contacts = [];
  bool isPressedBeach = false;
  bool isPressedMountain = false;
  bool isPressedCity = false;
  bool isPressedAttractions = false;
  bool isPressedShopping = false;
  bool isPressedNature = false;
  bool isPressedTropical = false;
  String requestId = "";
  bool isRequestFinished = false;
  bool isPressedNightlife = false;
  bool isPressedUnique = false;
  bool isPressedPopular = false;
  bool isPressedLuxury = false;
  bool isPressedCruises = false;
  bool isPressedRomantic = false;
  bool isPressedThermalSpa = false;
  bool isPressedAdventure = false;
  bool isPressedRelaxing = false;
  bool isPressedGroupTravel = false;
  bool isPressedSoloTravel = false;

  @override
  void initState() {
    super.initState();
    getAllContacts();
  }
  getAllContacts() async {
    List<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      contacts = contacts;
    });
  }
  void _updatePlan() async{
    requestUpdateNeeded = true;
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    String? idUpdate = "";
    //String planId = request[requestIndex].plan
    final postData = {
      "userId": userId,
      "budget": plan.getPlanBudget(),
      "departure": plan.getPlanTown(),
      "date": plan.getPlanDate(),
      "days": plan.getPlanDays(),
      "isSki": plan.getPlanSki(),
      "isCity": plan.getPlanCity(),
      "isHistorical": plan.getPlanHistorical(),
      "isBeach": plan.getPlanSwim(),
      "isNightlife": plan.getPlanNightlife(),
      "isNature": plan.getPlanNature(),
      "isSwim": plan.getPlanSwim(),
      "isTropical": plan.getPlanTropical(),
      "isShopping": plan.getPlanShopping(),
      "isUnique": plan.getPlanUnique(),
      "isPopular": plan.getPlanPopular(),
      "isLuxury": plan.getPlanLuxury(),
      "isCruises": plan.getPlanCruises(),
      "isRomantic": plan.getPlanRomantic(),
      "isThermalSpa": plan.getPlanThermalSpa(),
      "isAdventure": plan.getPlanAdventure(),
      "isRelaxing": plan.getPlanRelaxing(),
      "requestId": request[requestIndex].key,
      "voted": "no"
    };
    final Map<String, Map> updates = {};
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var planLocal in snapshot.children) {
        if (planLocal
            .child("userId")
            .value!
            .toString() == userId
            && request[requestIndex].key == planLocal.child("requestId").value!.toString()) {
          idUpdate = planLocal.key;
        }
      }
    }catch (error) {
      log(error.toString());
    }
    if(idUpdate != "") {
      updates["plan/$idUpdate"] = postData;
      return FirebaseDatabase.instance.ref().update(updates);
    }
  }
  void _createPlan() async{
    var uuid = const Uuid().v1();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("plan/$uuid");
    _createRequest();
    await ref.set({
      "userId": userId,
      "budget": plan.getPlanBudget(),
      "date": plan.getPlanDate(),
      "days": plan.getPlanDays(),
      "departure": plan.getPlanTown(),
      "isSki": plan.getPlanSki(),
      "isCity": plan.getPlanCity(),
      "isHistorical": plan.getPlanHistorical(),
      "isBeach": plan.getPlanSwim(),
      "isNature": plan.getPlanNature(),
      "isSwim": plan.getPlanSwim(),
      "isTropical": plan.getPlanTropical(),
      "isShopping": plan.getPlanShopping(),
      "isNightlife": plan.getPlanNightlife(),
      "isUnique": plan.getPlanUnique(),
      "isPopular": plan.getPlanPopular(),
      "isLuxury": plan.getPlanLuxury(),
      "isCruises": plan.getPlanCruises(),
      "isRomantic": plan.getPlanRomantic(),
      "isThermalSpa": plan.getPlanThermalSpa(),
      "isAdventure": plan.getPlanAdventure(),
      "isRelaxing": plan.getPlanRelaxing(),
      "requestId": requestId,
      "voted": "no"
    });
    contacts = await ContactsService.getContacts();
    for(int i=0;i<contacts.length;i++){
      if(isSelected[i]==true){
        _createPlanContact(contacts[i].phones!.elementAt(0).value.toString());
      }
    }
  }
  void _createPlanSoloTrip() async{
    var uuid = const Uuid().v1();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("plan/$uuid");
    _createRequest();
    globalRequestIdSoloTrip = requestId;
    await ref.set({
      "userId": userId,
      "budget": plan.getPlanBudget(),
      "date": plan.getPlanDate(),
      "days": plan.getPlanDays(),
      "departure": plan.getPlanTown(),
      "isSki": plan.getPlanSki(),
      "isCity": plan.getPlanCity(),
      "isHistorical": plan.getPlanHistorical(),
      "isBeach": plan.getPlanSwim(),
      "isNature": plan.getPlanNature(),
      "isSwim": plan.getPlanSwim(),
      "isTropical": plan.getPlanTropical(),
      "isShopping": plan.getPlanShopping(),
      "isNightlife": plan.getPlanNightlife(),
      "isUnique": plan.getPlanUnique(),
      "isPopular": plan.getPlanPopular(),
      "isLuxury": plan.getPlanLuxury(),
      "isCruises": plan.getPlanCruises(),
      "isRomantic": plan.getPlanRomantic(),
      "isThermalSpa": plan.getPlanThermalSpa(),
      "isAdventure": plan.getPlanAdventure(),
      "isRelaxing": plan.getPlanRelaxing(),
      "requestId": requestId,
      "voted": "yes"
    });
  }
  Future<String?> getUserIdByPhoneNumber(String phoneNumber) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshot = await ref.child('user').get();
      for (var phoneLocal in snapshot.children) {
        String userPhoneNumber = phoneLocal.child("telephone").value!.toString(); // Get the value of userId
        if (userPhoneNumber == phoneNumber) {
          return phoneLocal.key;
        }
      }
    } catch (error) {
      return "No user found with this phone number";
    }
    return null;
  }
  void _createPlanContact(String phoneNumber) async{
    String? userId = await getUserIdByPhoneNumber(phoneNumber);
    var uuid = const Uuid().v1();
    DatabaseReference ref = FirebaseDatabase.instance.ref("plan/$uuid");
    await ref.set({
      "userId": userId,
      "budget": "",
      "departure": "",
      "date": "",
      "days": "",
      "isSki": false,
      "isCity": false,
      "isHistorical": false,
      "isBeach": false,
      "isNature": false,
      "isSwim": false,
      "isTropical": false,
      "isShopping": false,
      "isNightlife": false,
      "isUnique": false,
      "isPopular": false,
      "isLuxury": false,
      "isCruises": false,
      "isRomantic": false,
      "isThermalSpa": false,
      "isAdventure": false,
      "isRelaxing": false,
      "isGroupTravel": false,
      "isSoloTravel": false,
      "requestId": requestId,
      "voted": "no"

    });
  }
  void _createRequest() async{
    var uuid = const Uuid().v1();
    requestId = uuid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("request/$uuid");
    await ref.set({
      "status": "pending"

    });
  }
  Future<bool> verifyIsRequestFinished() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var planLocal in snapshot.children) {
        if (planLocal
            .child("requestId")
            .value!
            .toString() == request[requestIndex].key
            && planLocal
                .child("budget")
                .value!
                .toString()!="") {
          return false;
        }
      }
    } catch (error) {
      log("Error at searching requests");
    }
    return true;
  }
  void waitVerifyRequestFinished() async{
    isRequestFinished = await verifyIsRequestFinished();
  }
  Widget _nextButton() {
    if (isPressedAttractions||isPressedShopping||isPressedCity||isPressedMountain||isPressedBeach
    ||isPressedNature||isPressedTropical) {
      plan.setPlanHistorical(isPressedAttractions);
      plan.setPlanShopping(isPressedShopping);
      plan.setPlanCity(isPressedCity);
      plan.setPlanSki(isPressedMountain);
      plan.setPlanSwim(isPressedBeach);
      plan.setPlanNature(isPressedNature);
      plan.setPlanTropical(isPressedTropical);
      plan.setPlanNightlife(isPressedNightlife);
      plan.setPlanUnique(isPressedUnique);
      plan.setPlanPopular(isPressedPopular);
      plan.setPlanLuxury(isPressedLuxury);
      plan.setPlanCruises(isPressedCruises);
      plan.setPlanRomantic(isPressedRomantic);
      plan.setPlanThermalSpa(isPressedThermalSpa);
      plan.setPlanAdventure(isPressedAdventure);
      plan.setPlanRelaxing(isPressedRelaxing);
    }
    return ElevatedButton(
        onPressed: () =>
            setState(() {
              if(isPlanRequest == false && isFriendsTrip == false) {
                _createPlanSoloTrip();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const ChatScreen(),
                  ),
                );
              }
              if(isPlanRequest == true && isFriendsTrip==false){
                _updatePlan();
                waitVerifyRequestFinished();
                // if(isRequestFinished) {
                //   resultUpdated = false;
                //  _updateRequest();
                //   showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return requestFinished(context);
                //       }
                //   );
                // }
                // else{
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return requestPending(context);
                    }
                );
                //}
              }
              else if(isFriendsTrip == true){
                _createPlan();
                // Show the AlertDialog
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return requestSend(context);
                    }
                );
              }
            }
            ),

        child: const Text("Continue", style:  TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSerif',
          color: Color(0xff036d81)
        ),)
    );
  }
  Widget _text(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSerif',
            color:Color(0xff036d81)
        ),
      ),
    );
  }
  Widget requestPending(BuildContext context) {
    return AlertDialog(
      title: const Text('Preferences saved'),
      content: const Text("Call your friends and tell them to hurry up."),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const HomePage(),
                  )
              );
            }
            );
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
  Widget requestSend(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Sent'),
      content: const Text('The request has been sent to your friends.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const HomePage(),
                  )
              );
            }
            );
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
  Widget requestFinished(BuildContext context) {
    return AlertDialog(
      title: const Text('Your trip preferences are saved'),
      content: const Text('All your friends details are completed, choose your destination.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const HomePage(),
                  )
              );
            }
            );
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
  Widget _tropicalButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedTropical = !isPressedTropical;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedTropical ? const Color(0xffdbe8e8) : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sunny,color: Color(0xffff7c00),),
          // Adjust the spacing between icon and text as needed
          Text('Tropical',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _shoppingButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedShopping = !isPressedShopping;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedShopping ? const Color(0xffdbe8e8) : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined,color: Color(0xffbd00b8),),
          // Adjust the spacing between icon and text as needed
          Text(' Shopping',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _attractionsButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedAttractions = !isPressedAttractions;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedAttractions ? const Color(0xffdbe8e8) : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.castle_sharp,color: Color(0xff965b02),),
          // Adjust the spacing between icon and text as needed
          Text(' Historic Sites',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _natureButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedNature = !isPressedNature;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedNature ? const Color(0xffdbe8e8) : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forest,color: Color(0xff06a00e),),
          // Adjust the spacing between icon and text as needed
          Text(' Parks',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }

  Widget _beachButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedBeach = !isPressedBeach;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedBeach ? const Color(0xffdbe8e8) : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.beach_access,color: Color(0xfff7cd0d),),
          // Adjust the spacing between icon and text as needed
          Text(' Beach',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _luxuryButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedLuxury = !isPressedLuxury;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedLuxury ? const Color(0xffdbe8e8) : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star,color: Color(0xfff5de75),),
          // Adjust the spacing between icon and text as needed
          Text(' Luxury',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _romanticButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedRomantic = !isPressedRomantic;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedRomantic ? const Color(0xffdbe8e8) : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_sharp,color: Color(0xffff2828),),
          // Adjust the spacing between icon and text as needed
          Text(' Romantic',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _thermalButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedThermalSpa = !isPressedThermalSpa;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedThermalSpa ? const Color(0xffdbe8e8) : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.spa,color: Color(0xff1a6f36),),
          // Adjust the spacing between icon and text as needed
          Text(' Thermal Spa',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _nightlifeButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedNightlife = !isPressedNightlife;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedNightlife ? const Color(0xffdbe8e8) : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.nightlight,color: Color(0xff989898),),
          // Adjust the spacing between icon and text as needed
          Text(' Nightlife',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }

  Widget _mountainButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedMountain = !isPressedMountain;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedMountain ? const Color(0xffdbe8e8) : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.downhill_skiing,color: Color(0xff00d5ea),),
          // Adjust the spacing between icon and text as needed
          Text(' Mountain',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _cruiseButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedCruises = !isPressedCruises;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedCruises ? const Color(0xffdbe8e8) : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_boat,color: Color(0xff0091de),),
          // Adjust the spacing between icon and text as needed
          Text(' Cruises', style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _uniqueButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedUnique = !isPressedUnique;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedUnique ? const Color(0xffdbe8e8) : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.airplanemode_active_sharp,color: Color(0xff0a0096),),
          // Adjust the spacing between icon and text as needed
          Text(' Unique',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _adventureButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedAdventure = !isPressedAdventure;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedAdventure ? const Color(0xffdbe8e8) : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hiking,color: Color(0xff6b04a8),),
          // Adjust the spacing between icon and text as needed
          Text(' Adventure',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _relaxingButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedRelaxing = !isPressedRelaxing;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedRelaxing ? const Color(0xffdbe8e8) : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hotel,color: Color(0xffa84704),),
          // Adjust the spacing between icon and text as needed
          Text(' Relaxing',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
            color: Color(0xff036d81)
          ),),
        ],
      ),
    );
  }
  Widget _popularButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedPopular = !isPressedPopular;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedPopular ? const Color(0xffdbe8e8) : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_sharp,color: Color(0xffbb1500),),
          // Adjust the spacing between icon and text as needed
          Text(' Popular',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
      ),
    );
  }
  Widget _cityButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedCity = !isPressedCity;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedCity ? const Color(0xffdbe8e8) : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_city,color: Color(0xff2d0505),),
          // Adjust the spacing between icon and text as needed
          Text(' Big City',style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
              color: Color(0xff036d81))),
        ],
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
        backgroundColor: const Color(0xffdbe8e8),
      ),
      body: Expanded(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20),),
          ),
          child: SingleChildScrollView(
            child: Column(
                children: [

                  Align(
                  alignment: Alignment.topLeft,
               child:_text('Filters'),
                  ),
                const SizedBox(height: 60,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                _beachButton(),
                _mountainButton(),
                    _natureButton(),
            ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _attractionsButton(),
                    _cityButton(),
                  ],
                ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tropicalButton(),
                _shoppingButton(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _nightlifeButton(),
                _uniqueButton(),
                ],
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _popularButton(),
                _luxuryButton(),
                _cruiseButton()
              ]
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _romanticButton(),
                _thermalButton()

              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  _adventureButton(),
                _relaxingButton(),
              ]
            ),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // _grouptravelButton(),
                        // _solotravelButton(),
                      ]
                  ),
              const SizedBox(height: 200,),
              Align(
                alignment: Alignment.bottomRight,
                child: _nextButton(),
            )
                ],
              ),
            ),
          ),
        ),
      );
  }
}
