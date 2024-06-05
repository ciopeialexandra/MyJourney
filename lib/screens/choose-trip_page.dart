import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:myjorurney/screens/home_page.dart';
import 'package:uuid/uuid.dart';
import '../data/globals.dart';
import '../data/plan.dart';
import '../data/request.dart';
import '../data/result.dart';
import '../data/user.dart';
import '../services/api_constants.dart';

class ChooseTripPage extends StatefulWidget {
  const ChooseTripPage({super.key});

  @override
  State<ChooseTripPage> createState() => _ChooseTripPageState();
}


class _ChooseTripPageState extends State<ChooseTripPage> {
  List<Result> resultList = List.empty(growable: true);
  List<Result> resultListCopy = List.empty(growable: true);
  bool resultDisplayed = false;
  String img = "";
  String _generatedImageUrl = '';
  String chatGptAnswer = "";
  late List parts;
  List<Request> requestWait = List.empty(growable: true);
  String msgGlobal = "";
  late Future<bool> areRequestDetailsGenerated ;
  late Future<bool> areRequestResultsGenerated ;
  int swipeNumber = 0;
  String resultKey = "";
  late Future<bool> areResultsGeneratedFuture;
  late Future<void> areResultsCreated;
  late Future<bool> isRequestCompleted;
  late Future<void> waitPlanUpdate;
  int indexGlobal = 0;
  String  resultKeyParam = "";

  @override
  void initState() {
    super.initState();
    areResultsGeneratedFuture = _areResultsAlreadyGenerated();
    if(areResultsGeneratedGlobal == false) {
      areRequestDetailsGenerated = _getRequestDetails();
      areRequestDetailsGenerated.then((result) {
        setState(() {
          areRequestResultsGenerated = waitingForResult(msgGlobal);
        });
      });
    }
    else {
      waitPlanUpdate = _updatePlan();
      waitPlanUpdate.then((value){
        isRequestCompleted = _getRequestStatus();
      });
    }
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
      log (_generatedImageUrl);
    } else {
      // Handle API error
      log ('Error generating image: ${response.reasonPhrase}');
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
          Result resultData = Result("", "", ""," ");
          resultData.key = resultLocal.key!;
          resultData.itinerary = resultLocal
              .child("itinerary")
              .value
              .toString();
          resultData.cityAndCountry = resultLocal.child("cityAndCountry").value.toString();
          resultData.image = resultLocal.child("image").value.toString();
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

  void trimResult(){
    int idx = chatGptAnswer.indexOf("Itinerary");
    parts = [chatGptAnswer.substring(0,idx).trim(), chatGptAnswer.substring(idx).trim()];
  }
  Future<bool> waitingForResult(String msg) async{
    for(int i=0;i<3;i++) {
      if (msg.isNotEmpty) {
        await chatGPTAPI(msg);
      }
      if (chatGptAnswer.isNotEmpty) {
        trimResult();
        img =
        "A realistic picture portraying a trip to ${parts[0]} ";
        await generateImage();
        resultList.add(Result(_generatedImageUrl, parts[1], parts[0],resultKey));
        resultListCopy.add(Result(_generatedImageUrl, parts[1], parts[0],resultKey));
        if (msgGlobal.contains("Except")) {
          msgGlobal = "$msgGlobal, ${parts[0]}";
        }
        else {
          msgGlobal = "$msgGlobal Except ${parts[0]}";
        }
      }
    }
    return true;
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
      log ('An internal error occurred');
    } catch (e) {
      log (e.toString());
    }
  }
  Future<void> _createResult(Result result) async{
      var uuid = const Uuid().v1();
      DatabaseReference ref = FirebaseDatabase.instance.ref("result/$uuid");
      resultKey = uuid;
      await ref.set({
        "image": result.image,
        "itinerary": result.itinerary,
        "cityAndCountry": result.cityAndCountry,
        "likes": result.numberOfLikes,
        "requestId": globalRequest.key
      });
  }
  void _updateResult() async{
    if(areResultsGeneratedGlobal){
      resultKey = resultKeyParam;
    }
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
          cityAndCountry = resultLocal.child("cityAndCountry").value.toString();
          itinerary = resultLocal.child("itinerary").value.toString();
          requestId = resultLocal.child("requestId").value.toString();
          image = resultLocal.child("image").value.toString();
          if(resultLocal.child("likes").value!.toString().contains("0")) {
            numberOfLikes = 1;

          }
          else if(resultLocal.child("likes").value!.toString() == "1") {
            numberOfLikes = 2;
          }
          if(resultLocal.child("likes").value!.toString() == "2") {
            numberOfLikes = 3;
          }
        }
      }
      if(cityAndCountry.isEmpty){
        cityAndCountry = resultList[indexGlobal].cityAndCountry;
        itinerary = resultList[indexGlobal].itinerary;
        requestId = globalRequest.key;
        image = resultList[indexGlobal].image;
        if(resultList[indexGlobal].numberOfLikes == 0) {
          numberOfLikes = 1;
        }
        else if(resultList[indexGlobal].numberOfLikes == 1) {
          numberOfLikes = 2;
        }
        if(resultList[indexGlobal].numberOfLikes == 2) {
          numberOfLikes = 3;
        }
      }
    }catch (error) {
      log(error.toString());
    }
    final postData = {
      "image": image,
      "itinerary": itinerary,
      "cityAndCountry": cityAndCountry,
      "likes": numberOfLikes,
      "requestId": requestId
    };
    if(resultKey != "") {
      updates["result/$resultKey"] = postData;
      return FirebaseDatabase.instance.ref().update(updates);
    }
  }
  Future<void> _updatePlan() async{
    Plan planLocal = Plan("", "" ,"","",false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,"");
    int days = 0;
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    final Map<String, Map> updates = {};
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var planIterator in snapshot.children) {
        if (planIterator
            .child("userId").value.toString() == userId &&
        planIterator.child("requestId").value.toString() == globalRequest.key
        ) {
          planLocal.key = planIterator.key!;
          planLocal.date = planIterator.child("date").value.toString();
          planLocal.budget = planIterator.child("budget").value.toString();
          planLocal.town = planIterator.child("departure").value.toString();
          planLocal.days = planIterator.child("days").value.toString();

          if(planIterator.child("isBeach").value.toString() == "true") {
            planLocal.isSwimming = true;
          }
          if(planIterator.child("isNightlife").value.toString() == "true") {
            planLocal.isNightlife = true;
          }
          if(planIterator.child("isHistorical").value.toString() == "true") {
            planLocal.isHistoricalHeritage = true;
          }
          if(planIterator.child("isCity").value.toString() == "true") {
            planLocal.isBigCity = true;
          }
          if(planIterator.child("isNature").value.toString() == "true") {
            planLocal.isNature = true;
          }
          if(planIterator.child("isSki").value.toString() == "true") {
            planLocal.isSkiing = true;
          }
          if(planIterator.child("isTropical").value.toString() == "true") {
            planLocal.isTropical = true;
          }
          if(planIterator.child("isShopping").value.toString() == "true") {
            planLocal.isShopping = true;
          }

          if(planIterator.child("isUnique").value.toString() == "true") {
            planLocal.isUnique = true;
          }
          if(planIterator.child("isPopular").value.toString() == "true") {
            planLocal.isPopular = true;
          }
          if(planIterator.child("isLuxury").value.toString() == "true") {
            planLocal.isLuxury = true;
          }
          if(planIterator.child("isCruises").value.toString() == "true") {
            planLocal.isCruises = true;
          }
          if(planIterator.child("isRomantic").value.toString() == "true") {
            planLocal.isRomantic = true;
          }
          if(planIterator.child("isThermalSpa").value.toString() == "true") {
            planLocal.isThermalSpa = true;
          }
          if(planIterator.child("isAdventure").value.toString() == "true") {
            planLocal.isAdventure = true;
          }
          if(planIterator.child("isRelaxing").value.toString() == "true") {
            planLocal.isRelaxing = true;
          }
        }
      }
    }catch (error) {
      log(error.toString());
    }
    final postData = {
      "userId": userId,
      "budget": planLocal.getPlanBudget(),
      "departure": planLocal.getPlanTown(),
      "date": planLocal.getPlanDate(),
      "days": planLocal.getPlanDays(),
      "isSki": plan.getPlanSki(),
      "isCity": plan.getPlanCity(),
      "isHistorical": plan.getPlanHistorical(),
      "isBeach": plan.getPlanSwim(),
      "isNature": plan.getPlanNature(),
      "isSwim": plan.getPlanSwim(),
      "isTropical": plan.getPlanTropical(),
      "isShopping": plan.getPlanShopping(),
      "isNightlife": plan.getPlanNightlife(),
      "isUnique": plan.getPlanUnique(),
      "isPopular": plan.getPlanPopular(),
      "isLuxury": plan.getPlanLuxury(),
      "isCruises": plan.getPlanCruises(),
      "isRomantic": plan.getPlanRomantic(),
      "isThermalSpa": plan.getPlanThermalSpa(),
      "isAdventure": plan.getPlanAdventure(),
      "isRelaxing": plan.getPlanRelaxing(),
      "requestId": globalRequest.key,
      "voted": "yes"
    };
    if(planLocal.key != "") {
      updates["plan/${planLocal.key}"] = postData;
      return FirebaseDatabase.instance.ref().update(updates);
    }
  }
  Widget closeButton() {
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
  void _updateRequest() async{
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    String likesNumber = "0";
    String? resultId ="";
    try {
      DataSnapshot snapshot = await ref.child('result').get();
      for (var resultLocal in snapshot.children) {
        if (resultLocal
            .child("requestId")
            .value!
            .toString() == globalRequest.key) {
          if(likesNumber.compareTo(resultLocal.child("likes").value.toString())<0){
            likesNumber = resultLocal.child("likes").value.toString();
            resultId = resultLocal.key;
          }
        }
      }
    } catch (error) {
      log(error.toString());
    }
    final postData = {
      "status": "completed",
      "resultId": resultId
    };
    final Map<String, Map> updates = {};
    String key = globalRequest.key;
    updates["request/$key"] = postData;
    return FirebaseDatabase.instance.ref().update(updates);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Journey"),
        ),
        body: Center(
            child: FutureBuilder<bool>(
                future: areResultsGeneratedFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if(snapshot.hasData) {
                    if (snapshot.data == true) {
                      List<Result> resultListLocal = List.empty(
                          growable: true);
                      resultListLocal = resultList;
                      if (swipeNumber != 3) {
                        return Stack(
                            children: resultListLocal.map((card) {
                              int index = resultListLocal.indexOf(card);
                              return Dismissible(
                                  key: Key('card_$index'),
                                  direction: DismissDirection.horizontal,
                                  onDismissed: (direction) {
                                    setState(() {
                                      resultKeyParam = resultList[index].key;
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
                                        Icons.thumb_down,
                                        color: Colors.white),
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
                            }).toList());
                      }
                      else {
                       return verifyRequestState();
                      }
                    } else {
                      return waitForRequestDetails();
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                }
            )
        )
    );
  }
Widget verifyPlanUpdated() {
  return Center(
      child: FutureBuilder<void>(
          future: waitPlanUpdate,
          // a previously-obtained Future<String> or null
          builder: (BuildContext context,
              AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return verifyRequestState();
            }
            return const Text("Error at verifyPlanUpdated");
          }
      )
  );
}
  Widget verifyRequestState(){
      return  Center(
          child:FutureBuilder<bool>(
              future: isRequestCompleted,
              // a previously-obtained Future<String> or null
              builder: (BuildContext context,
                  AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }else if (snapshot.hasData) {
                  return AlertDialog(
                    title: const Text(
                        'Preferences saved'),
                    content: const Text(
                        'After your friends will complete the request, you will receive a notification.'),
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
                  );
                }
                return const Text("Request update failed");
              }
          )
      );
    }
Widget waitForRequestDetails(){
    if(msgGlobal.isEmpty) {
      return FutureBuilder<bool>(
          future: areRequestDetailsGenerated,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text(
                  'Error: ${snapshot.error}'));
            } else {
              if (snapshot.data == true) {
                msgGlobal = getMessage();
                if (resultDisplayed == false) {
                  resultDisplayed = true;
                  return displayTheResult();
                }
              }
            }
            return const Padding(
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
                )
            );
          }
      );
    }
    else{
      return displayTheResult();
    }
}
  Widget displayTheResult() {
      return FutureBuilder<bool>(
          future: areRequestResultsGenerated,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text(
                  'Error: ${snapshot.error}'));
            } else {
              if (snapshot.data == true) {
                  if (swipeNumber != 3) {
                    return Stack(
                        children: resultListCopy
                            .map((card) {
                          int index = resultListCopy
                              .indexOf(card);
                          return Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection
                                  .horizontal,
                              onDismissed: (direction) {
                                final Result result = resultListCopy[index];
                                setState(() {
                                  //_createResult(index);
                                  resultListCopy.removeAt(index);
                                  swipeNumber ++;
                                });
                                _createResult(result);
                                if (direction ==
                                    DismissDirection
                                        .endToStart) {
                                  // Handle left swipe
                                  indexGlobal = index;
                                  _updateResult();
                                  log(
                                      "Swiped left on card $index");
                                } else if (direction ==
                                    DismissDirection
                                        .startToEnd) {
                                  // Handle right swipe
                                  log(
                                      "Swiped right on card $index");
                                }
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment
                                    .center,
                                child: const Icon(
                                    Icons.thumb_down,
                                    color: Colors
                                        .white,
                                  size: 40,
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.green,
                                alignment: Alignment
                                    .center,
                                child: const Icon(
                                    Icons.thumb_up,
                                    color: Colors
                                        .white,
                                  size: 40,
                                ),
                              ),
                              child: Card(
                                child: Container(
                                  padding: const EdgeInsets
                                      .all(20),
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
                                              child: Image
                                                  .network(
                                                  resultListCopy[index]
                                                      .image),
                                            ),
                                            Center(
                                              child: Text(
                                                card
                                                    .cityAndCountry,
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
                                                    Icons
                                                        .favorite,
                                                    size: 30.0,
                                                    color: Colors
                                                        .red,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                                width: 20),
                                            closeButton(),
                                          ]
                                      )
                                    ],
                                  ),
                                ),
                              )
                          );
                        }).toList());
                  }
                  else {
                    _updatePlan();
                    return  Center(
                        child: AlertDialog(
                          title: const Text(
                              'Your preferences are saved'),
                          content: const Text(
                              'After your friends will complete the request, you will receive a notification'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () =>
                                  setState(() {
                                    Navigator
                                        .push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const HomePage()));
                                  }
                                  ),
                              child: const Text(
                                  'Continue'),
                            ),
                          ],
                        )
                    );
                  }
                }
              }
                return const Padding(
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
                );
              });
          }
  Future<bool> _getRequestDetails() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    String userIdRequest = "";
    String userPhoneRequest = "";
    String userNameRequest = "";
    String userEmailRequest = "";
    Plan localPlan = Plan("", "", "", "", false, false, false, false, false, false, false,false,  false,false,false,false,false,false,false,false,"");
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
              if (planLocal.child("isNightlife").value!.toString() == "true") {
                localPlan.isNightlife = true;
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
              if(planLocal.child("isUnique").value!.toString()=="true") {
                localPlan.isUnique = true;
              }
              if(planLocal.child("isPopular").value!.toString()=="true") {
                localPlan.isPopular = true;
              }
              if(planLocal.child("isLuxury").value!.toString()=="true") {
                localPlan.isLuxury = true;
              }
              if(planLocal.child("isCruises").value!.toString()=="true") {
                localPlan.isCruises = true;
              }
              if(planLocal.child("isRomantic").value!.toString()=="true") {
                localPlan.isRomantic = true;
              }
              if(planLocal.child("isThermalSpa").value!.toString()=="true") {
                localPlan.isThermalSpa = true;
              }
              if(planLocal.child("isAdventure").value!.toString()=="true") {
                localPlan.isAdventure = true;
              }
              if(planLocal.child("isRelaxing").value!.toString()=="true") {
                localPlan.isRelaxing = true;
              }
              localPlan.days = planLocal.child("days").value.toString();
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
                  userEmailRequest = userLocal.child("email").value!.toString();
                  UserClass user = UserClass(userLocal.key,userNameRequest,userEmailRequest,userPhoneRequest);
                  globalRequest.user.add(user);
                }
              }
            }
          }
    } catch (error) {
      log(error.toString());
      return false;
    }
    msgGlobal = getMessage();
    return true;
  }
  Future<bool> _getRequestStatus() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try {
      DataSnapshot snapshot = await ref.child('plan').get();
      for (var planLocal in snapshot.children) {
        if (planLocal
            .child("requestId")
            .value!
            .toString() == globalRequest.key) {
        if(planLocal.child("voted").value!.toString().contains("no")){
          return false;
        }
        }
      }
    } catch (error) {
      log(error.toString());
      return false;
    }
    _updateRequest();

    return true;
  }
  String getMessage(){
    String msgRequest = "";
    String days = "";
    String destination = "";
    String budget = "";

      for(int i=0;i<globalRequest.plan.length;i++){
        if(!days.contains(globalRequest.plan[i].getPlanDays())&& days.isNotEmpty) {
          days = "$days or ${globalRequest.plan[i]} days";
        }
        else if(!days.contains(globalRequest.plan[i].getPlanDays())&& days.isEmpty) {
          days = "$days ${globalRequest.plan[i]} days";
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
        if(globalRequest.plan[i].isNightlife && !msgRequest.contains("night")){
          msgRequest = "$msgRequest have a nice nightlife ,";
        }
        if(globalRequest.plan[i].budget.compareTo( budget)>0){
          budget = globalRequest.plan[i].budget;
        }
        if(globalRequest.plan[i].isUnique && !msgRequest.contains("unique")) {
          msgRequest = "$msgRequest is a unique place ,";
        }
        if(globalRequest.plan[i].isPopular && !msgRequest.contains("popular")) {
          msgRequest = "$msgRequest is a popular destination ,";
        }
        if(globalRequest.plan[i].isLuxury && !msgRequest.contains("luxury")) {
          msgRequest = "$msgRequest is a luxury destination,";
        }
        if(globalRequest.plan[i].isCruises && !msgRequest.contains("cruises")) {
          msgRequest = "$msgRequest go on a cruise,";
        }
        if(globalRequest.plan[i].isRomantic && !msgRequest.contains("romantic")) {
          msgRequest = "$msgRequest is a romantic destination ,";
        }
        if(globalRequest.plan[i].isThermalSpa && !msgRequest.contains("thermal")) {
          msgRequest = "$msgRequest have a thermal spa ,";
        }
        if(globalRequest.plan[i].isAdventure && !msgRequest.contains("adventure")) {
          msgRequest = "$msgRequest have adventure activities ,";
        }
        if(globalRequest.plan[i].isRelaxing && !msgRequest.contains("relax")) {
          msgRequest = "$msgRequest have relaxing activities ,";
        }
      }
    String msg = "Can you tell me a country and a city separated with a comma, just like this: 'Rome,Italy', that would fit a budget of $budget euro, for $days days, from $destination. I want the destination to: $msgRequest";
    msg = "$msg. In this budget I want to include the transport plan and also the accommodation and travel expenses. If the period is short please recommend something close. If the period is 7 or 10 days recommend a place far, but the budget to fit it. And in the next line I want an itinerary for the trip.";
   print(msg);
    return msg;
  }
}
