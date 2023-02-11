import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlparser;
import 'package:meme_maker/add_popup_general.dart';

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
    print("a");
    if (templateURLs.isEmpty) {
      templateURLs = await getUrls();
    }
    print(templateURLs);

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

class ElevatedImageButton extends StatefulWidget {
  const ElevatedImageButton(
      {super.key, required this.baseurl, required this.onClick});
  final String baseurl;
  final void Function(String) onClick;

  @override
  createState() => _ElevatedImageButtonState();
}

class _ElevatedImageButtonState extends State<ElevatedImageButton> {
  String? url;

  @override
  void initState() {
    super.initState();
    url = "${widget.baseurl}.jpg";
    ImgflipAdapter.getRealUrl(widget.baseurl).then((value) => setState(
          () {
            url = value;
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: .3,
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
          child: url != null ? Image.network(url!) : null),
    );
  }
}
