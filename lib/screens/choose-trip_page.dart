import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  int indexGlobal = 0;
  String  resultKeyParam = "";
  late Uint8List downloadedImage ;
  final List<String> _generatedImageName = List.empty(growable: true);
  List<String> planDates = List.empty(growable: true);
  String numberOfDays = "";
  int swipeNumber = 0;
  String resultKey = "";
  late Future<bool> areRequestDetailsGenerated ;
  late Future<bool> areRequestResultsGenerated ;
  late Future<bool> areResultsGeneratedFuture;
  late Future<void> areResultsCreated;
  late Future<bool> isRequestCompleted;
  late Future<void> waitPlanUpdate;

  @override
  void initState() {
    super.initState();
    areResultsGeneratedFuture = _areResultsAlreadyGenerated();
    if(areResultsGeneratedGlobal == false) {
      for(int i=0;i<3;i++) {
        _generatedImageName.add(const Uuid().v4());
      }
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
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    try {
      DataSnapshot snapshotResult = await ref.child('result').get();
      for (var resultLocal in snapshotResult.children) {
        if (resultLocal
            .child("requestId")
            .value!
            .toString() == globalRequest.key
        ) {
          Result resultData = Result("", "", ""," ","","");
          resultData.key = resultLocal.key!;
          resultData.itinerary = resultLocal
              .child("itinerary")
              .value
              .toString();
          resultData.cityAndCountry = resultLocal.child("cityAndCountry").value.toString();
          resultData.image = resultLocal.child("image").value.toString();
          final storageRef = FirebaseStorage.instance.ref();
          var imagePath = resultData.image;
          resultData.image = await storageRef.child("images/$imagePath.jpg").getDownloadURL();
          if (resultLocal
              .child("likes")
              .value
              .toString().isNotEmpty) {
            resultData.numberOfLikes = resultLocal
                .child("likes")
                .value
                .toString();
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
  Widget itineraryButton() {
    return TextButton(
      onPressed: () {
        setState(() {
        });
      },

      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.place,
            size: 40.0,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
  void trimResult(){
    int idx = chatGptAnswer.indexOf("Itinerary");
    int idxBudgetSpending = chatGptAnswer.indexOf("Budget spending");
    parts = [chatGptAnswer.substring(0,idx).trim(), chatGptAnswer.substring(idx).trim(), chatGptAnswer.substring(idxBudgetSpending-1)];

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
        resultList.add(Result(_generatedImageUrl, parts[1], parts[0],resultKey,parts[2],""));
        resultListCopy.add(Result(_generatedImageUrl, parts[1], parts[0],resultKey,parts[2],""));
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
        // Decode the response body as UTF-8
        final decodedResponse = utf8.decode(res.bodyBytes);
        String content = jsonDecode(decodedResponse)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        chatGptAnswer = content;
      } else {
        log('An internal error occurred: ${res.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    }
  }
  Future<void> _createResult(Result result) async{
      var uuid = const Uuid().v1();
      DatabaseReference ref = FirebaseDatabase.instance.ref("result/$uuid");
      resultKey = uuid;
      String imageKey = await uploadImage(result.image);
      await ref.set({
        "image": imageKey,
        "itinerary": result.itinerary,
        "cityAndCountry": result.cityAndCountry,
        "likes": result.numberOfLikes,
        "budgetSpending":result.budgetSpending,
        "finalDate":result.finalDate,
        "requestId": globalRequest.key
      });
  }
  Future<Uint8List> downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download image');
    }
  }
  Future<String> uploadImage(String image) async {
    String imgKey = const Uuid().v4();
    if(image.isNotEmpty) {
      downloadedImage = await downloadImage(image);
    }
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('images/$imgKey.jpg');
      UploadTask uploadTask = ref.putData(downloadedImage);
      await uploadTask.whenComplete(() {
        log('File uploaded successfully');
      });
      String downloadUrl = await ref.getDownloadURL();
      log('Download URL: $downloadUrl');
    } catch (e) {
      log('Error uploading image: $e');
    }
    return imgKey;
  }
  void _updateResult() async{
    if(areResultsGeneratedGlobal){resultKey = resultKeyParam;}
    String numberOfLikes = "1";String cityAndCountry = "";String itinerary = "";String requestId = "";String image = "";
    String budgetSpending = "";String finalDate = "";final Map<String, Map> updates = {};
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    try {
      DataSnapshot snapshot = await ref.child('result').get();
      for (var resultLocal in snapshot.children) {
        if (resultLocal.key == resultKey) {
          cityAndCountry = resultLocal.child("cityAndCountry").value.toString();
          itinerary = resultLocal.child("itinerary").value.toString();
          requestId = resultLocal.child("requestId").value.toString();
          image = resultLocal.child("image").value.toString();
          budgetSpending = resultLocal.child("budgetSpending").value.toString();
          finalDate = resultLocal.child("finalDate").value.toString();
          if(resultLocal.child("likes").value!.toString().isNotEmpty) {
            numberOfLikes = (int.parse(resultLocal.child("likes").value!.toString())+ 1).toString();
          }}}
      if(cityAndCountry.isEmpty){
        cityAndCountry = resultList[indexGlobal].cityAndCountry;
        itinerary = resultList[indexGlobal].itinerary;
        requestId = globalRequest.key;
        image = resultList[indexGlobal].image;
        budgetSpending = resultList[indexGlobal].budgetSpending;
        finalDate = resultList[indexGlobal].finalDate;
        if(resultList[indexGlobal].numberOfLikes.isNotEmpty) {numberOfLikes = (int.parse(resultList[indexGlobal].numberOfLikes)+ 1).toString();}}
    }catch (error) {log(error.toString());}
    final postData = {
      "image": image,
      "itinerary": itinerary,
      "cityAndCountry": cityAndCountry,
      "budgetSpending": budgetSpending,
      "finalDate":finalDate,
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
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    final Map<String, Map> updates = {};
    DatabaseReference ref = FirebaseDatabase.instance.ref();
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
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    int likesNumber = 0;
    try {
      DataSnapshot snapshot = await ref.child('result').get();
      for (var resultLocal in snapshot.children) {
        if (resultLocal
            .child("requestId")
            .value!
            .toString() == globalRequest.key) {
          if(likesNumber < int.parse(resultLocal.child("likes").value.toString())){
            likesNumber = int.parse(resultLocal.child("likes").value.toString());
          }
        }
      }
    } catch (error) {
      log(error.toString());
    }
    final postData = {
      "status": "completed",
    };
    final Map<String, Map> updates = {};
    String key = globalRequest.key;
    updates["request/$key"] = postData;
    return FirebaseDatabase.instance.ref().update(updates);
  }
  Widget _countryAndCityText(String text){
    return DefaultTextStyle(
      style: const TextStyle(
          fontSize: 30.0,
          color: Colors.black87
      ),
      child: AnimatedTextKit(
        animatedTexts : [
          TyperAnimatedText(text),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("TripSync"),
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
                                                  child:  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      itineraryButton(),
                                                      Flexible(
                                                        child: _countryAndCityText(card.cityAndCountry),
                                                      ),
                                                    ],
                                                  )
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
                                result.calcFinalDate(planDates,numberOfDays);
                                setState(() {
                                  //_createResult(index);
                                  resultListCopy.removeAt(index);
                                  swipeNumber ++;
                                });
                                _createResult(result);
                                if (direction ==
                                    DismissDirection
                                        .endToStart) {
                                  if(result.numberOfLikes.isNotEmpty) {
                                    result.numberOfLikes = (int.parse(result.numberOfLikes)+ 1).toString();
                                  }
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
                                              child: Text("Options left: ${index+1}", style: const TextStyle(
                                                  fontSize: 20.0),),
                                            ),
                                            const SizedBox(height: 20,),
                                            Center(
                                              child: Image
                                                  .network(
                                                  resultListCopy[index]
                                                      .image),
                                            ),
                                            Center(
                                                child:  Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    itineraryButton(),
                                                    Flexible(
                                                      child: _countryAndCityText(card.cityAndCountry),
                                                    ),
                                                  ],
                                                )
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
    DatabaseReference ref = FirebaseDatabase.instance.ref();
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
              planDates.add(localPlan.date);
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
              numberOfDays = localPlan.days;
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
    DatabaseReference ref = FirebaseDatabase.instance.ref();
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
    msg = "$msg. In this budget I want to include the transport plan and also the accommodation and travel expenses."
        " If the period is short please recommend something close. If the period is 7 or 10 days recommend a place far,"
        " but the budget to fit it. And in the next line I want an itinerary for the trip, starting with the text Itinerary."
        " Next after the the itinerary on a next line please provide the travel expenses, starting with the words: Budget spending."
        " For both I want the answer to be on the following line";
    return msg;
  }
}
