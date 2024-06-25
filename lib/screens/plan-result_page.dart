import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myjorurney/screens/home_page.dart';
import 'package:uuid/uuid.dart';
import '../data/globals.dart';
import '../data/result.dart';
import '../services/api_constants.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();}

class _ChatScreenState extends State<ChatScreen> {

  late ScrollController _listScrollController;
  late FocusNode focusNode;
  bool resultDisplayed = false;
  String img = "";
  String _generatedImageUrl = '';
  String chatGptAnswer = "";
  late List parts;
  Result result=Result("", "", "", "","","");
  String resultId = "";
  late Future<bool> waitingForResultsFinished;
  late Uint8List downloadedImage ;
  late String _generatedImageName;

  @override
  void initState() {
    _listScrollController = ScrollController();
    focusNode = FocusNode();
   waitingForResultsFinished = waitingForResult();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    focusNode.dispose();
    super.dispose();
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
  Widget _countryAndCityText(){
    return DefaultTextStyle(
      style: const TextStyle(
          fontSize: 30.0,
          color: Colors.black87
      ),
      child: AnimatedTextKit(
        animatedTexts : [
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
      }
    } catch (e) {
      log (e.toString());
      parts[0] = "No result found";
      parts[1] = "Please try again";
    }
  }

  Widget _title() {
    return const Text('TripSync');
  }

  Widget refreshButton() {
      return TextButton(
        onPressed: () {
          setState(() {
            previousGeneratedResultsSoloTrip = "${previousGeneratedResultsSoloTrip + parts[0]},";
            isPlanRequest = true;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                    const ChatScreen()));
          });
        },

        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.refresh_outlined,
              size: 40.0,
              color: Colors.black,
            ),
          ],
        ),
      );
    }
  Future<void> _createResult() async{
    var uuid = const Uuid().v1();
    DatabaseReference ref = FirebaseDatabase.instance.ref("result/$uuid");
    resultId = uuid;
    List<String> planDate = List.empty(growable: true);
    planDate.add(plan.date);
    result.calcFinalDate(planDate,plan.days);
    await ref.set({
      "image": _generatedImageName,
      "itinerary": parts[1],
      "cityAndCountry": parts[0],
      "budgetSpending": parts[2],
      "requestId": globalRequestIdSoloTrip,
      "finalDate": result.finalDate,
      "likes": "1"
    });
    _createRequest();
  }
  Future<Uint8List> downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download image');
    }
  }
  Future<void> uploadImage() async {
    if(_generatedImageUrl.isNotEmpty) {
      downloadedImage = await downloadImage(_generatedImageUrl);
    }
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('images/$_generatedImageName.jpg');
      UploadTask uploadTask = ref.putData(downloadedImage);
      await uploadTask.whenComplete(() {
        log('File uploaded successfully');
      });
      String downloadUrl = await ref.getDownloadURL();
      log('Download URL: $downloadUrl');
    } catch (e) {
      log('Error uploading image: $e');
    }
  }
  void _createRequest() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("request/$globalRequestIdSoloTrip");
    await ref.set({
      "status": "completed"
    });
  }
  Widget heartButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _generatedImageName = const Uuid().v4();
          uploadImage();
          _createResult();
          isPlanRequest = true;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const HomePage()));
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
            size: 40.0,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
  Widget itineraryButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
              //    builder: (context) =>
                //  const ItineraryPage()));
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
            Icons.place,
            size: 40.0,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
  void trimResult(){
    if(chatGptAnswer.contains("Itinerary")) {
      int idx = chatGptAnswer.indexOf("Itinerary");
      int idxBudgetSpending = chatGptAnswer.indexOf("Budget spending");
      parts = [
        chatGptAnswer.substring(0, idx).trim(),
        chatGptAnswer.substring(idx - 1).trim(),
        chatGptAnswer.substring(idxBudgetSpending-1)
      ];
    }
    else{
      parts[0] = "No result found";
      parts[1] = "Please try again";
    }
  }
  Future<bool> waitingForResult() async{
    String msg = getMessage();
    await chatGPTAPI(msg);
    img =
    "A realistic picture portraying a trip to $chatGptAnswer ,";
    await generateImage();
    return true;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: _title(),
    ),
    body: FutureBuilder<bool>(
          future: waitingForResultsFinished,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if(snapshot.hasData) {
              trimResult();
                 return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                        children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(_generatedImageUrl),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        itineraryButton(),
                                        Flexible(
                                          child: _countryAndCityText(),
                                        ),
                                      ],
                                    )
                                    //Text(parts[1]),
                                  ]
                              )
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                heartButton(),
                                refreshButton(),
                              ]
                          )
                        ]
                    )
    );
            }
    else {
      return  Scaffold(
          appBar: AppBar(
            title: _title(),
          ),
          body: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SpinKitCircle(
                    color: Colors.grey,
                    size: 70.0,
                  )
                ]
            ),
          ));
    }
  }
      ));
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }
  String getMessage(){
      String msg = "Can you tell me a country and a city separated with a comma, just like this:"
          " 'Rome,Italy', that would fit a budget of ${plan.getPlanBudget()} euro, for ${plan.days} days, "
          "from ${plan.town}. I want the destination to: ";
      if(plan.isShopping){msg = "$msg have places to go shopping,";}
      if(plan.isSwimming){msg = "$msg have beaches where you can swim close by,";}
      if(plan.isHistoricalHeritage){msg = "$msg have historical attractions,";}
      if(plan.isBigCity){msg = "$msg be a big city,";}
      if(plan.isTropical){msg = "$msg be a tropical place,";}
      if(plan.isNightlife){msg = "$msg have a wonderful nightlife with a lot of parties and fun,";}
      if(plan.isSkiing){msg = "$msg have mountains,";}
      if(plan.isNature){msg = "$msg have natural parks near by,";}
      if(plan.isUnique) {msg = "$msg is a unique place, not that popular as other destinations,";}
      if(plan.isPopular) {msg = "$msg is a popular destination,";}
      if(plan.isLuxury) {msg = "$msg is a luxury destination,";}
      if(plan.isCruises) {msg = "$msg go on a cruise,";}
      if(plan.isRomantic) {msg = "$msg is a romantic destination,";}
      if(plan.isThermalSpa) {msg = "$msg have a thermal spa,";}
      if(plan.isAdventure) {msg = "$msg have adventure activities,";}
      if(plan.isRelaxing) {msg = "$msg have relaxing activities,";}
      msg = "${msg}In this budget I want to include the transport plan (including the flight) and also the accommodation and travel expenses."
          " If the period is short please recommend something close. If the period is 7 or 10 days recommend a place far,"
          " but the budget to fit it. And in the next line I want a detailed itinerary for the trip, starting with the text Itinerary."
          " Next after the the itinerary on a next line please provide the detailed travel expenses, starting with the words: Budget spending."
          " For both I want the answer to be on the following line. Please exclude the $previousGeneratedResultsSoloTrip";
      return msg;
  }
}