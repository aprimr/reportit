import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MediaService {
  final ImagePicker _picker = ImagePicker();

  // Capture photo using Camera and return compressed image
  Future<XFile?> captureImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return null;

      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.absolute.path,
        'COMPRESSED_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compress image
      final XFile? compressedImage =
          await FlutterImageCompress.compressAndGetFile(
            image.path,
            targetPath,
            quality: 80,
            minWidth: 1000,
            minHeight: 1000,
            format: CompressFormat.jpeg,
          );

      return compressedImage ?? image;
    } catch (e) {
      return null;
    }
  }

  // Pick single image from Gallery and return compressed image
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.absolute.path,
        'COMPRESSED_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compress image
      final XFile? compressedImage =
          await FlutterImageCompress.compressAndGetFile(
            image.path,
            targetPath,
            quality: 85,
            minWidth: 1200,
            minHeight: 1200,
            format: CompressFormat.jpeg,
          );
      return compressedImage ?? image;
    } catch (e) {
      return null;
    }
  }
}
