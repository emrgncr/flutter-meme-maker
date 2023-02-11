import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

Future<ImageInfo> getImageSize(ImageProvider<Object> x) async {
  Completer<ImageInfo> comp = Completer<ImageInfo>();
  var res = x.resolve(ImageConfiguration.empty);
  var listener = ImageStreamListener(
    (image, synchronousCall) {
      try {
        comp.complete(image);
      } catch (err) {
        print("I guess error because of gif, ignore maybe");
      }
    },
  );
  res.addListener(listener);
  comp.future.then((value) => res.removeListener(listener));

  return comp.future;
}

GenericElement netImageElement({
  required String imgUrl,
  required int id,
  GenericElementStats? stats,
}) {
  Image img = Image.network(
    imgUrl,
  );
  return GenericElement(
    imageProv: img.image,
    id: id,
    stats: stats ?? GenericElementStats(),
  );
}

class GenericElementStats {
  GenericElementStats({
    this.deletable = false,
    this.onDelete,
    this.resizable = false,
    this.onResize,
    this.editable = false,
    this.onEdit,
    this.movable = false,
    this.onMove,
    this.mult = 1,
    this.locx,
    this.locy,
    this.layerShiftable = false,
    this.onLayerShift,
    this.center = false,
    this.rotatable = false,
    this.onRotate,
    this.rotation,
  });

  bool deletable;
  bool resizable;
  bool editable;
  bool movable;
  bool layerShiftable;
  bool rotatable;

  bool center;

  double mult;

  double? locx;
  double? locy;
  double? rotation;

  void Function()? onDelete;
  void Function(double)? onResize;
  void Function(Map<String, dynamic>)? onEdit;
  void Function(double, double)? onMove;
  void Function(int)? onLayerShift;
  void Function(double)? onRotate;

  @override
  String toString() {
    return """State:
    deletable: $deletable, resizable: $resizable,
    editable: $editable, movable: $movable,
    layerShiftablr: $layerShiftable, mult: $mult,
    locx: $locx, locy: $locy""";
  }
}

final defaultStats = GenericElementStats();

class GenericElement extends StatefulWidget {
  const GenericElement(
      {super.key, this.stats, required this.id, required this.imageProv});

  final GenericElementStats? stats;
  final ImageProvider<Object> imageProv;
  final int id;

  @override
  State<StatefulWidget> createState() => _GenericElementState();
}

const double iconSize = 36;
const double additionalPad = 12;
const EdgeInsets outerPadding =
    EdgeInsets.fromLTRB(iconSize + (2 * additionalPad), 0, 0, 0);
final totalPadW = outerPadding.left + outerPadding.right;
final totalPadH = outerPadding.top + outerPadding.bottom;

// ignore: constant_identifier_names
const double sizeup_amn = 0.05;
const int buttonCount = 7;
const double minH = buttonCount * (iconSize + (2 * additionalPad));
const double minW = (iconSize + (2 * additionalPad));

Widget sideButton(IconData icon, Color color, double xShift, double yShift,
    dynamic Function() onClick) {
  return Positioned(
    left: 0 + xShift,
    top: 0 + yShift,
    width: iconSize + (2 * additionalPad),
    height: iconSize + (2 * additionalPad),
    child: IconButton(
      onPressed: () {
        onClick();
      },
      padding: const EdgeInsetsDirectional.all(additionalPad),
      icon: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
    ),
  );
}

class _GenericElementState extends State<GenericElement> {
  double sizex = 0;
  double sizey = 0;
  double mult = 1;
  double basemult = 1;

  double rotation = 0;

  double locx = 0;
  double locy = 0;

  bool showButtons = false;

  ImageProvider? prv;

  late GenericElementStats stats;

  void changeLoc(double x, double y) {
    setState(() {
      locx += x;
      locy += y;
    });
  }

  void changeMult(double x) {
    setState(() {
      mult += x;
    });
  }

  void setShowButtons(bool x) {
    setState(() {
      showButtons = x;
    });
  }

  void changeRotation(double x) {
    setState(() {
      rotation += x;
    });
  }

  @override
  void initState() {
    super.initState();
    stats = widget.stats ?? GenericElementStats();
    mult = stats.mult;
    locx = stats.locx ?? 0;
    locy = stats.locy ?? 0;
    prv = widget.imageProv;
    rotation = stats.rotation ?? 0;
    getImageSize(widget.imageProv).then((value) {
      //calculate sizex sizey
      sizex = value.image.width.toDouble();
      sizey = value.image.height.toDouble();
      //get screen size
      final mediaQueryData = MediaQuery.of(context);
      final winW = mediaQueryData.size.width;
      final winH = mediaQueryData.size.height;

      if (sizex > winW) {
        basemult = (winW - 10) / (sizex * 1.5);
      }
      if (sizey > winH) {
        basemult = min(basemult, (winH - 10) / (sizey * 1.5));
      }
      widget.stats?.onResize!(basemult);
      setState(() {
        mult = basemult;
        sizex = value.image.width.toDouble();
        sizey = value.image.height.toDouble();
        //center the location
        if (stats.center) {
          locx -= max((sizex * mult) + totalPadW, minW) / 2;
          locy -= max((sizey * mult) + totalPadH, minH) / 2;
          widget.stats?.center = false;
        }
        widget.stats?.onMove!(locx, locy);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: locx,
        top: locy,
        width: max((sizex * mult) + totalPadW, minW),
        height: max((sizey * mult) + totalPadH, minH),
        child: SizedBox(
            width: max((sizex * mult) + totalPadW, minW),
            height: max((sizey * mult) + totalPadH, minH),
            child: Stack(
              alignment: AlignmentDirectional.topStart,
              children: [
                Positioned(
                  left: totalPadW,
                  top: totalPadH,
                  width: sizex * mult,
                  height: sizey * mult,
                  child: GestureDetector(
                    child: DottedBorder(
                      color: Colors.yellow[200] ?? Colors.yellow,
                      dashPattern: [showButtons ? 10 : 1],
                      strokeWidth: showButtons ? 7 : 0,
                      padding: const EdgeInsets.all(1),
                      child: Transform(
                        transform: Matrix4.translationValues(
                            sizex * mult / 2, sizey * mult / 2, 0)
                          ..rotateZ(rotation * pi / 180)
                          ..translate(-sizex * mult / 2, -sizey * mult / 2, 0),
                        child: SizedBox(
                          width: sizex * mult,
                          height: sizey * mult,
                          child: Image(
                            image: prv ?? widget.imageProv,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    onLongPress: () => setShowButtons(true),
                    onTap: () => setShowButtons(false),
                    // Move if highligted
                    onPanUpdate: (details) {
                      if (showButtons && stats.movable) {
                        double dx = details.delta.dx;
                        double dy = details.delta.dy;
                        changeLoc(dx, dy);
                        if (stats.onMove != null) {
                          stats.onMove!(locx + dx, locy + dy);
                        }
                      }
                    },
                  ),
                ),
                if (showButtons && stats.deletable)
                  // Delete button
                  sideButton(Icons.delete, Colors.red, 0, 0, () {
                    if (stats.deletable && stats.onDelete != null) {
                      stats.onDelete!();
                    }
                  }),
                if (showButtons && stats.resizable)
                  // Size up button
                  sideButton(Icons.arrow_circle_up, Colors.yellow, 0,
                      1 * (iconSize + (2 * additionalPad)), () {
                    if (stats.resizable) {
                      double s = sizeup_amn * basemult;
                      if (mult + s > (10 * basemult)) {
                        s = ((10 * basemult) - mult);
                      }
                      if (stats.onResize != null) {
                        stats.onResize!(mult + s);
                      }
                      changeMult(s); //positive for scale up

                    }
                  }),
                if (showButtons && stats.resizable)
                  // Size down button
                  sideButton(Icons.arrow_circle_down, Colors.yellow, 0,
                      2 * (iconSize + (2 * additionalPad)), () {
                    if (stats.resizable) {
                      double s = sizeup_amn * basemult;
                      if ((mult - s) < (.1 * basemult)) {
                        s = (mult - (.1 * basemult));
                      }
                      if (stats.onResize != null) {
                        stats.onResize!(mult - s);
                      }
                      changeMult(-s); //positive for scale up

                    }
                  }),
                if (showButtons && stats.rotatable)
                  // Rotate up Button
                  sideButton(Icons.rotate_right, Colors.purple, 0,
                      3 * (iconSize + (2 * additionalPad)), () {
                    changeRotation(15);
                    if (stats.rotatable && stats.onRotate != null) {
                      stats.onRotate!(15);
                    }
                  }),
                if (showButtons && stats.rotatable)
                  // Rotate down Button
                  sideButton(Icons.rotate_left, Colors.purple, 0,
                      4 * (iconSize + (2 * additionalPad)), () {
                    changeRotation(-15);
                    if (stats.rotatable && stats.onRotate != null) {
                      stats.onRotate!(-15);
                    }
                  }),
                if (showButtons && stats.layerShiftable)
                  // Layer up Button
                  sideButton(Icons.keyboard_double_arrow_up, Colors.green, 0,
                      5 * (iconSize + (2 * additionalPad)), () {
                    if (stats.layerShiftable && stats.onLayerShift != null) {
                      stats.onLayerShift!(1);
                    }
                  }),
                if (showButtons && stats.layerShiftable)
                  // Layer down Button
                  sideButton(Icons.keyboard_double_arrow_down, Colors.green, 0,
                      6 * (iconSize + (2 * additionalPad)), () {
                    if (stats.layerShiftable && stats.onLayerShift != null) {
                      stats.onLayerShift!(-1);
                    }
                  }),
              ],
            )));
  }
}
