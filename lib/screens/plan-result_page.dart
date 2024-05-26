import 'dart:convert';
import 'dart:developer';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myjorurney/screens/home_page.dart';
import '../data/globals.dart';
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

  @override
  void initState() {
    _listScrollController = ScrollController();
    focusNode = FocusNode();
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
      log ('An internal error occurred');
    } catch (e) {
      log (e.toString());
    }
  }

  Widget _title() {
    return const Text('My Journey');
  }

  Widget refreshButton() {
      return TextButton(
        onPressed: () {
          setState(() {
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
  Widget heartButton() {
    return TextButton(
      onPressed: () {
        setState(() {
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
    int idx = chatGptAnswer.indexOf("Itinerary");
    parts = [chatGptAnswer.substring(0,idx).trim(), chatGptAnswer.substring(idx+1).trim()];
  }
  Future<void> waitingForResult() async{
    String msg = getMessage();
    await chatGPTAPI(msg);
    img =
    "A realistic picture portraying a trip to $chatGptAnswer ";
    await generateImage();
}

  @override
  Widget build(BuildContext context) {
    if (resultDisplayed == false) {
      resultDisplayed = true;
      waitingForResult();
    }
    if (_generatedImageUrl.isNotEmpty && chatGptAnswer.isNotEmpty) {
      trimResult();
      return Scaffold(
          appBar: AppBar(
            title: _title(),
          ),
          body:
          Padding(
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
                            _countryAndCityText(),
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
            ),
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

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }
  String getMessage(){
      String msgRequest = "";
      String days = "";
      String destination = "";
      String msg = "Can you tell me a country and a city separated with a comma, just like this: 'Italy,Rome', that would fit a budget of ${plan.getPlanBudget()} euro, for $days days, from $destination. I want the destination to: $msgRequest";
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
      if(plan.isNightlife && !msgRequest.contains("night")){
        msg = "$msg, have a nice nightlife ";
      }
      if(plan.isSkiing && !msgRequest.contains("mountains")){
        msg = "$msg have mountains ";
      }
      if(plan.isNature && !msgRequest.contains("nature")){
        msg = "$msg be a lot of nature ";
      }
      if(plan.isUnique && !msgRequest.contains("unique")) {
        msgRequest = "$msgRequest is a unique place ,";
      }
      if(plan.isPopular && !msgRequest.contains("popular")) {
        msgRequest = "$msgRequest is a popular destination ,";
      }
      if(plan.isLuxury && !msgRequest.contains("luxury")) {
        msgRequest = "$msgRequest is a luxury destination,";
      }
      if(plan.isCruises && !msgRequest.contains("cruises")) {
        msgRequest = "$msgRequest go on a cruise,";
      }
      if(plan.isRomantic && !msgRequest.contains("romantic")) {
        msgRequest = "$msgRequest is a romantic destination ,";
      }
      if(plan.isThermalSpa && !msgRequest.contains("thermal")) {
        msgRequest = "$msgRequest have a thermal spa ,";
      }
      if(plan.isAdventure && !msgRequest.contains("adventure")) {
        msgRequest = "$msgRequest have adventure activities ,";
      }
      if(plan.isRelaxing && !msgRequest.contains("relax")) {
        msgRequest = "$msgRequest have relaxing activities ,";
      }
      if(plan.isGroupTravel && !msgRequest.contains("group")) {
        msgRequest = "$msgRequest is recommended for a group travel ,";
      }
      if(plan.isSoloTravel && !msgRequest.contains("solo")) {
        msgRequest = "$msgRequest is recommended for a solo travel ,";
      }
      msg = "${msg}In this budget I want to include the transport plan and also the accommodation and travel expenses. If the period is short please recommend something close. If the period is 7 or 10 days recommend a place far, but the budget to fit it. And in the next line I want an itinerary for the trip.";
      return msg;
  }
}