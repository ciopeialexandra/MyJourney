import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/plan-result_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data/globals.dart';
import '../services/chat-provider.dart';
import '../services/models-provider.dart';

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
    plan.setPlanFriend(contactSelected);
    return ElevatedButton(
      onPressed: () {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
              MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => ModelsProvider(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => ChatProvider(),
                  ),
                ],
                child: MaterialApp(
                  title: 'Flutter ChatBOT',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                      scaffoldBackgroundColor: Colors.white,
                      appBarTheme: const AppBarTheme(
                        color: Colors.white,
                      )),
                  home: const ChatScreen(),
                ),
              )
              )
          );
          _createPlan();
        });
      },
      child: const Text('Next'),
    );
  }
  void _createPlan() async{
    var uuid = const Uuid().v1();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("plan/$uuid");
    await ref.set({
      "userId": userId,
      "budget": plan.getPlanBudget(),
      "date": plan.getPlanDate(),
      "friend": plan.getPlanFriend(),
      "isSki": plan.getPlanSki(),
      "isCity": plan.getPlanCity(),
      "isHistorical": plan.getPlanHistorical(),
      "isBeach": plan.getPlanSwim(),
      "isNature": plan.getPlanNature(),
      "isSwim": plan.getPlanSwim(),
      "result":plan.getPlanResult()
    });
  }
  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    int _selectedIndex = 0;
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
                      leading: (contact.avatar != null && contact.avatar!.isNotEmpty) ?
                      CircleAvatar(
                        backgroundImage: MemoryImage(contact.avatar!),
                      ) :
                      CircleAvatar(
                        child: Text(contact.initials()),
                      ),
                      tileColor: _selectedIndex == index ? Colors.blue.withOpacity(0.5) : null,
                      selected: _selectedIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedIndex = _selectedIndex == index ? -1 : index;
                          contactSelected = contact.phones!.elementAt(0).value.toString();
                        });
                      },
                    );
                  },
                )
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
