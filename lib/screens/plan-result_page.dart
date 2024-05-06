import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myjorurney/screens/home_page.dart';
import 'package:myjorurney/screens/plan-trip_page.dart';
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
  final spinkit = SpinKitFadingCircle(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: index.isEven ? Colors.red : Colors.green,
        ),
      );
    },
  );

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

  Widget _backButton() {
    return BackButton(
      onPressed: () {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const PlanTripPage()));
        });
      },
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
        // plan.setPlanResult(resultMsg);
      },
      child: const Text('Add to wishlist'),
    );
  }

  Widget _tryAgainButton() {
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
      child: const Text('Try again'),
    );
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
      return Scaffold(
          appBar: AppBar(
            actions: [
              _backButton(),
            ],
            title: _title(),
          ),
          body: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(chatGptAnswer),
                    Image.network(_generatedImageUrl),
                    _addButton(),
                    _tryAgainButton()
                  ]
              )
          )
      );
    }
    else {
      return const Scaffold(
        body: Padding(
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
            days = "$days or 10";
          }
          else if(request[requestIndex].plan[i].isSeven && days.contains("7")){
            days = "$days or 7";
          }
          else if(request[requestIndex].plan[i].isThree && days.contains("3")){
            days = "$days or 3";
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
      msg = "${msg}In this budget I want to include the transport plan and also the accommodation and travel expenses. If the period is short please recommend something close. If the period is 7 or 10 days recommend a place far, but the budget to fit it. And in the next line I want an itinerary for the trip.";
      return msg;
  }
}