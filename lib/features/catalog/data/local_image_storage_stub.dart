import 'package:cross_file/cross_file.dart';

import 'local_image_storage.dart';

Future<LocalStoredImage> saveLocalImage(XFile image) async {
  return LocalStoredImage(path: image.path);
}
