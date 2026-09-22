import 'package:cross_file/cross_file.dart';

import 'local_image_storage_stub.dart'
    if (dart.library.io) 'local_image_storage_io.dart'
    if (dart.library.html) 'local_image_storage_web.dart';

class LocalStoredImage {
  const LocalStoredImage({required this.path});
  final String path;
}

abstract final class LocalImageStorage {
  static Future<LocalStoredImage> save(XFile image) => saveLocalImage(image);
}
