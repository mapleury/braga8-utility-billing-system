import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageContainerProofComponent extends StatelessWidget {
  final String? currentImageUrl;
  final String? previousImageUrl;

  const ImageContainerProofComponent({
    super.key,
    this.currentImageUrl,
    this.previousImageUrl,
  });

  // Helper to fetch images safely as bytes to avoid CanvasKit crashes
  Future<Uint8List?> _getImageBytes(String? url) async {
    if (url == null || url.isEmpty) return null;
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json', // Avoids Laravel redirecting to /login
        },
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      debugPrint("Image Fetch Failed: Status ${response.statusCode} for $url");
    } catch (e) {
      debugPrint("Error fetching bytes: $e");
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
                        Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
                        SizedBox(height: 4),
                        Text("No Data", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  )
                : FutureBuilder<Uint8List?>(
                    // Using the URL as a key ensures the future restarts when the URL changes
                    key: ValueKey(imageUrl), 
                    future: _getImageBytes(imageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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

                      // Fallback for broken links or server 404s
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: Colors.redAccent, size: 30),
                            SizedBox(height: 4),
                            Text("Load Error", style: TextStyle(fontSize: 10, color: Colors.redAccent)),
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