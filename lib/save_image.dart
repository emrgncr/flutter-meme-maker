import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:image/image.dart' as img;
import 'package:meme_maker/generate_img.dart';
import 'package:meme_maker/generic_element.dart';
import 'package:meme_maker/pair.dart';
import 'package:permission_handler/permission_handler.dart';

void saveImage(String filepath, img.Image image) {
  img.encodePngFile(filepath, image);
}

Future<void> saveImageScratch(String filepath, List<int> ids,
    Map<int, MutablePair<ImageProvider, GenericElementStats>> elemData) async {
  saveImage(filepath, await generateImage(ids, elemData));
}

void chooseAndSaveScratch(List<int> ids,
    Map<int, MutablePair<ImageProvider, GenericElementStats>> elemData) async {
  chooseLocAndSaveImage(await generateImage(ids, elemData));
}

Future<bool> getSavePermissions() async {
  var status = await Permission.storage.request();
  if (status.isGranted) {
    return true;
  }
  if (kDebugMode) {
    print("status not granted");
  }
  return false;
}

void chooseLocAndSaveImage(img.Image image) async {
  if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    String? filepath;
    filepath = await chooseSaveLocationWebDesktop();
    if (filepath == null) {
      if (kDebugMode) {
        print("invalid filepath");
      }
      return;
    }
    saveImage(filepath, image);
    return;
  } else if (Platform.isAndroid || Platform.isIOS) {
    if (!(await getSavePermissions())) return;
    final filepath = await chooseSaveLocationAndroid();
    // ignore: unused_local_variable
    final finalPath = await FlutterFileDialog.saveFileToDirectory(
      directory: filepath!,
      data: img.encodeJpg(image, quality: 80),
      mimeType: "image/jpeg",
      fileName: "mememaker_image",
      replace: false,
    );
  }
}

Future<String?> chooseSaveLocationWebDesktop() async {
  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Where to save:',
    fileName: 'mememaker_image.png',
    type: FileType.image,
  );
  return outputFile;
}

Future<DirectoryLocation?> chooseSaveLocationAndroid() async {
  if (!await FlutterFileDialog.isPickDirectorySupported()) {
    if (kDebugMode) {
      print("Picking directory not supported");
    }
    return null;
  }
  final pickedDirectory = await FlutterFileDialog.pickDirectory();
  return pickedDirectory;
}

Future<ImageProvider?> loadImageFromFileAndroid() async {
  if (!(await getSavePermissions())) return null;
  const params = OpenFileDialogParams(
    dialogType: OpenFileDialogType.image,
    sourceType: SourceType.photoLibrary,
  );
  final filePath = await FlutterFileDialog.pickFile(params: params);
  if (filePath == null) return null;
  Image i = Image.file(File(filePath));
  return i.image;
}

Future<ImageProvider?> loadImageFromFileDesktop() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Choose an image to load",
      allowMultiple: false,
      type: FileType.image);
  if (result == null) return null;
  if (result.files.single.path == null) return null;
  File file = File(result.files.single.path!);
  Image i = Image.file(file);
  return i.image;
}

Future<ImageProvider?> loadImageFromFile() async {
  if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    return loadImageFromFileDesktop();
  } else if (Platform.isAndroid || Platform.isIOS) {
    // return loadImageFromFileAndroid();
    if (!(await getSavePermissions())) return null;
    return loadImageFromFileDesktop();
  } else {
    return null;
  }
}
