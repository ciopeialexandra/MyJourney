import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/auth.dart';
import 'package:myjorurney/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? errorMessage = '';
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> createUserWithEmailAndPassword() async {
    try {
      // Attempt to create user account
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      // If successful, clear any previous error message
      setState(() {
        errorMessage = '';
      });
    } on FirebaseAuthException catch (e) {
      // If an error occurs, update errorMessage with the error message
      setState(() {
        errorMessage = e.message;
      });
    }
  }
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
  Widget _errorMessage(){
    return Text(errorMessage == '' ?'' : 'Humm ? $errorMessage ');
  }
  void _createUser() async{
    String name = _controllerName.text;
    String email = _controllerEmail.text;
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("user/$userId");
    await ref.set({
      "name": name,
      "email":email,
      "friends": {
      },
    });
  }
  Widget _submitButton(){
    return ElevatedButton(
        onPressed: () async {
          // Wait for the registration process to complete
          await createUserWithEmailAndPassword();

          // After registration, check if there's no error message
          // and navigate to HomePage
          if(errorMessage == '') {
            _createUser();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }
        },
        child: const Text('Register')
    );
  }
  Widget _loginOrRegisterButton(){
    return ElevatedButton(
      onPressed: (){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const LoginPage()));
    },
      child: const Text('Login instead'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _entryField('name', _controllerName),
            _entryField('email', _controllerEmail),
            _entryField('password', _controllerPassword),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton()
          ],
        ),
      ),
    );
  }
}
