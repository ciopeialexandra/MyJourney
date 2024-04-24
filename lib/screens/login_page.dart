import 'package:flutter/material.dart';
import 'package:myjorurney/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myjorurney/screens/register_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async{
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }
  Widget _title(){
    return const Text("My journey");
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
  Widget _submitButton(){
    return ElevatedButton(
        onPressed: signInWithEmailAndPassword,
        child: const Text('Login')
    );
  }
  Widget _loginOrRegisterButton(){
    return ElevatedButton(
        onPressed: (){
          setState(() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                    const RegisterPage()));
          });
        },
        child: const Text('Register instead' ),
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
