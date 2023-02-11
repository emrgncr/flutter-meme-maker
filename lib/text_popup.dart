import 'package:flutter/material.dart';
import 'package:meme_maker/add_popup_general.dart';
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
    _sizeController.text = "200";
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: .9,
        child: Center(
          child: Column(
            children: [
              const Text("Text:"),
              TextField(
                controller: _controller,
              ),
              padding,
              const Text("Text size:"),
              TextField(
                controller: _sizeController,
                keyboardType: TextInputType.number,
              ),
              padding,
              ElevatedButton(
                  onPressed: () =>
                      widget.onClick(_controller.text, _sizeController.text),
                  child: const Text("add")),
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
            double fontsize = double.tryParse(n) ?? 200;
            double shadowsize = 1.5 * fontsize / 64;
            WidgetToImage.widgetToImage(Text(
              s,
              textDirection: TextDirection.ltr,
              style:
                  TextStyle(fontSize: fontsize, color: Colors.white, shadows: [
                Shadow(
                    // bottomLeft
                    offset: Offset(-shadowsize, -shadowsize),
                    color: Colors.black),
                Shadow(
                    // bottomRight
                    offset: Offset(shadowsize, -shadowsize),
                    color: Colors.black),
                Shadow(
                    // topRight
                    offset: Offset(shadowsize, shadowsize),
                    color: Colors.black),
                Shadow(
                    // topLeft
                    offset: Offset(-shadowsize, shadowsize),
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
