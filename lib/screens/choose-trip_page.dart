import 'package:flutter/material.dart';

class ChooseTripPage extends StatefulWidget {
  const ChooseTripPage({super.key});

  @override
  State<ChooseTripPage> createState() => _ChooseTripPageState();
}

class _ChooseTripPageState extends State<ChooseTripPage> {
  List<String> cardList = ["Card 1", "Card 2", "Card 3", "Card 4", "Card 5"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Swipe Cards Demo"),
      ),
      body: Center(
        child: Stack(
          children: cardList.map((card) {
            int index = cardList.indexOf(card);
            return Dismissible(
              key: Key(card),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {
                setState(() {
                  cardList.removeAt(index);
                });
                if (direction == DismissDirection.endToStart) {
                  // Handle left swipe
                  print("Swiped left on card $index");
                } else if (direction == DismissDirection.startToEnd) {
                  // Handle right swipe
                  print("Swiped right on card $index");
                }
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.center,
                child: const Icon(Icons.thumb_down, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.green,
                alignment: Alignment.center,
                child: const Icon(Icons.thumb_up, color: Colors.white),
              ),
              child: Card(
                child: Center(
                  child: Text(
                    card,
                    style: const TextStyle(fontSize: 24.0),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
