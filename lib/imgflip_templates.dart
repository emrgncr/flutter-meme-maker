import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlparser;
import 'package:meme_maker/add_popup_general.dart';
import 'package:meme_maker/url_popup.dart';
import 'package:string_similarity/string_similarity.dart';

class StaticAssets {
  static List<String> assetUrls = [];

  static Future<List<String>> getImages() async {
    var assets = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> json = jsonDecode(assets);
    // print(json);
    List<String> ret = json.keys
        .where((element) =>
            element.startsWith("assets/meme_templates/meme_") &&
            element.endsWith(".jpg"))

        // .map((e) => json[e])
        .toList(growable: false);
    return ret;
  }

  static setup() {
    getImages().then((value) => assetUrls = value);
  }
}

class ImgflipAdapter {
  ImgflipAdapter(
      {List<String>? templateURLs,
      this.pageCount = 1,
      required this.addGenericUrlImage}) {
    this.templateURLs = templateURLs ?? [];
  }

  late List<String> templateURLs;
  int pageCount;
  final void Function(String) addGenericUrlImage;

  static bool isUriNumbered(String uri) {
    var parts = uri.split("/");
    if (parts.isEmpty) return true;
    if (parts.length < 4) return false;
    return true;
  }

  static Future<String?> getRealUrl(String baseurl) async {
    const toTry = [".jpg", ".png"];
    for (var fix in toTry) {
      http.Response response = await http.get(Uri.parse(baseurl + fix));
      if (response.statusCode > 199 && response.statusCode < 300) {
        return baseurl + fix;
      }
    }
    return null;
  }

  Future<List<String>> getUrls() async {
    List<String> finalList = [];
    for (int page = 0; page < pageCount; page++) {
      String baseUrl = page == 0
          ? "https://imgflip.com/memetemplates"
          : "https://imgflip.com/memetemplates?page=$page";
      http.Response response = await http.get(Uri.parse(baseUrl));
      // I am too lazy to do this properly
      var doc = htmlparser.parse(response.bodyBytes);
      var mainList = doc.querySelectorAll(".mt-img-wrap");
      for (var elem in mainList) {
        if (elem.children.isEmpty) continue;
        var node = elem.children[0];
        if (!node.attributes.containsKey("href")) continue;
        var uri = node.attributes["href"]!;
        //TODO add support for numbered urls as well
        if (isUriNumbered(uri)) continue;
        var lastpart = uri.split("/").last;
        var finalurl = "https://imgflip.com/s/meme/$lastpart";
        finalList.add(finalurl);
      }
    }
    return finalList;
  }

  List<Widget> getChildren(BuildContext context) {
    List<Widget> ret = [];
    for (var uri in templateURLs) {
      ret.add(ElevatedImageButton(baseurl: uri, onClick: addGenericUrlImage));
      ret.add(const Padding(padding: EdgeInsets.symmetric(vertical: 8)));
    }
    return ret;
  }

  Future<T?> imgflipPopup<T>(BuildContext context) async {
    const String testurl = "imgflip.com";

    final test =
        await PopupUrlImage.testforConnection(context, testurl: testurl);
    if (test != null) return test;

    if (templateURLs.isEmpty) {
      templateURLs = await getUrls();
    }
    if (kDebugMode) {
      print(templateURLs);
    }

    return showDialog<T>(
        context: context,
        builder: ((context) {
          return SimpleDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              contentPadding: const EdgeInsets.only(
                top: 10.0,
                bottom: 2,
                left: 8,
                right: 8,
              ),
              title: const Text("Templates"),
              children: getChildren(context));
        }));
  }
}

class OfflineAdapter {
  const OfflineAdapter({required this.addGenericUrlImage});

  final void Function(String) addGenericUrlImage;

  Future<List<String>> getImages() async {
    var assets = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> json = jsonDecode(assets);
    // print(json);
    List<String> ret = json.keys
        .where((element) =>
            element.startsWith("assets/meme_templates/meme_") &&
            element.endsWith(".jpg"))

        // .map((e) => json[e])
        .toList(growable: false);
    return ret;
  }

  List<Widget> getChildren(BuildContext context, List<String> urls) {
    List<Widget> ret = [];
    for (var uri in urls) {
      ret.add(ElevatedImageButton(
          baseurl: uri, onClick: addGenericUrlImage, offline: true));
      ret.add(const Padding(padding: EdgeInsets.symmetric(vertical: 8)));
    }
    return ret;
  }

  Future<T?> suggestedPopup<T>(BuildContext context) async {
    var res = await showSearch(
        context: context,
        delegate: OfflineDelegate(addGenericUrlImage: addGenericUrlImage));
    if (res != null) {
      addGenericUrlImage(res);
    }
  }

  Future<T?> imgflipPopup<T>(BuildContext context) async {
    print("aa");
    List<String> imageLocs = StaticAssets.assetUrls;
    print("hh");
    if (kDebugMode) {
      print(imageLocs);
    }

    return showDialog<T>(
        context: context,
        builder: ((context) {
          return SimpleDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              contentPadding: const EdgeInsets.only(
                top: 10.0,
                bottom: 2,
                left: 8,
                right: 8,
              ),
              title: const Text("Templates"),
              children: getChildren(context, imageLocs));
        }));
  }
}

class OfflineDelegate extends SearchDelegate<String?> {
  OfflineDelegate({required this.addGenericUrlImage});

  final void Function(String) addGenericUrlImage;
  List<String> possibleSuggestions =
      StaticAssets.assetUrls.toList(growable: false);

  static String removeComp(String s1) {
    const st = "assets/meme_templates/meme_";
    int i1 = st.length;
    int i2 = ".jpg".length;
    print(s1);
    s1 = s1.substring(i1, s1.length - i2).replaceAll("-", " ");
    return s1;
  }

  int compareBySimilarity(String s1, String s2, String arg) {
    s1 = removeComp(s1);
    s2 = removeComp(s2);

    int sim1 = (StringSimilarity.compareTwoStrings(s1, arg) * 100).toInt();
    int sim2 = (StringSimilarity.compareTwoStrings(s2, arg) * 100).toInt();
    return sim2 - sim1;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    possibleSuggestions.sort((s1, s2) => compareBySimilarity(s1, s2, query));

    return _SuggestionList(
        suggestions: possibleSuggestions.sublist(0, 8),
        istext: false,
        query: query,
        onSelected: (s1) {
          close(context, s1);
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    possibleSuggestions.sort((s1, s2) => compareBySimilarity(s1, s2, query));

    return _SuggestionList(
        suggestions: possibleSuggestions.sublist(0, 10),
        istext: true,
        query: query,
        onSelected: (s1) {
          query = s1;
          showResults(context);
        });
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList(
      {required this.suggestions,
      required this.query,
      required this.onSelected,
      required this.istext});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;
  final bool istext;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: istext
          ? (BuildContext context, int i) {
              final String suggestion = suggestions[i];
              return ListTile(
                leading: query.isEmpty
                    ? const Icon(Icons.history)
                    : const Icon(null),
                title: Text(OfflineDelegate.removeComp(suggestion)),
                onTap: () {
                  onSelected(suggestion);
                },
              );
            }
          : (BuildContext context, int i) {
              final String suggestion = suggestions[i];
              return Column(
                children: [
                  const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                  ElevatedImageButton(
                    baseurl: suggestion,
                    onClick: onSelected,
                    offline: true,
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                ],
              );
            },
    );
  }
}

class ElevatedImageButton extends StatefulWidget {
  const ElevatedImageButton(
      {super.key,
      required this.baseurl,
      required this.onClick,
      this.offline = false});
  final String baseurl;
  final void Function(String) onClick;
  final bool offline;

  @override
  createState() => _ElevatedImageButtonState();
}

class _ElevatedImageButtonState extends State<ElevatedImageButton> {
  String? url;

  @override
  void initState() {
    super.initState();
    if (!widget.offline) {
      ImgflipAdapter.getRealUrl(widget.baseurl).then((value) => setState(
            () {
              url = value;
            },
          ));
    } else {
      url = widget.baseurl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: .7,
      child: ElevatedButton(
          onPressed: () {
            if (url != null) {
              widget.onClick(url!);
            }
            Navigator.pop(context);
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.deepPurple),
          ),
          child: url != null
              ? (widget.offline ? Image.asset(url!) : Image.network(url!))
              : null),
    );
  }
}
