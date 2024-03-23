
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:myjorurney/data/globals.dart';
import 'package:myjorurney/widgets/text_widget.dart';
import '../data/constants.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget(
      {super.key,
        required this.msg,
        required this.chatIndex,
        this.shouldAnimate = false});

  final String msg;
  final int chatIndex;
  final bool shouldAnimate;
  @override
  Widget build(BuildContext context) {
    resultMsg = msg;
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image.asset(
                //   chatIndex == 0
                //       ? AssetsManager.userImage
                //       : AssetsManager.botImage,
                //   height: 30,
                //   width: 30,
                // ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: chatIndex == 0
                      ? TextWidget(
                    label: msg,
                  )
                      : shouldAnimate
                      ? DefaultTextStyle(
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16),
                    child: AnimatedTextKit(
                        isRepeatingAnimation: false,
                        repeatForever: false,
                        displayFullTextOnTap: true,
                        totalRepeatCount: 1,
                        animatedTexts: [
                          TyperAnimatedText(
                            msg.trim(),
                          ),
                        ]),
                  )
                      : Text(
                    msg.trim(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16),
                  ),
                ),
                chatIndex == 0
                    ? const SizedBox.shrink()
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
