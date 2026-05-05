import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ImageContainerProofComponent extends StatelessWidget {
  final String? currentImageUrl;
  final String? previousImageUrl;

  const ImageContainerProofComponent({
    super.key,
    this.currentImageUrl,
    this.previousImageUrl,
  });

  // ── Use Dio so ngrok-skip-browser-warning header is included ──────────────
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'ngrok-skip-browser-warning': 'true',
      'Accept': 'image/*',
    },
  ));

  Future<Uint8List?> _getImageBytes(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data!);
      }
      debugPrint("Image Fetch Failed: Status ${response.statusCode} for $url");
    } catch (e) {
      debugPrint("Error fetching image bytes: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildImageWrapper("Current Reading", currentImageUrl),
        const SizedBox(width: 12),
        _buildImageWrapper("Previous Reading", previousImageUrl),
      ],
    );
  }

  Widget _buildImageWrapper(String label, String? imageUrl) {
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            clipBehavior: Clip.antiAlias,
            child: !hasImage
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 30),
                        SizedBox(height: 4),
                        Text("No Data",
                            style:
                                TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  )
                : FutureBuilder<Uint8List?>(
                    key: ValueKey(imageUrl),
                    future: _getImageBytes(imageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF723CFF),
                          ),
                        );
                      }

                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      }

                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                color: Colors.redAccent, size: 30),
                            SizedBox(height: 4),
                            Text("Load Error",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.redAccent)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}