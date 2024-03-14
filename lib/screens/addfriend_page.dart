import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}
   enum IconLabel {
     smile('Beach', Icons.beach_access),
     cloud(
       'Mountain',
       Icons.downhill_skiing,
     ),
     brush('Brush', Icons.brush_outlined),
     heart('Heart', Icons.favorite);

     const IconLabel(this.label, this.icon);
     final String label;
     final IconData icon;
   }

class _AddFriendPageState extends State<AddFriendPage> {
  List<User> data = List.empty();
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController budgetController = TextEditingController();

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
          TyperAnimatedText('Choose friends to go with'),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }
  Widget _title(){
    return const Text("My Journey");
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
  Widget _addButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const HomePage()));
        });
      },
      child: const Text('Add'),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(

        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _animatedText(),
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
                child:ListView.builder(
                  shrinkWrap: true,
                  itemCount: isSearching == true ? contactsFiltered.length : contacts.length,
                  itemBuilder: (context,index) {
                    Contact contact = isSearching == true ? contactsFiltered[index] : contacts[index];
                    return ListTile(
                        title:  Text(contact.displayName.toString()),
                        subtitle: Text(
                            contact.phones!.elementAt(0).value.toString()
                        ),
                        leading: (contact.avatar != null && contact.avatar!.isNotEmpty)?
                        CircleAvatar(
                          backgroundImage: MemoryImage(contact.avatar!),
                        ) :
                        CircleAvatar(
                          child: Text(contact.initials()),
                        )
                    );
                  },
                )
            )
          ],
        ),
      ),
    );
  }
}
