// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meme_maker/generate_img.dart';
import 'package:meme_maker/generic_element.dart';
import 'package:meme_maker/imgflip_templates.dart';
import 'package:meme_maker/info_popups.dart';
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

class MainPopup {
  static const padding = Padding(padding: EdgeInsets.symmetric(vertical: 4));

  static Future<T?> generalAddPopup<T>(
      void Function(String) onUrlClick,
      void Function(ImageProvider<Object>) onTextClick,
      void Function() onDelete,
      List<int> ids,
      Map<int, MutablePair<ImageProvider, GenericElementStats>> elemdata,
      BuildContext context,
      {OfflineAdapter? adapter}) async {
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
                  PopupUrlImage.showUrlPopup(onUrlClick, context);
                },
                child: const Text("Add image using url")),
            padding,
            ElevatedButton(
                onPressed: () {
                  // Navigator.pop(context);
                  if (adapter != null) {
                    // adapter.imgflipPopup(context);
                    adapter.suggestedPopup(context);
                    // adapter.getImages();
                  }
                },
                child: const Text("Add meme templates")),
            padding,
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  PopupTextImage.showPopupText(onTextClick, context);
                },
                child: const Text("Add text")),
            padding,
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  SaveImg.loadImageFromFile().then((provider) {
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
                  SaveImg.chooseAndSaveScratch(ids, elemdata);
                },
                child: const Text("Save")),
            padding,
            if (!kIsWeb && Platform.isAndroid)
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    SaveImg.shareImageScratch(ids, elemdata);
                  },
                  child: const Text("Share")),
            if (!kIsWeb && Platform.isAndroid) padding,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Dynamic Save Borders:"),
                DynamicCheckbox(
                    getVar: () => GenerateImg.dynamic_save_border,
                    setVar: (f) {
                      GenerateImg.dynamic_save_border = f;
                    })
              ],
            ),
            padding,
            /*
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => InfoPopups.infoPopup(context),
                  icon: const Icon(Icons.info_outline),
                  tooltip: "info button",
                ),
                //TODO: add a proper help button
                if (!kIsWeb && Platform.isAndroid)
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        SaveImg.shareImageScratch(ids, elemdata);
                      },
                      icon: Icon(Icons.share))
              ],
            ),
            padding
            */
          ],
        );
      },
    );
  }
}
