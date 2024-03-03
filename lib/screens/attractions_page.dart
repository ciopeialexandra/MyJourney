
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'images_page.dart';


class AttractionsPage extends StatefulWidget {
  const AttractionsPage({super.key});

  @override
  State<AttractionsPage> createState() => _AttractionsPageState();
}
final TextEditingController _attractionsAnswer = TextEditingController();
class _AttractionsPageState extends State<AttractionsPage> {

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
                  const ImagesPage()));
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
          TyperAnimatedText('Which attractions have you visited?'),
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
                  _entryField('Your answer', _attractionsAnswer),
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