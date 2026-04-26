import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // 🔧 Replace these with your actual Cloudinary credentials
  static const String _cloudName = 'donsgccnn';
  static const String _uploadPreset = 'campus_connect_uploads'; // paste here

  /// Uploads [imageFile] to Cloudinary and returns the secure URL.
  /// Returns null if the upload fails.
  static Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(body);
        return json['secure_url'] as String?;
      } else {
        print('Cloudinary upload failed: ${response.statusCode} $body');
        return null;
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}