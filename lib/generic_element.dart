import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:meme_maker/generate_img.dart';

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

class StaticUtil {
  static const double iconSize = 36;
  static const double additionalPad = 12;
  static const EdgeInsets outerPadding =
      EdgeInsets.fromLTRB(iconSize + (2 * additionalPad), 0, 0, 0);
  static final totalPadW = outerPadding.left + outerPadding.right;
  static final totalPadH = outerPadding.top + outerPadding.bottom;

// ignore: constant_identifier_names
  static const double sizeup_amn = 0.05;
  static const int buttonCount = 7;
  static const double minH = buttonCount * (iconSize + (2 * additionalPad));
  static const double minW = (iconSize + (2 * additionalPad));

  static Widget sideButton(IconData icon, Color color, double xShift,
      double yShift, dynamic Function() onClick) {
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

  static Widget sideButton2(IconData icon, Color color, double _, double __,
      dynamic Function() onClick) {
    return IconButton(
      onPressed: () {
        onClick();
      },
      padding: const EdgeInsetsDirectional.all(additionalPad),
      icon: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
    );
  }

  static final defaultStats = GenericElementStats();
}

class GenericElement extends StatefulWidget {
  const GenericElement(
      {super.key, this.stats, required this.id, required this.imageProv});

  final GenericElementStats? stats;
  final ImageProvider<Object> imageProv;
  final int id;

  @override
  State<StatefulWidget> createState() => _GenericElementState();

  static GenericElement netImageElement({
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
    GenerateImg.getImageSize(widget.imageProv).then((value) {
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
          locx -=
              max((sizex * mult) + StaticUtil.totalPadW, StaticUtil.minW) / 2;
          locy -=
              max((sizey * mult) + StaticUtil.totalPadH, StaticUtil.minH) / 2;
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
        width: max((sizex * mult) + StaticUtil.totalPadW, StaticUtil.minW),
        height: max((sizey * mult) + StaticUtil.totalPadH, StaticUtil.minH),
        child: SizedBox(
            width: max((sizex * mult) + StaticUtil.totalPadW, StaticUtil.minW),
            height: max((sizey * mult) + StaticUtil.totalPadH, StaticUtil.minH),
            child: Stack(
              alignment: AlignmentDirectional.topStart,
              children: [
                Positioned(
                  // image
                  left: StaticUtil.totalPadW,
                  top: StaticUtil.totalPadH,
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
                SizedBox(
                  width: StaticUtil.totalPadW,
                  height: (sizey * mult) + StaticUtil.totalPadH,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (showButtons && stats.deletable)
                          // Delete button
                          StaticUtil.sideButton(Icons.delete, Colors.red, 0, 0,
                              () {
                            if (stats.deletable && stats.onDelete != null) {
                              stats.onDelete!();
                            }
                          }),
                        if (showButtons && stats.resizable)
                          // Size up button
                          StaticUtil.sideButton(
                              Icons.arrow_circle_up,
                              Colors.yellow,
                              0,
                              1 *
                                  (StaticUtil.iconSize +
                                      (2 * StaticUtil.additionalPad)), () {
                            if (stats.resizable) {
                              double s = StaticUtil.sizeup_amn * basemult;
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
                          StaticUtil.sideButton(
                              Icons.arrow_circle_down,
                              Colors.yellow,
                              0,
                              2 *
                                  (StaticUtil.iconSize +
                                      (2 * StaticUtil.additionalPad)), () {
                            if (stats.resizable) {
                              double s = StaticUtil.sizeup_amn * basemult;
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
                          StaticUtil.sideButton(
                              Icons.rotate_right,
                              Colors.purple,
                              0,
                              3 *
                                  (StaticUtil.iconSize +
                                      (2 * StaticUtil.additionalPad)), () {
                            changeRotation(15);
                            if (stats.rotatable && stats.onRotate != null) {
                              stats.onRotate!(15);
                            }
                          }),
                        if (showButtons && stats.rotatable)
                          // Rotate down Button
                          StaticUtil.sideButton(
                              Icons.rotate_left,
                              Colors.purple,
                              0,
                              4 *
                                  (StaticUtil.iconSize +
                                      (2 * StaticUtil.additionalPad)), () {
                            changeRotation(-15);
                            if (stats.rotatable && stats.onRotate != null) {
                              stats.onRotate!(-15);
                            }
                          }),
                        if (showButtons && stats.layerShiftable)
                          // Layer up Button
                          StaticUtil.sideButton(
                              Icons.keyboard_double_arrow_up,
                              Colors.green,
                              0,
                              5 *
                                  (StaticUtil.iconSize +
                                      (2 * StaticUtil.additionalPad)), () {
                            if (stats.layerShiftable &&
                                stats.onLayerShift != null) {
                              stats.onLayerShift!(1);
                            }
                          }),
                        if (showButtons && stats.layerShiftable)
                          // Layer down Button
                          StaticUtil.sideButton(
                              Icons.keyboard_double_arrow_down,
                              Colors.green,
                              0,
                              6 *
                                  (StaticUtil.iconSize +
                                      (2 * StaticUtil.additionalPad)), () {
                            if (stats.layerShiftable &&
                                stats.onLayerShift != null) {
                              stats.onLayerShift!(-1);
                            }
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }
}
