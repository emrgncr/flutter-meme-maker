import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meme_maker/add_popup_general.dart';

class PopupUrlImage extends StatefulWidget {
  const PopupUrlImage({super.key, required this.onClick});

  final void Function(String url) onClick;

  @override
  createState() => _PopupUrlImageState();

  static Future<T?> testforConnection<T>(BuildContext context,
      {String? testurl}) async {
    //https://stackoverflow.com/questions/49648022/check-whether-there-is-an-internet-connection-available-on-flutter-app
    try {
      final result = await InternetAddress.lookup(testurl ?? "google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //connected
      }
      // ?
    } on SocketException catch (_) {
      //no connection
      return showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            title: Text("No Connection"),
            content: Text(
                "Please make sure that your device is conneced to the internet"),
          );
        },
      );
    }
    return null;
  }

  static Future<T?> showUrlPopup<T>(
      void Function(String) onClick, BuildContext context) async {
    final test = await PopupUrlImage.testforConnection(context);
    if (test != null) return test;
    return showDialog<T>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          contentPadding: const EdgeInsets.only(
            top: 10.0,
          ),
          title: const Text("Add image with url"),
          children: [
            PopupUrlImage(onClick: (s) {
              onClick(s);
              Navigator.pop(context);
            })
          ],
        );
      },
    );
  }
}

class _PopupUrlImageState extends State<PopupUrlImage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = "Enter image url";
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: .9,
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: _controller,
              ),
              MainPopup.padding,
              ElevatedButton(
                  onPressed: () => widget.onClick(_controller.text),
                  child: const Text("add")),
            ],
          ),
        ));
  }
}
