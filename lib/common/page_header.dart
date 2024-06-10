import 'dart:developer';

import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.3,
      child: SimpleMap(
        instructions: SMapWorld.instructions,
        defaultColor: Colors.grey,
        colors: const SMapWorldColors(
            uS: Colors.purple,
            cN: Colors.pink,
            iN: Colors.purple,
            bF: Colors.yellowAccent,
            aR: Colors.blueAccent,
            nA: Colors.red,
            bL: Colors.orange,
            aO: Colors.orange,
            aL: Colors.white,
            rO: Colors.red,
            rU: Colors.green,
            aU: Colors.yellow,
            aN: Colors.red,
            eG: Colors.cyanAccent,
            lI: Colors.red,
            cA: Colors.blue,
            tN: Colors.pinkAccent,
            mA: Colors.lightGreen
        ).toMap(),
        callback: (id, name, tapDetails) {
          log(id);
        },
      ),
    );
  }
}
