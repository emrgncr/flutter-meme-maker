import 'package:flutter/material.dart';
import 'package:meme_maker/add_popup_general.dart';

class PopupUrlImage extends StatefulWidget {
  const PopupUrlImage({super.key, required this.onClick});

  final void Function(String url) onClick;

  @override
  createState() => _PopupUrlImageState();
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
              padding,
              ElevatedButton(
                  onPressed: () => widget.onClick(_controller.text),
                  child: const Text("add")),
            ],
          ),
        ));
  }
}

Future<T?> showUrlPopup<T>(
    void Function(String) onClick, BuildContext context) async {
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
