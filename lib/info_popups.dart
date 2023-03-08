import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPopups {
  static Future<T?> infoPopup<T>(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) => AboutDialog(
              applicationName: "About emrgncr's meme maker",
              children: [
                const Text(
                    softWrap: true,
                    'First of all, thanks for using my app!\n\n'
                    'For adding meme templates you need an active internet connection.\n'
                    'That is because the app parses imgflip at runtime and collects meme templates from there.\n'
                    'That is also the reason of the time it takes for the meme templates to load the first time that button is clicked.'
                    '\n\n'
                    'The source code of this app can be found on my github.\n'
                    'For any recommendations, problems and bug reports, you can use there:'),
                TextButton(
                  onPressed: () => launchUrl(Uri.parse(
                      "https://github.com/emrgncr/flutter-meme-maker")),
                  child: const Text(
                    "github.com/emrgncr/flutter-meme-maker",
                  ),
                )
              ],
            ));
  }

  static Future<T?> helpPopup<T>(BuildContext context) async {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var aspectRatio = MediaQuery.of(context).size.aspectRatio;
    double popupWidth = aspectRatio < 1 ? width * .8 : width * .4;
    return showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              contentPadding: const EdgeInsets.all(16),
              title: const Text("Help"),
              children: [
                SizedBox(
                  width: popupWidth,
                  height: (height * .7) - 80,
                  child: SingleChildScrollView(
                    child: RichText(
                        text: const TextSpan(children: [
                      TextSpan(text: "Use buttons in the settings "),
                      WidgetSpan(child: Icon(Icons.settings)),
                      TextSpan(text: """
 tab to add included meme templates, text or load images from your device.

Long press on the added images to activate edit mode. 
Single tap on the image to deactivate edit mode.
While they are in edit mode you can move/scale/rotate using gestures or buttons on the left side.
Double tap on the image to fix the rotation to a multiple of 30 degrees.

You can also change their layers relative to eachother using the green buttons on the left.
You can delete added images usign the trash button or you can reset the whole canvas using the button in the settings tab.

When your image is done, you can save the image locally in your device or share it with your friends using other apps.

Functions of buttons:

"""),
                      WidgetSpan(
                          child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                      TextSpan(text: ": Deletes the current image\n"),
                      WidgetSpan(
                          child: Icon(
                        Icons.arrow_circle_up,
                        color: Colors.yellow,
                      )),
                      WidgetSpan(
                          child: Icon(
                        Icons.arrow_circle_down,
                        color: Colors.yellow,
                      )),
                      TextSpan(text: ": Change the size of the image\n"),
                      WidgetSpan(
                          child: Icon(
                        Icons.rotate_left,
                        color: Colors.purple,
                      )),
                      WidgetSpan(
                          child: Icon(
                        Icons.rotate_right,
                        color: Colors.purple,
                      )),
                      TextSpan(text: ": Rotate the image\n"),
                      WidgetSpan(
                          child: Icon(
                        Icons.keyboard_double_arrow_up,
                        color: Colors.green,
                      )),
                      WidgetSpan(
                          child: Icon(
                        Icons.keyboard_double_arrow_down,
                        color: Colors.green,
                      )),
                      TextSpan(text: ": Change the layer of the image\n\n"),
                      TextSpan(
                          text:
                              "Dynamic Save Borders: If this setting is on, when saving the image, the app will try to guess the corners of the image.\nIf this setting is off, the image will be cropped at your screen's borders."),
                    ])),
                  ),
                )
              ],
            ));
  }
}
