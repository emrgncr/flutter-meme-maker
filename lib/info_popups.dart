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
                  child: const Text(
                      'This app allows you to scale, rotate images, composite them on top of each other and add texts/captions.\n'),
                )
              ],
            ));
  }
}
