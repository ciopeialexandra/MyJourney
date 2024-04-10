import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../data/globals.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}
Widget _title(){
  return const Text("My Journey");
}
Widget _animatedText(){
  return DefaultTextStyle(
    style: const TextStyle(
        fontSize: 20.0,
        color: Colors.black
    ),
    child: AnimatedTextKit(
      animatedTexts : [
        TyperAnimatedText('Your saved recommendations'),
      ],
      isRepeatingAnimation: false,
    ),
  );
}
class _FavouritePageState extends State<FavouritePage> {
  late Future<void> _planDetailsFuture;

  @override
  void initState() {
    super.initState();
    _planDetailsFuture = getPlanDetails();
  }

  Future<void> getPlanDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var plan_local in snapshot.children) {
        String userId = plan_local.child("userId").value!.toString(); // Get the value of userId
        if (user?.uid == userId) {
          setState(() {
            plans.add(plan_local.child("result").value.toString());
          });
          print(plan_local.child("result").value.toString());
        }
      }
    } catch (error) {
      print("Error fetching plan details: $error");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: FutureBuilder<void>(
        future: _planDetailsFuture,
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
                  itemCount: plans.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plans[index]),
                            Text('Option $index'),
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
      ),
    );
  }
}


