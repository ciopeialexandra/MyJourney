import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/auth.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:myjorurney/screens/details_screen.dart';
import 'package:myjorurney/screens/plan-trip_page.dart';
import '../data/globals.dart';
import '../data/plan.dart';
import '../data/request.dart';
import '../data/result.dart';
import '../data/user.dart';
import 'add-friend_page.dart';
import 'choose-trip_page.dart';

class HomePage extends StatefulWidget {
   const HomePage({super.key});
   @override
   State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  int notificationNumber = 0;
  int numberOfRequests = 0;
  int currentPageIndex = 0;
  late Future<bool> areResultsGeneratedFuture;
  List<Result> favouriteResultList = List.empty(growable: true);
  late Future<int> areFavouritesFound;

  @override
  void initState() {
    super.initState();
    favouriteResultList = List.empty(growable: true);
    areResultsGeneratedFuture = _areResultsAlreadyGenerated();
    areFavouritesFound = _isFavourite();
    twoUsersTripTrace.start();
    //soloTripTrace.start();
  }
  Future<bool> _areResultsAlreadyGenerated() async {
    //verifies if there are results already generated

// Code you want to trace
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    try {
      DataSnapshot snapshotResult = await ref.child('result').get();
      for (var resultLocal in snapshotResult.children) {
        if (resultLocal
            .child("requestId")
            .value!
            .toString() == globalRequest.key
        ) {
          return true;
        }
      }

    } catch (error) {
      log("Error at searching ");
    }
    return false;
  }
  Future<void> signOut() async {
    await Auth().signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _title() {
    return const Text('TripSync');
  }


  Widget _signOutButton() {
    return TextButton(
      onPressed: () {
        signOut();
      },

      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.logout_outlined,
            size: 30.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Future<int> _isRequest() async {
    await FirebasePerformance.instance.isPerformanceCollectionEnabled();
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    User? user = FirebaseAuth.instance.currentUser;
    notificationNumber = 0;
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
                .toString()
                .isEmpty) {
          notificationNumber++;
          isPlanRequest = true;
        }
      }
    } catch (error) {
      log(error.toString());
    }
    return notificationNumber;
  }

  Future<int> _isFavourite() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    User? user = FirebaseAuth.instance.currentUser;
    String? resultId = "";
    bool isDuplicate = false;
    final storageRef = FirebaseStorage.instance.ref();
    int favouriteResultNumber = 0;
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var planLocal in snapshot.children) {
        if (planLocal.child("userId").value!.toString() == user?.uid
            && planLocal.child("voted").value!.toString() == "yes") {
          DataSnapshot snapshot = await ref.child('request').get();
          for (var requestLocal in snapshot.children) {
            if (requestLocal.child("status").value!.toString() == "completed") {
              String likes = "0";
              String requestId = requestLocal.key.toString();
              favouriteResultNumber++;
              DataSnapshot snapshot = await ref.child('result').get();
            Result result = Result("", "", "", "","","");
              for (var resultLocal in snapshot.children) {
                if(resultLocal.child("requestId").value.toString() == requestId) {
                  if(resultLocal.child("likes").value.toString().compareTo(likes)>0) {
                    resultId = resultLocal.key;
                    result = Result(resultLocal.child("image").value.toString(), resultLocal.child("itinerary").value.toString(),
                        resultLocal.child("cityAndCountry").value.toString(), resultId!,
                        resultLocal.child("budgetSpending").value.toString(),resultLocal.child("finalDate").value.toString());
                    likes = resultLocal.child("likes").value.toString();
                  }}}
              if(result.cityAndCountry.isNotEmpty) {
                isDuplicate = false;
                var imagePath = result.image;
                result.image =
                await storageRef.child("images/$imagePath.jpg").getDownloadURL();
                for(int i=0; i<favouriteResultList.length;i++) {
                  if (favouriteResultList[i].key.contains(result.key)) {isDuplicate = true;}
                }
                if(isDuplicate == false) {favouriteResultList.add(result);}
              }}}}}} catch (error) {log(error.toString());}
    return favouriteResultNumber;
  }

  Future<int> _areRequestDetailsCompleted() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    User? user = FirebaseAuth.instance.currentUser;
    int requestParticipants = 0;
    int requestDetailsCompletedNumber = 0;
    try {
      DataSnapshot snapshotPlan = await ref.child('plan').get();
      for (var planLocal in snapshotPlan.children) {
        if (planLocal.child("userId").value!.toString() ==
            user?.uid && planLocal.child("budget").value.toString().isNotEmpty &&
            planLocal.child("voted").value!.toString() == "no"
        ) {
          globalRequest.key = planLocal.child("requestId").value.toString();
           areResultsGeneratedGlobal = await _areResultsAlreadyGenerated();
          requestParticipants = 0;
          for (var planLocal in snapshotPlan.children) {
            if (planLocal.child("requestId").value!.toString() == globalRequest.key &&
                planLocal.child("budget").value.toString().isEmpty
            ) {
              return 0;
            }
            else if (planLocal.child("requestId").value!.toString() == globalRequest.key &&
                planLocal.child("budget").value.toString().isNotEmpty) {
              requestParticipants++;
            }
          }
          if (requestParticipants > 1) {
            requestDetailsCompletedNumber++;
          }
        }
      }
    } catch (error) {
      log("Error at searching requests");
    }
    numberOfRequests = requestDetailsCompletedNumber;
    if (requestDetailsCompletedNumber > 0) {
      return requestDetailsCompletedNumber;
    }
    return 0;
  }


  Widget _planButton() {
    Size size = MediaQuery.of(context).size;
    previousGeneratedResultsSoloTrip = "";
    return Container(
        width: size.width * 0.5,
        decoration: BoxDecoration(
        color: const Color(0xff05cece),
    borderRadius: BorderRadius.circular(26),
    ),
    child: TextButton(
      //     onPressed: () async {
      //       if(await Permission.contacts.request().isGranted) {
      //         setState(() {
      //           Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (context) =>
      //                   const PlanTripPage()));
      //         });
      //       }
      //       else{
      //       }
      //     },
      //     child: const Text('Plan a trip'),
      //   );
      //
      onPressed: () =>
          showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                  title: const Text('Plan your trip'),
                  content: const Text('Do you want to go alone?',style: TextStyle(color: Colors.black, fontSize: 18)),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () =>
                          setState(() {
                            isFriendsTrip = false;
                            isPlanRequest = false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const PlanTripPage(),
                                )
                            );
                          }),
                      child: const Text('Yes',style: TextStyle(color: Colors.black, fontSize: 14)),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() {
                            isPlanRequest = false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const AddFriendPage()));
                          }),
                      child:  const Text('No', style: TextStyle(color: Colors.black, fontSize: 14),),
                    ),
                  ],
                ),
          ),
      child: const Text("Plan a trip", style: TextStyle(color: Colors.black, fontSize: 18),),
    )
    );
  }

  Widget _requestAlert() {
    return AlertDialog(
      title: const Text('Choose your destination',style: TextStyle(color: Colors.black, fontSize: 18)),
      content: const Text(
          'Your friends completed the trip details.',style: TextStyle(color: Colors.black, fontSize: 14)),
      actions: <Widget>[
        TextButton(
          onPressed: () =>
              setState(() {
                isPlanRequest = false;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const ChooseTripPage()));
              }),
          child: const Text('Continue',style: TextStyle(color: Colors.black, fontSize: 14)),
        ),
      ],
    );
  }


  Future<List<Request>> _setRequestDetails() async{
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    User? user = FirebaseAuth.instance.currentUser;
    String requestId = "";String userIdRequest = "";String userPhoneRequest = "";String userNameRequest = "";
    String userKeyRequest = "";String userEmailRequest = "";request = [];
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
                .toString().isEmpty) {
          Plan localPlan = Plan("", "" ,"","",false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,"");
          requestId = planLocal.child("requestId").value!.toString();
          requestLocal.key = requestId;
          DataSnapshot requestPlan = await ref.child('plan').get();
          localPlan.setPlanKey(planLocal.key);
          for (var requestLocal in requestPlan.children) {
            if(requestLocal.child("requestId").value!.toString() == requestId&&requestLocal.key!=planLocal.key){
              userIdRequest = requestLocal.child("userId").value!.toString();
            }}
          DataSnapshot requestUser = await ref.child('user').get();
          for (var userLocal in requestUser.children) {
            if(userLocal.key == userIdRequest ){
              userPhoneRequest = userLocal.child("telephone").value!.toString();
              userNameRequest = userLocal.child("name").value!.toString();
              userKeyRequest = userLocal.key.toString();
              userEmailRequest = userLocal.child("email").value!.toString();
            }}
          setRequest(localPlan, planLocal, requestLocal, userKeyRequest, userNameRequest, userEmailRequest, userPhoneRequest);
        }}
    } catch (error) {
      log(error.toString());
    }
    return request;
  }

  void setRequest(Plan localPlan, DataSnapshot planLocal, Request requestLocal, String userKeyRequest, String userNameRequest, String userEmailRequest,
      String userPhoneRequest) {
      localPlan.days = planLocal.child("days").toString();
    localPlan.date = planLocal.child("date").toString();
    localPlan.budget = planLocal.child("budget").toString();
    if (planLocal.child("isBeach").toString() == "true") {localPlan.isSwimming = true;}
    if (planLocal.child("isCity").toString() == "true") {localPlan.isBigCity = true;}
    if (planLocal.child("isNightlife").toString() == "true") {localPlan.isNightlife = true;}
    if (planLocal.child("isHistorical").toString() == "true") {localPlan.isHistoricalHeritage = true;}
    if (planLocal.child("isNature").toString() == "true") {localPlan.isNature = true;}
    if (planLocal.child("isSki").toString() == "true") {localPlan.isSkiing = true;}
    if (planLocal.child("isTropical").toString() == "true") {localPlan.isTropical = true;}
    if(planLocal.child("isUnique").value!.toString()=="true") {localPlan.isUnique = true;}
    if(planLocal.child("isPopular").value!.toString()=="true") {localPlan.isPopular = true;}
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
  void navigateToPlan() {
    isPlanRequest = true;
    isFriendsTrip = false;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const PlanTripPage(),
      ),
    );
  }
  Widget itineraryButton() {
    return TextButton(
      onPressed: () {
        setState(() {
        });
      },
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.place,
            size: 25.0,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
  Card buildCard(String image,String itinerary, String cityAndCountry,String budgetSpending,String finalDate) {
      var heading = cityAndCountry;
      var cardImage = NetworkImage(
          image);
      //var supportingText =
      //    favouriteResultList[i].itinerary;
      return Card(
          elevation: 4.0,
          child: Column(
            children: [
              ListTile(
                title:    Row(
          mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align( alignment: Alignment.bottomLeft,child: itineraryButton(),),
              Align( alignment: Alignment.bottomLeft,child: Flexible(
                child: Text(heading),
              ),)
            ],
          ),
                //trailing: Icon(Icons.favorite_outline),
              ),
              SizedBox(
                height: 200.0,
                child: Ink.image(
                  image: cardImage,
                  fit: BoxFit.cover,
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.all(16.0),
              //   alignment: Alignment.centerLeft,
              //   child: Text(supportingText),
              // ),
              ButtonBar(
                children: [
                  TextButton(
                    child: const Text('See more', style: TextStyle(color: Color(0xff036d81)),),
                    onPressed: () {
                      globalCurrentTripImage = image;
                      globalCurrentCityAndCountry = cityAndCountry;
                      globalFinalDate = finalDate;
                      globalItinerary = itinerary;
                      globalBudgetSpending = budgetSpending;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const DetailsScreen(),
                        ),
                      );
                    },
                  )
                ],
              )
            ],
          ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        actions: [
          _signOutButton(),
        ],
      ),
      body: <Widget>[
        /// Home page
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<int>(
                future: _isRequest(),
                // a previously-obtained Future<String> or null
                builder: (BuildContext context,
                    AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData) {
                  }
                  return const Text("");
                }
            ),
            FutureBuilder<int>(
                future: _areRequestDetailsCompleted(),
                // a previously-obtained Future<String> or null
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData && numberOfRequests > 0) {
                    return Container(
                        child: _requestAlert()
                    );
                  }
                  return const Text("");
                }
            ),
            Expanded(
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.1,
                  maxScale: 2.0,
                  child: GestureDetector(
                    onTap: () {
                      // Handle tap on the map
                    },
                    child: SimpleMap(
                      instructions: SMapWorld.instructions,
                      defaultColor: Colors.grey,
                      colors: const SMapWorldColors(
                          uS: Colors.purple,
                          cN: Colors.pink,
                          iN: Colors.purple,
                          bF: Colors.yellowAccent,
                          aR: Colors.blueAccent,
                          nA: Colors.red,
                          bL: Colors.orange,
                          aO: Colors.orange,
                          aL: Colors.white,
                          rO: Colors.red,
                          rU: Colors.green,
                          aU: Colors.yellow,
                          aN: Colors.red,
                          eG: Colors.cyanAccent,
                          lI: Colors.red,
                          cA: Colors.blue,
                          tN: Colors.pinkAccent,
                          mA: Colors.lightGreen
                      ).toMap(),
                      callback: (id, name, tapDetails) {
                        log(id);
                      },
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _planButton()
              ],
            ),
            const SizedBox(height: 60,),
          ],
        ),

        /// Notifications page
        FutureBuilder<void>(
          future: _setRequestDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if(notificationNumber>0){
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
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.notifications_sharp),
                                  title: const Text('Notification '),
                                  subtitle: Text("${request[index].user[0].name} is inviting you on a trip"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),

                ],
              );
            }
            else{
              return Scaffold(
                body: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity, // Ensure the image container takes up full width
                          child: Image.asset(
                            'assets/images/not_found.webp',
                            fit: BoxFit.contain, // Ensure the entire image fits within the container
                          ),
                        ),
                        const SizedBox(height: 20), // Space between image and text
                        const Text(
                          "No notification found",
                          style:  TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'NotoSerif',
                          color: Colors.black,
                        ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
        /// Future trips page
        FutureBuilder<int>(
        future: _isFavourite(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if(favouriteResultList.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      for(int i=0;i<favouriteResultList.length;i++)
                       buildCard(favouriteResultList[i].image,favouriteResultList[i].itinerary,favouriteResultList[i].cityAndCountry,favouriteResultList[i].budgetSpending,favouriteResultList[i].finalDate),
                    ],
                  )),
            );
          }
          else{
            return Scaffold(
              body: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity, // Ensure the image container takes up full width
                        child: Image.asset(
                          'assets/images/not_found.webp',
                          fit: BoxFit.contain, // Ensure the entire image fits within the container
                        ),
                      ),
                      const SizedBox(height: 20), // Space between image and text
                      const Text(
                        "No future trips found",
                        style:  TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'NotoSerif',
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        }
        ),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        backgroundColor: const Color(0xffdbe8e8),
        indicatorColor: const Color(0xff05cece),
        //selectedIndex: currentPageIndex,
        destinations:  const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
             // label: Text((notificationNumber).toString()),
              child: Icon(Icons.notifications_sharp),
            ),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon:  Icon(Icons.luggage),
            label: 'Future trips',
          ),
        ],
      ),
    );
  }
}