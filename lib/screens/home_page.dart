import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/auth.dart';
import 'package:myjorurney/screens/country_page.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';

class HomePage extends StatefulWidget {
   const HomePage({super.key});
   @override
   State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('My Journey');
  }


  Widget _signOutButton() {
    return ElevatedButton(onPressed: signOut, child: const Text('Sign Out'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                child: _beenButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}