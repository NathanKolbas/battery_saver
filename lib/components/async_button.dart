import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that shows a [CircularProgressIndicator] while an async task is in progress.
///
/// Both the button text and onPressed function are required. For [successText] and
/// [failText] to work you must return a [bool] value of true when the function is
/// successful and false when not. The widget will handle the rest.
class AsyncButton extends StatefulWidget {
  const AsyncButton({
    Key? key,
    required this.text,
    required this.press,
    this.successText,
    this.failText,
  }) : super(key: key);

  final String text;
  final Future Function() press;
  final String? successText;
  final String? failText;

  @override
  AsyncButtonBuilder createState() => AsyncButtonBuilder();
}

class AsyncButtonBuilder extends State<AsyncButton> {
  String text = '';
  late Widget textWidget;
  late Future Function() press;
  String? successText;
  String? failText;

  onPressed() {
    setState(() {
      textWidget = const CircularProgressIndicator(color: Colors.white,);
    });

    press().then((success) {
      if (successText != null && success) {
        buildTextWithTimer(successText!);
      } else if (failText != null && !success) {
        buildTextWithTimer(failText!);
      } else {
        buildText(text);
      }
    });
  }

  void buildText(String text) {
    textWidget =  Text(
      text,
      key: UniqueKey(),
      style: const TextStyle(color: Colors.white, fontSize: 18.0,),
    );

    setState(() {});
  }

  void buildTextWithTimer(String text) {
    buildText(text);
    Timer(const Duration(seconds: 2), () => buildText(this.text));
  }

  @override
  void initState() {
    super.initState();
    text = widget.text;
    buildText(text);
    press = widget.press;
    successText = widget.successText;
    failText = widget.failText;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 54.0,
        minWidth: double.infinity,
      ),
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return TextButton(
              onPressed: () => onPressed(),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: textWidget,
              ),
            );
          }
      ),
    );
  }
}
