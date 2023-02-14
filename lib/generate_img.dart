// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meme_maker/generic_element.dart';
import 'package:meme_maker/pair.dart';
import "dart:math" as math;
import 'package:image/image.dart' as img;

class GenerateImg {
  static Future<ImageInfo> getImageSize(ImageProvider<Object> x) async {
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

  static bool dynamic_save_border = true;
  static bool gif_support = false;
  static double min_resolution = 1080;

  static Future<img.Image> generateImage(
      List<int> ids,
      Map<int, MutablePair<ImageProvider, GenericElementStats>>
          elemData) async {
    Map<int, math.MutableRectangle<double>> coords = {};
    for (int i in ids) {
      var t = await getCoords(elemData[i]!.first, elemData[i]!.second);
      coords.putIfAbsent(i, () => t);
    }
    //get the big image

    math.MutableRectangle<double> main = math.MutableRectangle<double>(
        0, 0, window.physicalSize.width, window.physicalSize.height);

    if (dynamic_save_border) {
      main = math.MutableRectangle<double>(
          coords.values.first.left,
          coords.values.first.top,
          coords.values.first.width,
          coords.values.first.height);
      for (var i in coords.values) {
        if (i.left < main.left) main.left = i.left;
        if (i.right > main.right) main.width = i.right - main.left;
        if (i.top < main.top) main.top = i.top;
        if (i.bottom > main.bottom) main.height = i.bottom - main.top;
      }
    }

    double enchancer_mult = 1;

    if (math.min(main.width, main.height) < min_resolution) {
      enchancer_mult = min_resolution / math.min(main.width, main.height);
    }

    //for gif support
    //TODO GIF support
    Map<int, ImageInfo> infos = {};
    // int maxframes = 1;
    for (int i in ids) {
      ImageProvider prov = elemData[i]!.first;
      var t = await getImageSize(prov);
      infos.putIfAbsent(i, () => t);
    }

    var image = img.Image(
        width: (main.width * enchancer_mult).toInt(),
        height: (main.height * enchancer_mult).toInt());
    for (int i in ids) {
      GenericElementStats stats = elemData[i]!.second;
      var rect = coords[i]!;
      ImageInfo data = infos[i]!;
      var bdt = await data.image.toByteData();
      var img2 = img.Image.fromBytes(
          width: data.image.width,
          height: data.image.height,
          bytes: bdt!.buffer,
          numChannels: 4);

      double osx = img2.width.toDouble() * stats.mult;
      double osy = img2.height.toDouble() * stats.mult;

      var img3 = img.copyRotate(img2, angle: stats.rotation ?? 0);

      double nsx = img3.width.toDouble() * stats.mult;
      double nsy = img3.height.toDouble() * stats.mult;

      img3 = img.copyResize(img3,
          width: (img3.width.toDouble() * stats.mult * enchancer_mult).toInt(),
          height:
              (img3.height.toDouble() * stats.mult * enchancer_mult).toInt());

      double shiftx = 0; //(nsx - osx) / 2;
      double shifty = 0; //(nsy - osy) / 2;

      img.compositeImage(
        image, img3,
        srcX: 0,
        srcY: 0,
        // dstH: image.height,
        // dstW: image.width,
        // srcW: img3.width,
        // srcH: img3.height,
        dstX: ((rect.left - main.left - shiftx) * enchancer_mult).toInt(),
        dstY: ((rect.top - main.top - shifty) * enchancer_mult).toInt(),
      );
    }
    // img.encodePngFile("/home/emrgncr/Pictures/test.png", image);
    return image;
  }

  static Future<math.MutableRectangle<double>> getCoords(
      ImageProvider prov, GenericElementStats stats) async {
    double locx = stats.locx ?? 0;
    double locy = stats.locy ?? 0;
    locx += StaticUtil.outerPadding.left;
    locy += StaticUtil.outerPadding.top;
    ImageInfo info = await getImageSize(prov);
    double mult = stats.mult;
    var sizex = info.image.width * mult;
    var sizey = info.image.height * mult;

    // recalculate size and loc for rotated image

    var aside = sizex;
    var bside = sizey;

    var angle = stats.rotation ?? 0;

    while (angle < 0) {
      angle += 180;
    }
    while (angle > 180) {
      angle -= 180;
    }
    if (angle > 90) {
      angle -= 90;
      var tmp = aside;
      aside = bside;
      bside = tmp;
    }

    var sina = math.sin(angle * math.pi / 180);
    var cosa = math.cos(angle * math.pi / 180);

    var newa = (aside * cosa) + (bside * sina);
    var newb = (bside * cosa) + (aside * sina);

    var xdiff = newa - sizex;
    var ydiff = newb - sizey;

    locx -= xdiff / 2;
    locy -= ydiff / 2;

    print("$locx, $locy, $newa, $newb");

    return math.MutableRectangle<double>(locx, locy, newa, newb);
  }
}
