import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/home_page.dart';
import 'package:myjorurney/screens/plan-trip_page.dart';
import 'package:provider/provider.dart';
import '../data/globals.dart';
import '../services/api_constants.dart';
import '../services/chat-provider.dart';
import '../services/models-provider.dart';
import '../widgets/chat_widget.dart';
import '../widgets/text_widget.dart';
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
      print(_generatedImageUrl);
    } else {
      // Handle API error
      print('Error generating image: ${response.reasonPhrase}');
    }
  }

  Future<void> showResult(ModelsProvider modelsProvider, ChatProvider chatProvider) async {
    await sendMessageFCT(
    modelsProvider: modelsProvider,
    chatProvider: chatProvider);
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
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    if(resultDisplayed == false) {
      showResult(modelsProvider, chatProvider);
      resultDisplayed = true;
    }
    return Scaffold(
    appBar: AppBar(
      actions: [
        _backButton(),
      ],
      title: _title(),
    ),
      body: Expanded(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: chatProvider.getChatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatProvider
                          .getChatList[index].msg,
                      chatIndex: chatProvider.getChatList[index]
                          .chatIndex,
                      shouldAnimate:
                      chatProvider.getChatList.length - 1 == index,
                    );
                  }
              ),
            ),
            if (_generatedImageUrl.isNotEmpty)
              Image.network(_generatedImageUrl),
            _addButton(),
            _tryAgainButton()
          ],
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
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
      img ="A realistic picture portraying a trip to ${chatProvider
          .getChatList[0].msg} ";
      generateImage();
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
}