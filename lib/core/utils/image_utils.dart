import 'package:tapto/core/api/api_endpoint.dart';

/// Utility class for image URL handling
class ImageUtils {
  /// Get the full image URL from a path
  /// 
  /// If the path already contains http/https, returns as-is
  /// If the path starts with /, prepends the API base URL
  /// Otherwise returns the path as-is
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // If already a full URL, return as-is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // If it starts with /, prepend the API base URL
    if (imagePath.startsWith('/')) {
      return '${ApiEndpoints.baseUrl}$imagePath';
    }

    // Otherwise return as-is
    return imagePath;
  }
}
