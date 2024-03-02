import 'package:flutter/material.dart';
import 'package:myjorurney/auth.dart';
import 'package:myjorurney/screens/login_page.dart';
import 'package:myjorurney/screens/home_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChange,
        builder: (context,snapshot){
          if(snapshot.hasData){
            return const HomePage();
          }
          else{
            return const LoginPage();
          }
        },
    );
  }
}


