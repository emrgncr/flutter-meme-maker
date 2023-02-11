import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meme_maker/add_popup_general.dart';
import 'package:meme_maker/generic_element.dart';
import 'package:meme_maker/imgflip_templates.dart';
import 'package:meme_maker/pair.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'emrgncr\'s mame maker',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        colorScheme: const ColorScheme.dark(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<int, Widget> elems = {};
  Map<int, MutablePair<ImageProvider, GenericElementStats>> elemData = {};
  List<int> idList = [];
  ImgflipAdapter? adapter;

  Widget generateElementFrame(int id) {
    if (!elems.containsKey(id) || elems[id] == null) {
      throw Exception("frames doesn't contain id $id");
    }

    return elems[id] as Widget;
  }

  List<Widget> getMainWidgets() {
    var ret = <Widget>[];
    for (int i in idList) {
      ret.add(generateElementFrame(i));
    }
    return ret;
  }

  void addNetPictureElementWrapper({
    required String imgUrl,
    GenericElementStats? stats,
  }) {
    Image img = Image.network(
      imgUrl,
    );
    addPictureElementWrapper(prov: img.image, stats: stats);
  }

  void addPictureElementWrapper({
    required ImageProvider prov,
    GenericElementStats? stats,
  }) {
    int maxid = idList.isEmpty
        ? -1
        : idList.reduce((value, element) => max(value, element));
    int id = maxid + 1;
    GenericElementStats stats1 = stats ?? GenericElementStats();
    stats1.onDelete = () => removeElementFromMap(id);
    stats1.onMove = (x, y) => onElementMove(id, x, y);
    stats1.onResize = (s) => onElementResize(id, s);
    stats1.onLayerShift = (c) => onElementLayerChange(id, c);
    stats1.onRotate = (p0) => onElementRotate(id, p0);
    Widget elem = GenericElement(
      id: id,
      imageProv: prov,
      key: UniqueKey(),
      stats: stats1,
    );
    setState(() {
      idList.add(id);
      elems.putIfAbsent(id, () => elem);
    });
    elemData.putIfAbsent(id, () => MutablePair(prov, stats1));
  }

  void addGenericImage(ImageProvider prov) {
    addPictureElementWrapper(
      stats: GenericElementStats(
        mult: 1,
        locx: (WidgetsBinding.instance.window.physicalSize.width /
                WidgetsBinding.instance.window.devicePixelRatio) /
            2,
        locy: (WidgetsBinding.instance.window.physicalSize.height /
                WidgetsBinding.instance.window.devicePixelRatio) /
            2,
        deletable: true,
        resizable: true,
        movable: true,
        layerShiftable: true,
        center: true,
        rotatable: true,
      ),
      prov: prov,
    );
  }

  void addGenericUrlImage(String imgurl) {
    addNetPictureElementWrapper(
      stats: GenericElementStats(
        mult: 1,
        locx: (WidgetsBinding.instance.window.physicalSize.width /
                WidgetsBinding.instance.window.devicePixelRatio) /
            2,
        locy: (WidgetsBinding.instance.window.physicalSize.height /
                WidgetsBinding.instance.window.devicePixelRatio) /
            2,
        deletable: true,
        resizable: true,
        movable: true,
        layerShiftable: true,
        center: true,
        rotatable: true,
      ),
      imgUrl: imgurl,
    );
  }

  @override
  void initState() {
    super.initState();
    adapter =
        ImgflipAdapter(addGenericUrlImage: addGenericUrlImage, pageCount: 1);
    //default images
    //   addGenericUrlImage(
    //       "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fpixel-creation.com%2Fwp-content%2Fuploads%2F113-kurumi-tokisaki-hd-wallpapers-background-images-wallpaper-abyss-1-800x800.png&f=1&nofb=1&ipt=e68e232772b16fa8629906a6a411d1276f4a3424cf5c6cf945e85056795b959f&ipo=images");
    //   addGenericUrlImage(
    //       "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fi.redd.it%2Fh6cxvyo43a841.png&f=1&nofb=1&ipt=51d0c5a0d8857fd381f13f8dfce77f51f2d45a412f2f0499044644753bdb9365&ipo=images");
  }

  void removeElementFromMap(int id) {
    elems.remove(id);
    setState(() {
      idList.remove(id);
    });
    elemData.remove(id);
  }

  void onElementResize(int id, double newmult) {
    if (elemData.containsKey(id)) {
      elemData[id]!.second.mult = newmult;
    }
  }

  void onElementMove(int id, double x, double y) {
    if (elemData.containsKey(id)) {
      elemData[id]!.second.locx = x;
      elemData[id]!.second.locy = y;
    }
  }

  void onElementRotate(int id, double rot) {
    if (elemData.containsKey(id)) {
      elemData[id]!.second.rotation =
          (elemData[id]!.second.rotation ?? 0) + rot;
    }
  }

  void onElementLayerChange(int id, int change) {
    if (!idList.contains(id)) return;
    //edge cases
    //start
    int idx = idList.indexOf(id);
    //bottom
    if (idx == 0 && change < 0) return;
    if (idx == idList.length - 1 && change > 0) return;

    setState(() {
      idList.removeAt(idx);
      idList.insert(idx + change, id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: idList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Please use the gear button to add images/text.")
                ],
              ),
            )
          : Stack(
              alignment: AlignmentDirectional.topStart,
              children: getMainWidgets(),
            ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => generalAddPopup(
                addGenericUrlImage,
                addGenericImage,
                () {
                  setState(() {
                    idList = [];
                    elemData = {};
                    elems = {};
                  });
                },
                idList,
                elemData,
                context,
                adapter: adapter,
              ),
          child: const Icon(Icons.settings)),
    );
  }
}
