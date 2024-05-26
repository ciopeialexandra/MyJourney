import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/preferences_screen.dart';
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
  bool isPressedThree = false;
  bool isPressedSeven = false;
  bool isPressedTen = false;
  String requestId = "";
  bool resultDisplayed = false;
  String img = "";
  bool isRequestFinished = false;
  bool resultUpdated = true;
  String result = "";
  double _currentSliderValue = 1;
  final _preferencesFormKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
  }


  Widget _title() {
    return const Text("My Journey");
  }

  Widget _text(String text) {
    return DefaultTextStyle(
      style: const TextStyle(
          fontSize: 20.0,
          color: Colors.black
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
          labelText: title,
        labelStyle: const TextStyle(fontSize: 20.0 , color: Colors.black, fontStyle: FontStyle.normal)
      ),
    );
  }

  Widget _entryFieldText(String title,
      TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(
              fontSize: 20.0, color: Colors.black, fontStyle: FontStyle.normal)
      ),
    );
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
  Widget _nextButton() {
    if (_selectedDateRange != null) {
      plan.setPlanBudget(budgetController.text);
      plan.setPlanTown(departureController.text);
      plan.setPlanDate(_selectedDateRange!.toString());
      plan.setPlanDays(_currentSliderValue.toString());
    }
    return TextButton(
        onPressed: () =>
            setState(() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const PreferencesScreen(),
                              ),
                );
              }
            ),
        child: _text("Continue")
    );
  }
  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
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
  Widget _dateButton() {
    Size size = MediaQuery.of(context).size;
    return  Container(
        width: size.width * 0.8,
        decoration: BoxDecoration(
        color: const Color(0xffdbe8e8),
    borderRadius: BorderRadius.circular(26),
    ),
    child: TextButton(
      onPressed: _show,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range,color: Colors.black),
          // Adjust the spacing between icon and text as needed
          Text(' Available period',style: TextStyle(color: Colors.black, fontSize: 20),),
        ],
      ),
    )
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
            child: Form(
              key: _preferencesFormKey,
              child: Column(
                children: [
                  const SizedBox(height: 80,),
                  _entryFieldNumber("Your budget", budgetController),
                  const SizedBox(height: 60,),
                  _entryFieldText("Place of departure", departureController),
                  const SizedBox(height: 80,),
                  _dateButton(),
                  const SizedBox(height: 80,),
                  _text("Duration"),
                  const SizedBox(height: 20,),
                  Slider(
                    value: _currentSliderValue,
                    max: 21,
                    divisions: 21,
                    activeColor: const Color(0xff036d81),
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                  ),
                  const SizedBox(height: 100),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _nextButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
