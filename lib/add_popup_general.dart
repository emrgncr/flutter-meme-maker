// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:meme_maker/generate_img.dart';
import 'package:meme_maker/generic_element.dart';
import 'package:meme_maker/imgflip_templates.dart';
import 'package:meme_maker/pair.dart';
import 'package:meme_maker/save_image.dart';
import 'package:meme_maker/text_popup.dart';
import 'package:meme_maker/url_popup.dart';

class DynamicCheckbox extends StatefulWidget {
  const DynamicCheckbox(
      {super.key,
      this.initial_state = false,
      required this.getVar,
      required this.setVar});

  final bool initial_state;
  final bool Function() getVar;
  final void Function(bool) setVar;

  @override
  State<DynamicCheckbox> createState() => _DynamicCheckboxState();
}

class _DynamicCheckboxState extends State<DynamicCheckbox> {
  bool cur_state = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      cur_state = widget.getVar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
        value: cur_state,
        onChanged: (f) => setState(() {
              widget.setVar(f ?? false);
              cur_state = f ?? false;
            }));
  }
}

const padding = Padding(padding: EdgeInsets.symmetric(vertical: 4));

Future<T?> generalAddPopup<T>(
    void Function(String) onUrlClick,
    void Function(ImageProvider<Object>) onTextClick,
    void Function() onDelete,
    List<int> ids,
    Map<int, MutablePair<ImageProvider, GenericElementStats>> elemdata,
    BuildContext context,
    {ImgflipAdapter? adapter}) async {
  return showDialog<T>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        contentPadding: const EdgeInsets.only(
          top: 10.0,
          bottom: 2,
          left: 8,
          right: 8,
        ),
        title: const Text("Options"),
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showUrlPopup(onUrlClick, context);
              },
              child: const Text("Add image using url")),
          padding,
          ElevatedButton(
              onPressed: () {
                // Navigator.pop(context);
                if (adapter != null) {
                  adapter.imgflipPopup(context);
                }
              },
              child: const Text("Add meme templates")),
          padding,
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showPopupText(onTextClick, context);
              },
              child: const Text("Add text")),
          padding,
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                loadImageFromFile().then((provider) {
                  if (provider != null) {
                    onTextClick(provider);
                  }
                });
              },
              child: const Text("Load Image")),
          padding,
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              child: const Text("Reset Canvas")),
          padding,
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                chooseAndSaveScratch(ids, elemdata);
              },
              child: const Text("Save")),
          padding,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Dynamic Save Borders:"),
              DynamicCheckbox(
                  getVar: () => dynamic_save_border,
                  setVar: (f) {
                    dynamic_save_border = f;
                  })
            ],
          ),
          padding,
        ],
      );
    },
  );
}
