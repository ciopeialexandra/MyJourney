import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/plan-trip_page.dart';
import '../data/globals.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  List<User> data = List.empty();
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  String contactSelected = "";

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
    return DefaultTextStyle(
      style: const TextStyle(
          fontSize: 40.0,
          color: Colors.black
      ),
      child: AnimatedTextKit(
        animatedTexts : [
          TyperAnimatedText('Invite friends'),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }
  Widget _title(){
    return const Text("My Journey");
  }
  Widget _nextButton() {
    for (int i = 0; i < contacts.length; i++) {
      if (isSelected[i] == true) {
        isFriendsTrip = true;
      }
    }
    return ElevatedButton(
      onPressed: () {
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const PlanTripPage(),
            ),
          );
        });
      },
      child: const Text('Next'),
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    if(isSelected.isEmpty) {
      isSelected = List<bool>.filled(contacts.length, false);
    }
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
            TextField(
              controller: searchController,
              decoration:  InputDecoration(
                  labelText: 'Search',
                border: OutlineInputBorder(
                  borderSide:BorderSide(
                    color: Theme.of(context).primaryColor
                  )
                ),
                prefixIcon:  Icon(
                    Icons.search,
                  color: Theme.of(context).primaryColor,
                )
              ),
            ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: isSearching ? contactsFiltered.length : contacts.length,
            itemBuilder: (context, index) {
              Contact contact = isSearching ? contactsFiltered[index] : contacts[index];
              return ListTile(
                title: Text(contact.displayName.toString()),
                subtitle: Text(contact.phones!.elementAt(0).value.toString()),
                leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                    ? CircleAvatar(
                  backgroundImage: MemoryImage(contact.avatar!),
                )
                    : CircleAvatar(
                  child: Text(contact.initials()),
                ),
                tileColor: isSelected[index] ? Colors.purple.withOpacity(0.3) : null,
                onTap: () {
                  setState(() {
                      isSelected[index] = !isSelected[index];

                  });
                },
              );
            },
          ),
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
}
