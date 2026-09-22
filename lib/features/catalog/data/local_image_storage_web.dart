import 'package:cross_file/cross_file.dart';

import 'local_image_storage.dart';

/// Le navigateur ne permet pas d’écrire dans le dossier assets du projet.
/// Le blob reste utilisable pour l’aperçu de la session courante.
Future<LocalStoredImage> saveLocalImage(XFile image) async {
  return LocalStoredImage(path: image.path);
}
