import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data/globals.dart';
import '../services/chat-provider.dart';
import '../services/models-provider.dart';
import '../widgets/chat_widget.dart';
import '../widgets/text_widget.dart';
import 'add-friend_page.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();}

class _ChatScreenState extends State<ChatScreen> {

  late ScrollController _listScrollController;
  late FocusNode focusNode;
  bool resultDisplayed = false;
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
                const AddFriendPage()));
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
        plan.setPlanResult(resultMsg);
        _createPlan();
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
      body: SafeArea(
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
      String msg = "Can you tell me in which travel destination can someone go with a budget of ${plan.getPlanBudget()} euro, 7 days";
      if(plan.isShopping){
        msg = "$msg, for shopping ";
      }
      if(plan.isSwimming){
        msg = "$msg, for going to the seaside ";
      }
      if(plan.isHistoricalHeritage){
        msg = "$msg for visiting historical attractions ";
      }
      if(plan.isBigCity){
        msg = "$msg for visiting a big city ";
      }
      await chatProvider.sendMessageAndGetAnswers(
          msg: msg, chosenModelId: modelsProvider.getCurrentModel);
      setState(() {});
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