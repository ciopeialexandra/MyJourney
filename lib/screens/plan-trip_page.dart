import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/preferences_screen.dart';
import '../common/page_header.dart';
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
  double _currentSliderValue = 7;
  final _preferencesFormKey = GlobalKey<FormState>();
  bool validator = true;
  bool validatorBudget = true;
  bool validatorDays = true;


  @override
  void initState() {
    super.initState();
  }


  Widget _title() {
    return const Text("TripSync");
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
        icon: const Icon(Icons.euro),
          iconColor: Colors.green,
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
          icon: const Icon(Icons.airplanemode_active_sharp),
          iconColor: Colors.blue,
          labelStyle: const TextStyle(
              fontSize: 20.0, color: Colors.black, fontStyle: FontStyle.normal)
      ),
    );
  }
  Future<String?> getUserIdByPhoneNumber(String phoneNumber) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
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
    return ElevatedButton(
        onPressed: () =>
            setState(() {
              validator = true;
              validatorBudget = true;
              validatorBudget = true;
              if (_selectedDateRange != null&&departureController.text.isNotEmpty&&_currentSliderValue.toString().isNotEmpty&&budgetController.toString().isNotEmpty&&int.parse(budgetController.text) > 199 &&int.parse(budgetController.text)/_currentSliderValue >=50) {
                plan.setPlanBudget(budgetController.text);
                plan.setPlanTown(departureController.text);
                plan.setPlanDate(_selectedDateRange!.toString());
                plan.setPlanDays(_currentSliderValue.abs().toString());

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const PreferencesScreen(),
                  ),
                );
              }
              else{
                if(_selectedDateRange == null || departureController.text.isEmpty||_currentSliderValue.toString().isEmpty){
                  validator = false;
                }
               else if(int.parse(budgetController.text)/_currentSliderValue <50) {
                  validatorDays = false;
                }
               else{
                  validatorBudget = false;
                }
              }
              }
            ),
        child: const Text("Continue", style:  TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSerif',
            color: Color(0xff036d81)
        ),)
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
      title: const Text('Done',style: TextStyle(color: Colors.black, fontSize: 18)),
      content: const Text('The request has been sent',style: TextStyle(color: Colors.black, fontSize: 14)),
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
          child: const Text('Continue',style: TextStyle(color: Colors.black, fontSize: 14)),
        ),
      ],
    );
  }
  Widget _dateButton() {
    Size size = MediaQuery.of(context).size;
    return  SizedBox(
        width: size.width * 0.7,

    child: ElevatedButton(
      onPressed: _show,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range,color: Color(0xff036d81)),
          // Adjust the spacing between icon and text as needed
          Text(' Available period',style: TextStyle(color: Color(0xff036d81), fontSize: 20),),
        ],
      ),
    )
    );
  }

  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 6, 6),
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
                  const PageHeader(),
                  _entryFieldNumber("Budget", budgetController),
                  const SizedBox(height: 30,),
                  _entryFieldText("Place of departure", departureController),
                  const SizedBox(height: 40,),
                  _dateButton(),
                  const SizedBox(height: 30,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _text("Duration"),
                  ),
                  const SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child:
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
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _text("days"),
                      ),
                  ]
                  ),
                  const SizedBox(height: 20),
                  validator ? const Text(""):const Text("Please complete all the details",style: TextStyle(color: Colors.red, fontSize: 18),),
                  validatorBudget ? const Text(""):const Text("Please provide a budget of at least 200€",style: TextStyle(color: Colors.red, fontSize: 18),),
                  validatorDays ? const Text(""):const Text("Please provide a budget at least of 50€ per day",style: TextStyle(color: Colors.red, fontSize: 18),),
                  const SizedBox(height: 20),
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
