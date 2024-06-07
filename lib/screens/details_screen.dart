import 'package:flutter/material.dart';

import '../auth.dart';
import '../data/globals.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key,});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final GlobalKey keyFirstScreen = GlobalKey();
  final GlobalKey keyItineraryScreen = GlobalKey();
  final GlobalKey keyBudgetSpendingScreen = GlobalKey();
  Widget _title() {
    return const Text('My Journey');
  }

  Widget _textButton(String text, GlobalKey key) {
    return ElevatedButton(
        onPressed: () {
          Scrollable.ensureVisible(key.currentContext!);
        },
        child: Text(text, style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSerif',
            color: Colors.black
        ),)
    );
  }

  Future<void> signOut() async {
    await Auth().signOut();
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

  @override
  Widget build(BuildContext context) {
    if(globalItinerary.contains("Itinerary:")) {
      globalItinerary = globalItinerary.substring(10).trim();
    }
    return Scaffold(
        appBar: AppBar(
          title: _title(),
          actions: [
            _signOutButton(),
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    key: keyFirstScreen,
                    height: MediaQuery.of(context).size.height - kToolbarHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(globalCurrentTripImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          colors: [
                            Colors.black.withOpacity(0.9),
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              globalCurrentCityAndCountry,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Text(
                            //   globalItinerary,
                            //   style: const TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 18,
                            //   ),
                            // ),
                            const SizedBox(height: 50),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _textButton("Itinerary", keyItineraryScreen),
                                   _textButton("Budget spending", keyBudgetSpendingScreen)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                      color: Colors.white,
                      key: keyItineraryScreen,
                      height: MediaQuery.of(context).size.height - kToolbarHeight,
                      child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  globalItinerary,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                              ]
                          )
                      )
                  )
                ]
            )
        )
    );
  }
}