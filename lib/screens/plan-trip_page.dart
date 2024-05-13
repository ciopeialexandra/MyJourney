import 'dart:async';
import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/plan-result_page.dart';
import 'package:uuid/uuid.dart';
import '../data/globals.dart';
import 'home_page.dart';

class PlanTripPage extends StatefulWidget {
  const PlanTripPage({super.key});

  @override
  State<PlanTripPage> createState() => _PlanTripPageState();
}
class _PlanTripPageState extends State<PlanTripPage> {
  late ScrollController _listScrollController;
  List<User> data = List.empty();
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  TextEditingController departureController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  DateTime? startDate;
  DateTime? endDate;
  bool isPressedBeach = false;
  bool isPressedMountain = false;
  bool isPressedCity = false;
  bool isPressedAttractions = false;
  bool isPressedShopping = false;
  bool isPressedNature = false;
  bool isPressedTropical = false;
  bool isPressedThree = false;
  bool isPressedSeven = false;
  bool isPressedTen = false;
  String requestId = "";
  bool resultDisplayed = false;
  String img = "";
  bool isRequestFinished = false;
  bool resultUpdated = true;
  String result = "";

  @override
  void initState() {
    super.initState();
    getAllContacts();
    searchController.addListener(() {
      filterContacts();
    });
  }

  filterContacts() {
    List<Contact> contacts = [];
    contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String contactName = contact.displayName!.toLowerCase();
        return contactName.contains(searchTerm);
      });
      setState(() {
        contactsFiltered = contacts;
      });
    }
  }

  getAllContacts() async {
    List<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      contacts = contacts;
    });
  }

  Widget _animatedText() {
    return const DefaultTextStyle(
      style: TextStyle(
          fontSize: 40.0,
          color: Colors.black26
      ),
      child: Text('Complete your trip details'),
    );
  }

  Widget _title() {
    return const Text("My Journey");
  }

  Widget _text(String text) {
    return DefaultTextStyle(
      style: const TextStyle(
          fontSize: 20.0,
          color: Colors.black26
      ),
      child: Text(text),
    );
  }

  Widget _entryFieldNumber(String title,
      TextEditingController controller) {
    return TextField(
      keyboardType: TextInputType.number,
      controller: controller,
      decoration: InputDecoration(
          labelText: title
      ),
    );
  }

  Widget _entryFieldText(String title,
      TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: title
      ),
    );
  }
  void _createPlanContact(String phoneNumber) async{
    String? userId = await getUserIdByPhoneNumber(phoneNumber);
    //aici trebuie verificat userId sa fie corect
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
      "requestId": requestId,
      "voted": "no"

    });
  }
  void _createRequest() async{
    var uuid = const Uuid().v1();
    requestId = uuid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("request/$uuid");
    await ref.set({
      "finalResult": "",
      "status": "pending"

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
  void _createPlan() async{
    var uuid = const Uuid().v1();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("plan/$uuid");
    String days = "";
    if(plan.isTen == true){
      days = "10";
    }
    else if(plan.isSeven == true){
      days = "7";
    }
    else if(plan.isThree == true){
      days = "3";
    }
    _createRequest();
    await ref.set({
      "userId": userId,
      "budget": plan.getPlanBudget(),
      "date": plan.getPlanDate(),
      "days": days,
      "departure": plan.getPlanTown(),
      "isSki": plan.getPlanSki(),
      "isCity": plan.getPlanCity(), //de adaugat verificari sa nu fie niciuna goala
      "isHistorical": plan.getPlanHistorical(),
      "isBeach": plan.getPlanSwim(),
      "isNature": plan.getPlanNature(),
      "isSwim": plan.getPlanSwim(),
      "isTropical": plan.getPlanTropical(),
      "isShopping": plan.getPlanShopping(),
      "requestId": requestId,
      "voted": "no"
    });
    contacts = await ContactsService.getContacts();
    print(contacts.length);
    for(int i=0;i<contacts.length;i++){
      if(isSelected[i]==true){
        _createPlanContact(contacts[i].phones!.elementAt(0).value.toString());
      }
    }
  }
  Widget _nextButton() {
    if (_selectedDateRange != null) {
      plan.setPlanBudget(budgetController.text);
      plan.setPlanTown(departureController.text);
      plan.setPlanDate(_selectedDateRange!.toString());
      plan.setPlanHistorical(isPressedAttractions);
      plan.setPlanShopping(isPressedShopping);
      plan.setPlanCity(isPressedCity);
      plan.setPlanSki(isPressedMountain);
      plan.setPlanSwim(isPressedBeach);
      plan.setPlanNature(isPressedNature);
      plan.setPlanTropical(isPressedTropical);
      plan.setPlanThree(isPressedThree);
      plan.setPlanSeven(isPressedSeven);
      plan.setPlanTen(isPressedTen);
    }
    return TextButton(
        onPressed: () =>
            setState(() {
              if(isPlanRequest == false && isFriendsTrip == false) {
                _createPlan();
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
                if(isRequestFinished) {
                  resultUpdated = false;
                 _updateRequest();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return requestFinished(context);
                      }
                  );
                }
                else{
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return requestPending(context);
                      }
                  );
                }
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
        child: const Text('Continue')
    );
  }
  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }
  void _updatePlan() async{
    requestUpdateNeeded = true;
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    String days = "";
    String? idUpdate = "";
    if(plan.isTen == true){
      days = "10";
    }
    else if(plan.isSeven == true){
      days = "7";
    }
    else if(plan.isThree == true){
      days = "3";
    }
    //String planId = request[requestIndex].plan
    final postData = {
      "userId": userId,
      "budget": plan.getPlanBudget(),
      "departure": plan.getPlanTown(),
      "date": plan.getPlanDate(),
      "days": days,
      "isSki": plan.getPlanSki(),
      "isCity": plan.getPlanCity(),
      "isHistorical": plan.getPlanHistorical(),
      "isBeach": plan.getPlanSwim(),
      "isNature": plan.getPlanNature(),
      "isSwim": plan.getPlanSwim(),
      "isTropical": plan.getPlanTropical(),
      "isShopping": plan.getPlanShopping(),
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
  void _updateRequest() async{
    final postData = {
      "finalResult": "",
      "status": "completed"
    };
    final Map<String, Map> updates = {};
    String key = request[requestIndex].key;
      updates["request/$key"] = postData;
      return FirebaseDatabase.instance.ref().update(updates);
    }
  Widget requestSend(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Send'),
      content: const Text('The request has been sent to your friends'),
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
      content: const Text('All your friends details are completed, choose your destination'),
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
  Widget requestPending(BuildContext context) {
    return AlertDialog(
      title: const Text('Your trip preferences are saved'),
      content: const Text("Not all your friends completed the trip details, you will get a notification when it's time to choose your destination"),
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
  Widget _dateButton() {
    return ElevatedButton(
      onPressed: _show,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range),
          // Adjust the spacing between icon and text as needed
          Text('Pick a date'),
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
          backgroundColor: isPressedBeach ? Colors.purpleAccent : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.beach_access),
          // Adjust the spacing between icon and text as needed
          Text('Beach'),
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
          backgroundColor: isPressedMountain ? Colors.purpleAccent : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.downhill_skiing),
          // Adjust the spacing between icon and text as needed
          Text('Mountain'),
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
          backgroundColor: isPressedCity ? Colors.purpleAccent : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_city),
          // Adjust the spacing between icon and text as needed
          Text('Big City'),
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
          backgroundColor: isPressedNature ? Colors.purpleAccent : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forest),
          // Adjust the spacing between icon and text as needed
          Text('Nature'),
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
          backgroundColor: isPressedAttractions ? Colors.purpleAccent : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.castle_sharp),
          // Adjust the spacing between icon and text as needed
          Text('Historical'),
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
          backgroundColor: isPressedShopping ? Colors.purpleAccent : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined),
          // Adjust the spacing between icon and text as needed
          Text('Shopping'),
        ],
      ),
    );
  }
  Widget _threeButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedThree = !isPressedThree;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedThree ? Colors.purpleAccent : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Adjust the spacing between icon and text as needed
          Text('3 days'),
        ],
      ),
    );
  }
  Widget _sevenButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedSeven = !isPressedSeven;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedSeven ? Colors.purpleAccent : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Adjust the spacing between icon and text as needed
          Text('7 days'),
        ],
      ),
    );
  }
  Widget _tenButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressedTen = !isPressedTen;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedTen ? Colors.purpleAccent : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Adjust the spacing between icon and text as needed
          Text('10 days'),
        ],
      ),
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
          backgroundColor: isPressedTropical ? Colors.purpleAccent : Colors
              .white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sunny),
          // Adjust the spacing between icon and text as needed
          Text('Tropical'),
        ],
      ),
    );
  }

  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );
    if (result != null) {
      setState(() {
        _selectedDateRange = result;
        startDate = _selectedDateRange?.start;
        endDate = _selectedDateRange?.end;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            _animatedText(),
            const SizedBox(height: 20),
            _entryFieldNumber("Your budget", budgetController),
            const SizedBox(height: 20),
            _entryFieldText("Place of departure", departureController),
            const SizedBox(height: 30),
            _dateButton(),
            const SizedBox(height: 20),
            _text('What would you like?'),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                _beachButton(),
                _mountainButton(),
                _cityButton()
              ],
            ),
        Row(
          children: <Widget>[
            _attractionsButton(),
            _natureButton(),
            ],
        ),
            Row(
              children: <Widget>[
                _tropicalButton(),
                _shoppingButton(),
              ],
            ),
            const SizedBox(height: 20),
            _text("How many days?"),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                _threeButton(),
                _sevenButton(),
                _tenButton(),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: _nextButton(),
              ),
            ),
          ],
        ),
      ),
    );
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
}
