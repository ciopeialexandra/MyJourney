import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/auth.dart';
import 'package:myjorurney/screens/country_page.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:myjorurney/screens/plan-trip_page.dart';
import '../common/custom_form_button.dart';
import '../data/globals.dart';
import 'add-friend_page.dart';
import 'choose-trip_page.dart';
import 'notification_page.dart';

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
  List<String> pages = ["Chat", "Search", "History", "Notification", "Profile"];
  late Future<bool> areResultsGeneratedFuture;

  @override
  void initState() {
    super.initState();
    areResultsGeneratedFuture = _areResultsAlreadyGenerated();
  }
  Future<bool> _areResultsAlreadyGenerated() async {
    //verifies if there are results already generated
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshotResult = await ref.child('result').get();
      for (var resultLocal in snapshotResult.children) {
        print(globalRequest.key);
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
  }

  Widget _title() {
    return const Text('My Journey');
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
    //verifies if there are any trip requests for this user and returns their number
    DatabaseReference ref = FirebaseDatabase.instance.reference();
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
        }
      }
    } catch (error) {
      log(error.toString());
    }
    return notificationNumber;
  }

  Future<int> _areRequestDetailsCompleted() async {
    //verifies if there are any trip requests for this user and returns their number
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    User? user = FirebaseAuth.instance.currentUser;
    int requestParticipants = 0;
    int requestDetailsCompletedNumber = 0;
    try {
      DataSnapshot snapshotPlan = await ref.child('plan').get();
      for (var planLocal in snapshotPlan.children) {
        if (planLocal
            .child("userId")
            .value!
            .toString() == user?.uid && planLocal
            .child("budget")
            .value
            .toString()
            .isNotEmpty &&
            planLocal
                .child("voted")
                .value!
                .toString() == "no"
        ) {
          globalRequest.key = planLocal
              .child("requestId")
              .value
              .toString();
           areResultsGeneratedGlobal = await _areResultsAlreadyGenerated();
          requestParticipants = 0;
          for (var planLocal in snapshotPlan.children) {
            if (planLocal
                .child("requestId")
                .value!
                .toString() == globalRequest.key && planLocal
                .child("budget")
                .value
                .toString()
                .isEmpty
            ) {
              return 0;
            }
            else if (planLocal
                .child("requestId")
                .value!
                .toString() == globalRequest.key && planLocal
                .child("budget")
                .value
                .toString()
                .isNotEmpty) {
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

  Widget _beenButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const TripPage()));
        });
      },
      child: const Text('Where have you been ?'),
    );
  }

  Widget _notification() {
    if (notificationNumber > 0) {
      return TextButton(
        onPressed: () {
          setState(() {
            isPlanRequest = true;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                    const NotificationPage()));
          });
        },

        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.notifications_active_outlined),
            // Adjust the spacing between icon and text as needed
            if(notificationNumber == 1)
              Text('$notificationNumber notification')
            else
              Text('$notificationNumber notifications')
          ],
        ),
      );
    }
    else {
      return const Text(" ");
    }
  }

  Widget _planButton() {
    Size size = MediaQuery.of(context).size;
    return Container(
        width: size.width * 0.8,
        decoration: BoxDecoration(
        color: const Color(0xffdbe8e8),
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
                  title: const Text('Add friends'),
                  content: const Text('Do you want to go with a friend?'),
                  actions: <Widget>[
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
                      child: const Text('Yes'),
                    ),
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
                      child: const Text('No'),
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
      title: const Text('Request completed'),
      content: const Text(
          'Your friends completed the trip details, choose your destination'),
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
          child: const Text('Continue'),
        ),
        TextButton(
          onPressed: () =>
              setState(() {
                isFriendsTrip = false;
                isPlanRequest = false;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const HomePage(),
                    )
                );
              }),
          child: const Text('Choose later'),
        ),
      ],
    );
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FutureBuilder<int>(
              future: _isRequest(),
              // a previously-obtained Future<String> or null
              builder: (BuildContext context,
                  AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  return Container(
                      child: _notification()
                  );
                }
                return const Text(" ");
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
        destinations:  <Widget>[
          const NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const NavigationDestination(
            icon:  Icon(Icons.airplanemode_active_sharp),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text(notificationNumber.toString()),
              child: const Icon(Icons.notifications_sharp),
            ),
            label: 'Notifications',
          ),
          const NavigationDestination(
            icon:  Icon(Icons.favorite_sharp),
            label: 'Favourites',
          ),
        ],
      ),
    );
  }
}