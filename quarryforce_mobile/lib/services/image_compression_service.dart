import 'dart:io';
import 'package:image/image.dart' as img;
import '../utils/logger.dart';

/// Service for compressing and optimizing images
class ImageCompressionService {
  static final ImageCompressionService _instance =
      ImageCompressionService._internal();

  factory ImageCompressionService() {
    return _instance;
  }

  ImageCompressionService._internal();

  /// Default compression quality (0-100)
  static const int defaultQuality = 75;

  /// Maximum image width/height in pixels
  static const int maxImageDimension = 1920;

  /// Maximum file size in bytes (5 MB)
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// Compress an image file
  Future<File?> compressImage(
    File imageFile, {
    int quality = defaultQuality,
    int maxWidth = maxImageDimension,
    int maxHeight = maxImageDimension,
  }) async {
    try {
      final originalSize = await imageFile.length();
      AppLogger.debug(
          'Original image size: ${(originalSize / 1024).toStringAsFixed(2)} KB');

      // Read image
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        AppLogger.error('Failed to decode image');
        return null;
      }

      // Resize if necessary
      img.Image processedImage = originalImage;
      if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
        processedImage = img.copyResize(
          originalImage,
          width: maxWidth,
          height: maxHeight,
          interpolation: img.Interpolation.linear,
        );
        AppLogger.debug(
            'Resized image to ${processedImage.width}x${processedImage.height}');
      }

      // For JPEG-like compression, encode as JPEG
      final compressedBytes = img.encodeJpg(processedImage, quality: quality);

      // Create a new file for the compressed image
      final compressedFile = File(imageFile.path)
        ..writeAsBytesSync(compressedBytes, flush: true);

      final compressedSize = compressedBytes.length;
      final compressionRatio =
          ((1 - (compressedSize / originalSize)) * 100).toStringAsFixed(1);

      AppLogger.info(
          'Image compressed: ${(compressedSize / 1024).toStringAsFixed(2)} KB ($compressionRatio% reduction)');

      return compressedFile;
    } catch (e) {
      AppLogger.error('Failed to compress image', e);
      return null;
    }
  }

  /// Compress image with automatic quality adjustment
  Future<File?> compressImageAuto(File imageFile) async {
    try {
      int quality = defaultQuality;
      File? result = await compressImage(imageFile, quality: quality);

      // If result is still too large, reduce quality
      while (result != null) {
        final fileSize = await result.length();

        if (fileSize <= maxFileSizeBytes) {
          AppLogger.info('Image compressed to acceptable size');
          return result;
        }

        quality -= 5;
        if (quality < 10) {
          AppLogger.warning('Could not compress image below size limit');
          return result;
        }

        result = await compressImage(imageFile, quality: quality);
      }

      return result;
    } catch (e) {
      AppLogger.error('Failed to auto-compress image', e);
      return null;
    }
  }

  /// Get image dimensions
  Future<Size?> getImageDimensions(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return null;
      }

      return Size(
        width: image.width.toDouble(),
        height: image.height.toDouble(),
      );
    } catch (e) {
      AppLogger.error('Failed to get image dimensions', e);
      return null;
    }
  }

  /// Get image file size in KB
  Future<double> getImageSizeKB(File imageFile) async {
    try {
      final bytes = await imageFile.length();
      return bytes / 1024;
    } catch (e) {
      AppLogger.error('Failed to get image size', e);
      return 0;
    }
  }

  /// Check if image needs compression
  Future<bool> needsCompression(File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      return fileSize > maxFileSizeBytes;
    } catch (e) {
      AppLogger.error('Failed to check if image needs compression', e);
      return false;
    }
  }

  /// Batch compress multiple images
  Future<List<File>> batchCompressImages(List<File> imageFiles) async {
    try {
      final compressedImages = <File>[];

      for (final imageFile in imageFiles) {
        final compressed = await compressImageAuto(imageFile);
        if (compressed != null) {
          compressedImages.add(compressed);
        }
      }

      AppLogger.info('Batch compressed ${compressedImages.length} images');
      return compressedImages;
    } catch (e) {
      AppLogger.error('Failed to batch compress images', e);
      return [];
    }
  }
}

/// Simple Size class for image dimensions
class Size {
  final double width;
  final double height;

  Size({required this.width, required this.height});

  @override
  String toString() =>
      '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}';
}
