import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'local_image_storage.dart';

Future<LocalStoredImage> saveLocalImage(XFile image) async {
  final root = await getApplicationDocumentsDirectory();
  final directory = Directory(path.join(root.path, 'product-images'));
  await directory.create(recursive: true);
  final extension = path.extension(image.name).isEmpty
      ? '.jpg'
      : path.extension(image.name);
  final filename = 'product_${DateTime.now().microsecondsSinceEpoch}$extension';
  final destination = File(path.join(directory.path, filename));
  await destination.writeAsBytes(await image.readAsBytes(), flush: true);
  return LocalStoredImage(path: destination.path);
}
