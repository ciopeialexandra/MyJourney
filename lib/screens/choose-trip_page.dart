import 'dart:convert';
import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:myjorurney/screens/home_page.dart';
import 'package:uuid/uuid.dart';
import '../data/globals.dart';
import '../data/plan.dart';
import '../data/request.dart';
import '../data/result.dart';
import '../services/api_constants.dart';

class ChooseTripPage extends StatefulWidget {
  const ChooseTripPage({super.key});

  @override
  State<ChooseTripPage> createState() => _ChooseTripPageState();
}


class _ChooseTripPageState extends State<ChooseTripPage> {
  List<Result> resultList = List.empty(growable: true);
  bool resultDisplayed = false;
  String img = "";
  String _generatedImageUrl = '';
  String chatGptAnswer = "";
  late List parts;
  List<Request> requestWait = List.empty(growable: true);
  String msgGlobal = "";
  int numberOfGeneratedResults = 0;
  int swipeNumber = 0;
  String resultKey = "";

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
      log(_generatedImageUrl);
    } else {
      // Handle API error
      log('Error generating image: ${response.reasonPhrase}');
    }
  }

  void trimResult() {
    int idx = chatGptAnswer.indexOf("Itinerary");
    parts = [
      chatGptAnswer.substring(0, idx).trim(),
      chatGptAnswer.substring(idx).trim()
    ];
  }

  Future<void> _waitForRequestDetails() async {
    requestWait = await _getRequestDetails();
  }

  Future<void> waitingForResult(String msg) async {
    for (int i = 0; i < 3; i++) {
      if (msg.isNotEmpty) {
        await chatGPTAPI(msg);
      }
      if (chatGptAnswer.isNotEmpty) {
        trimResult();
        img =
        "A realistic picture portraying a trip to ${parts[0]} ";
        await generateImage();
        resultList.add(Result(_generatedImageUrl, parts[1], parts[0]));
        numberOfGeneratedResults++;
        if (msgGlobal.contains("Except")) {
          msgGlobal = "$msgGlobal, ${parts[0]}";
        }
        else {
          msgGlobal = "$msgGlobal Except ${parts[0]}";
        }
      }
    }
  }

  Widget _countryAndCityText() {
    return DefaultTextStyle(
      style: const TextStyle(
          fontSize: 30.0,
          color: Colors.black87
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText(parts[0]),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }

  final List<Map<String, String>> messages = [];
  String openAiKey = API_KEY;

  Future<void> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content =
        jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        chatGptAnswer = content;
        print(chatGptAnswer);
      }
      log('An internal error occurred');
    } catch (e) {
      log(e.toString());
    }
  }

  void _createResult(int index) async {
    var uuid = const Uuid().v1();
    DatabaseReference ref = FirebaseDatabase.instance.ref("result/$uuid");
    resultKey = uuid;
    await ref.set({
      "image": resultList[index].image,
      "itinerary": resultList[index].itinerary,
      "cityAndCountry": resultList[index].cityAndCountry,
      "likes": resultList[index].numberOfLikes,
      "requestId": globalRequest.key
    });
  }

  void _updateResult() async {
    String? idUpdate = "";
    int numberOfLikes = 0;
    String cityAndCountry = "";
    String itinerary = "";
    String requestId = "";
    String image = "";

    final Map<String, Map> updates = {};
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshot = await ref.child('result').get();
      for (var resultLocal in snapshot.children) {
        if (resultLocal
            .key == resultKey) {
          cityAndCountry = resultLocal
              .child("cityAndCountry")
              .value
              .toString();
          itinerary = resultLocal
              .child("itinerary")
              .value
              .toString();
          requestId = resultLocal
              .child("requestId")
              .value
              .toString();
          image = resultLocal
              .child("image")
              .value
              .toString();
          if (resultLocal
              .child("likes")
              .value!
              .toString()
              .contains("0")) {
            numberOfLikes = 1;
          }
          else if (resultLocal
              .child("likes")
              .value!
              .toString() == "1") {
            numberOfLikes = 2;
          }
          if (resultLocal
              .child("likes")
              .value!
              .toString() == "2") {
            numberOfLikes = 3;
          }
        }
      }
    } catch (error) {
      log(error.toString());
    }
    final postData = {
      "image": image,
      "itinerary": itinerary,
      "cityAndCountry": cityAndCountry,
      "likes": numberOfLikes,
      "requestId": requestId
    };
    if (resultKey != "") {
      updates["result/$resultKey"] = postData;
      return FirebaseDatabase.instance.ref().update(updates);
    }
  }

  Future<bool> _areResultsAlreadyGenerated() async {
    //verifies if there are results already generated
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshotResult = await ref.child('result').get();
      for (var resultLocal in snapshotResult.children) {
        if (resultLocal
            .child("requestId")
            .value!
            .toString() == globalRequest.key
        ) {
          print("ok");
          Result resultData = Result("", "", "");
          resultData.itinerary = resultLocal
              .child("itinerary")
              .value
              .toString();
          resultData.cityAndCountry =
              resultLocal.child("cityAndCountry").toString();
          resultData.image = resultLocal.child("image").toString();
          if (resultLocal
              .child("likes")
              .value
              .toString() == "0") {
            resultData.numberOfLikes = 0;
          }
          else if (resultLocal
              .child("likes")
              .value
              .toString() == "1") {
            resultData.numberOfLikes = 1;
          }
          if (resultLocal
              .child("likes")
              .value
              .toString() == "2") {
            resultData.numberOfLikes = 2;
          }
          if (resultLocal
              .child("likes")
              .value
              .toString() == "3") {
            resultData.numberOfLikes = 3;
          }
          resultList.add(resultData);
        }
      }
    } catch (error) {
      log("Error at searching ");
    }
    if (resultList.isNotEmpty) {
      return true;
    }
    return false;
  }

  void _updatePlan() async {
    Plan planLocal = Plan(
        "",
        "",
        "",
        "",
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        "");
    int days = 0;
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    final Map<String, Map> updates = {};
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var planIterator in snapshot.children) {
        if (planIterator
            .child("userId")
            .value
            .toString() == userId &&
            planIterator
                .child("requestId")
                .value
                .toString() == globalRequest.key
        ) {
          planLocal.key = planIterator.key!;
          planLocal.date = planIterator
              .child("date")
              .value
              .toString();
          planLocal.budget = planIterator
              .child("budget")
              .value
              .toString();
          planLocal.town = planIterator
              .child("departure")
              .value
              .toString();
          if (planIterator
              .child("days")
              .value
              .toString() == "7") {
            planLocal.isSeven = true;
            days = 7;
          }
          else if (planIterator
              .child("days")
              .value
              .toString() == "3") {
            planLocal.isThree = true;
            days = 3;
          }
          else if (planIterator
              .child("days")
              .value
              .toString() == "10") {
            planLocal.isTen = true;
            days = 10;
          }
          if (planIterator
              .child("isBeach")
              .value
              .toString() == "true") {
            planLocal.isSwimming = true;
          }
          if (planIterator
              .child("isHistorical")
              .value
              .toString() == "true") {
            planLocal.isHistoricalHeritage = true;
          }
          if (planIterator
              .child("isCity")
              .value
              .toString() == "true") {
            planLocal.isBigCity = true;
          }
          if (planIterator
              .child("isNature")
              .value
              .toString() == "true") {
            planLocal.isNature = true;
          }
          if (planIterator
              .child("isSki")
              .value
              .toString() == "true") {
            planLocal.isSkiing = true;
          }
          if (planIterator
              .child("isTropical")
              .value
              .toString() == "true") {
            planLocal.isTropical = true;
          }
          if (planIterator
              .child("isShopping")
              .value
              .toString() == "true") {
            planLocal.isShopping = true;
          }
        }
      }
    } catch (error) {
      log(error.toString());
    }
    final postData = {
      "userId": userId,
      "budget": planLocal.getPlanBudget(),
      "departure": planLocal.getPlanTown(),
      "date": planLocal.getPlanDate(),
      "days": days,
      "isSki": plan.getPlanSki(),
      "isCity": plan.getPlanCity(),
      "isHistorical": plan.getPlanHistorical(),
      "isBeach": plan.getPlanSwim(),
      "isNature": plan.getPlanNature(),
      "isSwim": plan.getPlanSwim(),
      "isTropical": plan.getPlanTropical(),
      "isShopping": plan.getPlanShopping(),
      "requestId": globalRequest.key,
      "voted": "yes"
    };
    if (planLocal.key != "") {
      updates["plan/${planLocal.key}"] = postData;
      return FirebaseDatabase.instance.ref().update(updates);
    }
  }

  Widget closeButton() {
    return TextButton(
      onPressed: () {
        setState(() {});
      },

      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.close_sharp,
            size: 30.0,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget heartButton() {
    return TextButton(
      onPressed: () {
        setState(() {

        });
      },

      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.favorite,
            size: 30.0,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (swipeNumber != 3) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("My Journey"),
          ),
          body: Center(
              child: FutureBuilder<bool>(
                  future: _areResultsAlreadyGenerated(),
                  // a previously-obtained Future<String> or null
                  builder: (BuildContext context,
                      AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData) {
                      numberOfGeneratedResults = 3;
                    }
                    else {
                      if (resultDisplayed == false) {
                        resultDisplayed = true;
                        _getRequestDetails();
                        msgGlobal = getMessage();
                       waitingForResult(msgGlobal);
                      }
                    }
                    if (numberOfGeneratedResults == 3) {
                      List<Result> resultListLocal = List.empty(growable: true);
                      resultListLocal = resultList;
                      return Center (
                          child:Stack(
                        children: resultListLocal.map((card) {
                          int index = resultListLocal.indexOf(card);
                          return Dismissible(
                              key: Key('card_$index'),
                              direction: DismissDirection.horizontal,
                              onDismissed: (direction) {
                                setState(() {
                                  _createResult(index);
                                  resultListLocal.removeAt(index);
                                  swipeNumber ++;
                                });
                                if (direction ==
                                    DismissDirection.endToStart) {
                                  // Handle left swipe
                                  _updateResult();
                                  log("Swiped left on card $index");
                                } else if (direction ==
                                    DismissDirection.startToEnd) {
                                  // Handle right swipe
                                  log("Swiped right on card $index");
                                }
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.center,
                                child: const Icon(
                                    Icons.thumb_down, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: Colors.green,
                                alignment: Alignment.center,
                                child: const Icon(
                                    Icons.thumb_up, color: Colors.white),
                              ),
                              child: Card(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      Expanded(child:
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center,
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            Center(
                                              child: Image.network(
                                                  resultListLocal[index]
                                                      .image),
                                            ),
                                            Center(
                                              child: Text(
                                                card.cityAndCountry,
                                                style: const TextStyle(
                                                    fontSize: 30.0),
                                              ),
                                            ),
                                          ]
                                      ),
                                      ),
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center,
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                setState(() {

                                                });
                                              },

                                              style: ElevatedButton
                                                  .styleFrom(
                                                  backgroundColor: Colors
                                                      .white
                                              ),
                                              child: const Row(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .center,
                                                mainAxisAlignment: MainAxisAlignment
                                                    .end,
                                                children: [
                                                  Icon(
                                                    Icons.favorite,
                                                    size: 30.0,
                                                    color: Colors.red,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            closeButton(),
                                          ]
                                      )
                                    ],
                                  ),
                                ),
                              )
                          );
                        }).toList(),
                      )
                      );
                    }
                    else {
                      return Scaffold(
                          appBar: AppBar(
                            title: const Text("My Journey"),
                          ),
                          body: const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: <Widget>[
                                  SpinKitCircle(
                                    color: Colors.grey,
                                    size: 90.0,
                                  )
                                ]
                            ),
                          ));
                    }
                  }
              )
          )
      );
    }
    else {
      _updatePlan();
      return Scaffold(
          body: Center(
              child: AlertDialog(
                title: const Text(
                    'Your preferences are saved'),
                content: const Text(
                    'After your friends will complete the request, you will receive a notification'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () =>
                        setState(() {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const HomePage()));
                        }
                        ),
                    child: const Text('Continue'),
                  ),
                ],
              )
          )
      );
    }
  }

  Future<List<Request>> _getRequestDetails() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    String userIdRequest = "";
    String userPhoneRequest = "";
    String userNameRequest = "";
    Plan localPlan = Plan("", "", "", "", false, false, false, false, false, false, false, false, false, false, "");
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var planLocal in snapshot.children) {
            if (planLocal
                .child("requestId")
                .value!
                .toString() == globalRequest.key ) {
              localPlan.date = planLocal.child("date").value.toString();
              localPlan.budget = planLocal.child("budget").value.toString();
              if (planLocal.child("isBeach").value!.toString() == "true") {
                localPlan.isSwimming = true;
              }
              if (planLocal.child("isCity").value!.toString() == "true") {
                localPlan.isBigCity = true;
              }
              if (planLocal.child("isHistorical").value!.toString() == "true") {
                localPlan.isHistoricalHeritage = true;
              }
              if (planLocal.child("isNature").value!.toString() == "true") {
                localPlan.isNature = true;
              }
              if (planLocal.child("isSki").value!.toString() == "true") {
                localPlan.isSkiing = true;
              }
              if (planLocal.child("isTropical").value!.toString() == "true") {
                localPlan.isTropical = true;
              }
              if(planLocal.child("days").value!.toString() == "7"){
                localPlan.isSeven = true;
              }
              else if(planLocal.child("days").value!.toString() == "10"){
                localPlan.isTen = true;
              }
              else if(planLocal.child("days").value!.toString() == "3"){
                localPlan.isThree = true;
              }
                localPlan.town = planLocal.child("departure").value!.toString();
              userIdRequest = planLocal.child("userId").value!.toString();
              DataSnapshot requestUser = await ref.child('user').get();
              for (var userLocal in requestUser.children) {
                if (userLocal.key ==
                    userIdRequest) { //cautam useri care fac parte din request
                  userPhoneRequest = userLocal
                      .child("telephone")
                      .value!
                      .toString();
                  userNameRequest = userLocal
                      .child("name")
                      .value!
                      .toString();
                  globalRequest.plan.add(localPlan);
                  globalRequest.userName.add(userNameRequest);
                  globalRequest.phoneNumber.add(userPhoneRequest);
                }
              }
            }
          }
    } catch (error) {
      log(error.toString());
    }
    msgGlobal = getMessage();
    return request;
  }
  String getMessage(){
    String msgRequest = "";
    String days = "";
    String destination = "";
    String budget = "";

      for(int i=0;i<globalRequest.plan.length;i++){
        if(globalRequest.plan[i].isTen && !days.contains("10")){
          days = "$days 10";
        }
        else if(globalRequest.plan[i].isSeven && days.contains("7")){
          days = "$days 7";
        }
        else if(globalRequest.plan[i].isThree && days.contains("3")){
          days = "$days  3";
        }
        if(globalRequest.plan[i].isTropical && !msgRequest.contains("tropical")){
          msgRequest = "$msgRequest be a tropical place,";
        }
        if(globalRequest.plan[i].isShopping && !msgRequest.contains("shopping")){
          msgRequest = "$msgRequest have places to go shopping,";
        }
        if(globalRequest.plan[i].isSwimming && !msgRequest.contains("swim")){
          msgRequest = "$msgRequest have beaches where you can swim close by ,";
        }
        if(globalRequest.plan[i].isBigCity && !msgRequest.contains("city")){
          msgRequest = "$msgRequest be a big city,";
        }
        if(globalRequest.plan[i].isSkiing && !msgRequest.contains("mountains")){
          msgRequest = "$msgRequest have mountains ,";
        }
        if(globalRequest.plan[i].isNature && !msgRequest.contains("nature")){
          msgRequest = "$msgRequest be a lot of nature ,";
        }
        if(globalRequest.plan[i].isHistoricalHeritage && !msgRequest.contains("historical")){
          msgRequest = "$msgRequest have historical attractions ,";
        }
        if(globalRequest.plan[i].budget.compareTo( budget)>0){
          budget = globalRequest.plan[i].budget;
        }
        if(!destination.contains(globalRequest.plan[i].town)){
          String newTown = globalRequest.plan[i].town;
          destination = "$destination or $newTown";
        }
      }
    String msg = "Can you tell me a country and a city separated with a comma, just like this: 'Italy,Rome', that would fit a budget of $budget euro, for $days days, from $destination. I want the destination to: $msgRequest";
    msg = "$msg. In this budget I want to include the transport plan and also the accommodation and travel expenses. If the period is short please recommend something close. If the period is 7 or 10 days recommend a place far, but the budget to fit it. And in the next line I want an itinerary for the trip.";
   print(msg);
    return msg;
  }
}
