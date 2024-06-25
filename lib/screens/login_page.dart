import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myjorurney/screens/register_page.dart';

import '../common/custom_form_button.dart';
import '../common/custom_input_field.dart';
import '../common/page_header.dart';
import '../common/page_heading.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  String email = "";
  String password = "";
  final Key _emailKey = const Key('emailKey');
  final Key _passwordKey = const Key('passwordKey');
  final _loginFormKey = GlobalKey<FormState>();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: Column(
          children: [
            const PageHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20),),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        const PageHeading(title: 'Log-in',),
                        CustomInputField(
                            key:_emailKey,
                            labelText: 'Email',
                            hintText: 'Your email',
                            validator: (textValue) {
                              if(textValue == null || textValue.isEmpty) {
                                return 'Email is required!';
                              }
                              if(!EmailValidator.validate(textValue)) {
                                return 'Please enter a valid email';
                              }
                              email = textValue;
                              return null;
                            }
                        ),
                        const SizedBox(height: 16,),
                        CustomInputField(
                          key:_passwordKey,
                          labelText: 'Password',
                          hintText: 'Your password',
                          obscureText: true,
                          suffixIcon: true,
                          validator: (textValue) {
                            if(textValue == null || textValue.isEmpty) {
                              return 'Password is required!';
                            }
                            password = textValue;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16,),
                        const SizedBox(height: 20,),
                        CustomFormButton(innerText: 'Login', onPressed: _handleLoginUser,),
                        const SizedBox(height: 18,),
                        SizedBox(
                          width: size.width * 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Don\'t have an account ? ', style: TextStyle(fontSize: 13, color: Color(0xff939393), fontWeight: FontWeight.bold),),
                              GestureDetector(
                                onTap: () => {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()))
                                },
                                child: const Text('Sign-up', style: TextStyle(fontSize: 15, color: Color(0xff748288), fontWeight: FontWeight.bold),),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLoginUser() {
    // login user
    if (_loginFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting data..')),
      );
      signInWithEmailAndPassword();
      if(errorMessage!.isNotEmpty)
        {
           SnackBar(content: Text(errorMessage.toString()));
        }
    }
  }
}