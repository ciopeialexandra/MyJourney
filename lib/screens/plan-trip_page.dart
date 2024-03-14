import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/addfriend_page.dart';
import 'home_page.dart';

class PlanTripPage extends StatefulWidget {
  const PlanTripPage({super.key});

  @override
  State<PlanTripPage> createState() => _PlanTripPageState();
}


class _PlanTripPageState extends State<PlanTripPage> {
  List<User> data = List.empty();
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  bool isPressedBeach = false;
  bool isPressedMountain = false;
  bool isPressedCity = false;
  bool isPressedAttractions = false;

  @override
  void initState(){
    super.initState();
    getAllContacts();
    searchController.addListener(() {
      filterContacts();
    });
  }
  filterContacts(){
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if(searchController.text.isNotEmpty){
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String contactName = contact.displayName!.toLowerCase();
        return contactName.contains(searchTerm);
      });
      setState(() {
        contactsFiltered = _contacts;
      });
    }
  }
  getAllContacts() async{
    List<Contact> _contacts = await ContactsService.getContacts();
    setState(() {
      contacts = _contacts;
    });
  }
  Widget _animatedText(){
    return const DefaultTextStyle(
      style: TextStyle(
          fontSize: 40.0,
          color: Colors.black
      ),
      child: Text('Complete your trip details'),
      );
  }
  Widget _title(){
    return const Text("My Journey");
  }
  Widget _text(){
      return const DefaultTextStyle(
        style: TextStyle(
            fontSize: 20.0,
            color: Colors.black
        ),
        child: Text('What would you like?'),
      );
    }

  Widget _entryField(
      String title,
      TextEditingController controller
      ){
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: title
      ),
    );
  }
  Widget _nextButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const AddFriendPage()));
        });
      },
      child: const Text('Next'),
    );
  }

  Widget _dateButton() {
    return ElevatedButton(
      onPressed: _show,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range), // Adjust the spacing between icon and text as needed
          Text('Pick a date'),
        ],
      ),
    );
  }

  Widget _beachButton() {
    return ElevatedButton(
      onPressed:(){
        setState(() {
          isPressedBeach = !isPressedBeach;
        });
      },
        style: ElevatedButton.styleFrom(
          backgroundColor: isPressedBeach? Colors.purpleAccent : Colors.white
        ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.beach_access), // Adjust the spacing between icon and text as needed
          Text('Beach'),
        ],
      ),
    );
  }
  Widget _mountainButton() {
    return ElevatedButton(
      onPressed:(){
        setState(() {
          isPressedMountain = !isPressedMountain;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedMountain? Colors.purpleAccent : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.downhill_skiing), // Adjust the spacing between icon and text as needed
          Text('Mountain'),
        ],
      ),
    );
  }
  Widget _cityButton() {
    return ElevatedButton(
      onPressed:(){
        setState(() {
          isPressedCity = !isPressedCity;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedCity? Colors.purpleAccent : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_city), // Adjust the spacing between icon and text as needed
          Text('Big City'),
        ],
      ),
    );
  }
  Widget _attractionsButton() {
    return ElevatedButton(
      onPressed:(){
        setState(() {
          isPressedAttractions = !isPressedAttractions;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isPressedAttractions? Colors.purpleAccent : Colors.white
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.castle_sharp), // Adjust the spacing between icon and text as needed
          Text('Historical heritage'),
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
      print(result.start.toString());
      setState(() {
        _selectedDateRange = result;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _animatedText(),
            const SizedBox(height: 40),
            _entryField("Your budget", budgetController),
            const SizedBox(height: 30),
            _dateButton(),
            const SizedBox(height: 20),
            _text(),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                _beachButton(),
                _mountainButton(),
                _cityButton()
              ],
            ),
            _attractionsButton(),
            _nextButton()
          ],
        ),
      ),
    );
  }
}
