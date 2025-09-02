import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

class ResizeHelper {
  Uint8List resizeJpeg(Uint8List input, int maxw, int maxH, int quality) {
    final original = img.decodeImage(input);
    final norm = img.bakeOrientation(original!);

    // Center-crop to square
    final minSide = math.min(norm.width, norm.height);
    final cropX = ((norm.width - minSide) / 2).round();
    final cropY = ((norm.height - minSide) / 2).round();
    final square =
        img.copyCrop(norm, x: cropX, y: cropY, width: minSide, height: minSide);

    // Resize to final avatar size
    final resized = img.copyResize(
      square,
      width: maxw,
      height: maxH,
      interpolation: img.Interpolation.cubic,
    );

    return Uint8List.fromList(
      img.encodeJpg(resized, quality: quality),
    );
  }
}
