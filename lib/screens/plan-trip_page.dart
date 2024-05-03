import 'dart:convert';
import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/plan-result_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data/globals.dart';
import '../services/api_constants.dart';
import '../services/chat-provider.dart';
import '../services/models-provider.dart';
import '../widgets/text_widget.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;

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
  String _generatedImageUrl = '';
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
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
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

  getAllContacts() async {
    List<Contact> _contacts = await ContactsService.getContacts();
    setState(() {
      contacts = _contacts;
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
      "isSki": false,
      "isCity": false,
      "isHistorical": false,
      "isBeach": false,
      "isNature": false,
      "isSwim": false,
      "isTropical": false,
      "requestId": requestId

    });
  }
  void _createRequest() async{
    var uuid = const Uuid().v1();
    User? user = FirebaseAuth.instance.currentUser;
    requestId = uuid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("request/$uuid");
    await ref.set({
      "finalResult": "",

    });
  }
  Future<String?> getUserIdByPhoneNumber(String phoneNumber) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshot = await ref.child('user').get();
      for (var phone_local in snapshot.children) {
        String userPhoneNumber = phone_local.child("telephone").value!.toString(); // Get the value of userId
        if (userPhoneNumber == phoneNumber) {
          return phone_local.key;
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
    _createRequest();
    await ref.set({
      "userId": userId,
      "budget": plan.getPlanBudget(),
      "date": plan.getPlanDate(),
      "departure": plan.getPlanTown(),
      "isSki": plan.getPlanSki(),
      "isCity": plan.getPlanCity(), //de adaugat verificari sa nu fie niciuna goala
      "isHistorical": plan.getPlanHistorical(),
      "isBeach": plan.getPlanSwim(),
      "isNature": plan.getPlanNature(),
      "isSwim": plan.getPlanSwim(),
      "isTropical": plan.getPlanTropical(),
      "requestId": requestId
    });
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
              }
              //if (isFriendsTrip == false) {
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
  Future<void> generateImage() async {
    final String apiKey = API_KEY;
    final String prompt = img;

    // Make a POST request to OpenAI API to generate image
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
        "n": 1,
        "size": "512x512"
      }),
    );

    if (response.statusCode == 200) {
      // Parse the API response and update the generated image URL
      final responseData = jsonDecode(response.body);
      setState(() {
        _generatedImageUrl = responseData['data'][0]['url'];
      });
    } else {
      // Handle API error
      print('Error generating image: ${response.reasonPhrase}');
    }
  }
  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
        required ChatProvider chatProvider}) async {
    try {
      String msgRequest = "";
      String days = "";
      String destination = "";
      String budget = plan.getPlanBudget();
      if(plan.isThree){
        days = " 3 ";
      }
      else if(plan.isSeven){
        days = " 7 ";
      }
      else if(plan.isTen){
        days = " 10 ";
      }
      if(isPlanRequest == true){
        for(int i=0;i<request[requestIndex].userName.length;i++){
          if(request[requestIndex].plan[i].isTen && !days.contains("10")){
            days = "${days}or 10";
          }
          else if(request[requestIndex].plan[i].isSeven && days.contains("7")){
            days = "${days}or 7";
          }
          else if(request[requestIndex].plan[i].isThree && days.contains("3")){
            days = "${days}or 3";
          }
          if(request[requestIndex].plan[i].isTropical && !msgRequest.contains("tropical")){
            days = "$msgRequest, be a tropical place";
          }
          if(request[requestIndex].plan[i].isShopping && !msgRequest.contains("shopping")){
            days = "$msgRequest, have places to go shopping";
          }
          if(request[requestIndex].plan[i].isSwimming && !msgRequest.contains("swim")){
            days = "$msgRequest, have beaches where you can swim close by ";
          }
          if(request[requestIndex].plan[i].isBigCity && !msgRequest.contains("city")){
            days = "$msgRequest, be a big city";
          }
          if(request[requestIndex].plan[i].isSkiing && !msgRequest.contains("mountains")){
            days = "$msgRequest, have mountains ";
          }
          if(request[requestIndex].plan[i].isNature && !msgRequest.contains("nature")){
            days = "$msgRequest, be a lot of nature ";
          }
          if(request[requestIndex].plan[i].isHistoricalHeritage && !msgRequest.contains("historical")){
            days = "$msgRequest, have historical attractions ";
          }
          if(request[requestIndex].plan[i].budget.compareTo( plan.getPlanBudget())>0){
            budget = request[requestIndex].plan[i].budget;
          }
          if(!destination.contains(request[requestIndex].plan[i].town)){
            String newTown = request[requestIndex].plan[i].town;
            destination = "$destination or $newTown";
          }
        }
      }
      String msg = "Can you tell me a country and a city separated with a comma, just like this: 'Italy,Rome', that would fit a budget of ${plan.getPlanBudget()} euro, for $days days, from $destination. I want the destination to";
      if(plan.isShopping && !msgRequest.contains("shopping")){
        msg = "$msg, have places to go shopping ";
      }
      if(plan.isSwimming && !msgRequest.contains("swim")){
        msg = "$msg, have beaches where you can swim close by ";
      }
      if(plan.isHistoricalHeritage&& !msgRequest.contains("historical")){
        msg = "$msg, have historical attractions ";
      }
      if(plan.isBigCity && !msgRequest.contains("city")){
        msg = "$msg be a big city ";
      }
      if(plan.isTropical && !msgRequest.contains("tropical")){
        msg = "$msg be a tropical place ";
      }
      if(plan.isSkiing && !msgRequest.contains("mountains")){
        msg = "$msg have mountains ";
      }
      if(plan.isNature && !msgRequest.contains("nature")){
        msg = "$msg be a lot of nature ";
      }
      msg = "${msg}In this budget I want to include the transport plan and also the accommodation and travel expenses. If the period is short please recommend something close. If the period is long recommend a place far, but the budget to fit it. And in the next line I want an itinerary for the trip.";
      await chatProvider.sendMessageAndGetAnswers(
          msg: msg, chosenModelId: modelsProvider.getCurrentModel);
      // img ="A realistic picture portraying a trip to ${chatProvider
      //     .getChatList[0].msg} ";
      // generateImage();
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEND();
      });
    }
  }
  Future<void> showResult(ModelsProvider modelsProvider, ChatProvider chatProvider) async {
    await sendMessageFCT(
        modelsProvider: modelsProvider,
        chatProvider: chatProvider);
  }
  void _updatePlan() async{
    var uuid = const Uuid().v1();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    String? idUpdate = "";
    //String planId = request[requestIndex].plan
    final postData = {
      "userId": userId,
      "budget": plan.getPlanBudget(),
      "departure": plan.getPlanTown(),
      "date": plan.getPlanDate(),
      "isSki": plan.getPlanSki(),
      "isCity": plan.getPlanCity(),
      "isHistorical": plan.getPlanHistorical(),
      "isBeach": plan.getPlanSwim(),
      "isNature": plan.getPlanNature(),
      "isSwim": plan.getPlanSwim(),
      "isTropical": plan.getPlanTropical(),
      "requestId": request[requestIndex].key
    };
    final Map<String, Map> updates = {};
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var plan_local in snapshot.children) {
        if (plan_local
            .child("userId")
            .value!
            .toString() == userId
            && request[requestIndex].key == plan_local.child("requestId").value!.toString()) {
          idUpdate = plan_local.key;
        }
      }
    }catch (error) {
      print(error);
    }
    if(idUpdate != "") {
      updates["plan/$idUpdate"] = postData;
      return FirebaseDatabase.instance.ref().update(updates);
    }
  }
  void _updateRequest() async{
    var uuid = const Uuid().v1();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    String? idUpdate = "";
    final postData = {
      "finalResult": result,
      "accept": "not yet"
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
    // final modelsProvider = Provider.of<ModelsProvider>(context);
    // final chatProvider = Provider.of<ChatProvider>(context);
    // if(resultUpdated == false) {
    //   showResult(modelsProvider, chatProvider);
    //   result = chatProvider.getChatList[0].msg;
    //   resultUpdated = true;
    // }
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
    User? user = FirebaseAuth.instance.currentUser;
    int notificationNumber = 0;
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
