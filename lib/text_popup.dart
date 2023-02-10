import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:widget_to_image/widget_to_image.dart';

class PopupTextImage extends StatefulWidget {
  const PopupTextImage({super.key, required this.onClick});

  final void Function(String url, String size) onClick;

  @override
  createState() => _PopupTextImageState();
}

class _PopupTextImageState extends State<PopupTextImage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = "Enter text";
    _sizeController.text = "64";
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: .9,
        child: Center(
          child: Column(
            children: [
              Text("Text:"),
              TextField(
                controller: _controller,
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 4)),
              Text("Text size:"),
              TextField(
                controller: _sizeController,
                keyboardType: TextInputType.number,
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 4)),
              ElevatedButton(
                  onPressed: () =>
                      widget.onClick(_controller.text, _sizeController.text),
                  child: Text("add")),
            ],
          ),
        ));
  }
}

Future<T?> showPopupText<T>(
    void Function(ImageProvider<Object>) onClick, BuildContext context) async {
  return showDialog<T>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        contentPadding: const EdgeInsets.only(
          top: 10.0,
        ),
        title: const Text("Add text as image"),
        children: [
          PopupTextImage(onClick: (s, n) {
            WidgetToImage.widgetToImage(Text(
              s,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                  fontSize: double.tryParse(n) ?? 64,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                        // bottomLeft
                        offset: Offset(-1.5, -1.5),
                        color: Colors.black),
                    Shadow(
                        // bottomRight
                        offset: Offset(1.5, -1.5),
                        color: Colors.black),
                    Shadow(
                        // topRight
                        offset: Offset(1.5, 1.5),
                        color: Colors.black),
                    Shadow(
                        // topLeft
                        offset: Offset(-1.5, 1.5),
                        color: Colors.black),
                  ]),
            )).then((value) {
              var i = Image.memory(value.buffer.asUint8List());
              onClick(i.image);
            });

            Navigator.pop(context);
          })
        ],
      );
    },
  );
}
