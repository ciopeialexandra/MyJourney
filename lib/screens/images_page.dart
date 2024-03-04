import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/globals.dart';
import 'home_page.dart';
import 'package:uuid/uuid.dart';

class ImagesPage extends StatefulWidget {
  const ImagesPage({super.key});
  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  XFile? image;
  final ImagePicker picker = ImagePicker();
  var uuid = const Uuid().v1();
  void _createTrip() async{
    User? user = FirebaseAuth.instance.currentUser;
     String? userId = user?.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("trip/$uuid");
      await ref.set({
        "userId": userId,
        "country": trip.getTripCountry(),
        "city": trip.getTripCity(),
        "attractions": {
          "attraction": trip.getTripAttraction()
        },
        "images":{
          "image": trip.getTripImage()
        }
      });
  }

  void _setTrip(){
    trip.setTripImage(image!.name);
  }
  //we can upload image from camera or from gallery based on parameter
  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    setState(() {
      image = img;

    });
  }
  void uploadImage() async{
    final storageRef = FirebaseStorage.instance.ref();
    final String imageName = trip.getTripImage();
    final imagesRef = storageRef.child("images/$imageName");
    try {
      await imagesRef.putFile(File(image!.path));
    } on Exception catch (e) {
      print("Error upload image");
    }
  }
  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Please choose media to select'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);

                    },
                    child: const Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
  Widget _title(){
    return const Text("My Journey");
  }
  Widget _nextButton() {
    return ElevatedButton(
      onPressed: () {
        _setTrip();
        _createTrip();
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const HomePage()));
        });
        uploadImage();
      },
      child: const Text('Done'),
    );
  }
  Widget _addImageButton() {
    return ElevatedButton(
      onPressed: () {
        myAlert();
      },
      child: const Text('Upload'),
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
          TyperAnimatedText('Add images from your trip'),
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
                  _addImageButton(),
                  image != null
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(image!.path),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                      ),
                    ),
                  )
                      : const Text(
                    "No Image",
                    style: TextStyle(fontSize: 20),
                  )
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