
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'attractions_page.dart';


class TownPage extends StatefulWidget {
  const TownPage({super.key});

  @override
  State<TownPage> createState() => _TownPageState();
}

class _TownPageState extends State<TownPage> {
  final TextEditingController _controllerAnswer = TextEditingController();

  Widget _title(){
    return const Text("My Journey");
  }
  Widget _entryField(
      String title,
      TextEditingController controller
      ){
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: title
      ),
    );
  }
  Widget _nextButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const AttractionsPage()));
        });
      },
      child: const Text('Next'),
    );
  }
  Widget _animatedText(){
    return DefaultTextStyle(
      style: const TextStyle(
          fontSize: 40.0,
          color: Colors.black
      ),
      child: AnimatedTextKit(
        animatedTexts : [
          TyperAnimatedText('Which city have you visited?'),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child:Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 70),
                  _animatedText(),
                  const SizedBox(height: 100),
                  _entryField('Your answer', _controllerAnswer),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                child:_nextButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

