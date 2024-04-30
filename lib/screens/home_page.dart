import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/auth.dart';
import 'package:myjorurney/navigate.dart';
import 'package:myjorurney/screens/country_page.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:myjorurney/screens/plan-trip_page.dart';
import '../data/globals.dart';
import 'add-friend_page.dart';
import 'notification_page.dart';

class HomePage extends StatefulWidget {
   const HomePage({super.key});
   @override
   State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  int notificationNumber = 0;
  Future<void> signOut() async {
    await Auth().signOut();
  }
  Widget _title() {
    return const Text('My Journey');
  }


  Widget _signOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextButton(
            onPressed: signOut,
            style: OutlinedButton.styleFrom(
                side: BorderSide.none
            ),
            child: const Text('Sign Out')
        )
    );
  }
  Future<int> _isRequest() async{
    //verifies if there are any trip requests for this user and returns their number
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    User? user = FirebaseAuth.instance.currentUser;
    int notificationNumber = 0;
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var plan_local in snapshot.children) {
        if (plan_local
            .child("userId")
            .value!
            .toString() == user?.uid
            && plan_local
            .child("budget")
            .value!
            .toString().isEmpty) {
          notificationNumber++;
        }
        print(plan_local.child("budget").value!.toString());
      }
    } catch (error) {
      print("Error at searching requests");
    }
    return notificationNumber;
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
  void setNotificationNumber() async{
    notificationNumber =  await _isRequest();
  }
  Widget _notification(){
    setNotificationNumber();
    if(notificationNumber>0) {
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
            if(notificationNumber==1)
              Text('$notificationNumber notification')
            else
              Text('$notificationNumber notifications')
          ],
        ),
      );
    }
    else{
      return const Text(" ");
    }
  }
  Widget _planButton(){
    return ElevatedButton(
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
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Add friends'),
          content: const Text('Do you want to go with a friend?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>  setState(() {
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
              onPressed: () =>  setState(() {
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
      child: const Text('Plan a trip'),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavMenu(),
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
          _notification(),
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
                    ).toMap(),
                    callback: (id, name, tapDetails) {
                      print(id);
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
              _beenButton(),
              _planButton()
            ],
          ),
        ],
      ),
    );
  }
}