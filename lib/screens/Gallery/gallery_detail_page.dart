import 'package:BIBOL/models/gallery/gallery_model.dart';
import 'package:flutter/material.dart';

class GalleryDetailScreen extends StatelessWidget {
  final GalleryModel gallery;

  const GalleryDetailScreen({Key? key, required this.gallery})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('รายละเอียด'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _handleShare(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _handleDownload(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพแบบ Hero Animation
            Hero(
              tag: 'gallery_${gallery.id}',
              child:
                  gallery.photoFile.isNotEmpty
                      ? Image.network(
                        gallery.photoFile,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // หัวข้อ
                  Text(
                    gallery.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ข้อมูลเมตา
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetaItem(Icons.calendar_today, gallery.date),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey[400],
                        ),
                        _buildMetaItem(
                          Icons.visibility,
                          '${gallery.visits} ครั้ง',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // รายละเอียด
                  if (gallery.details.isNotEmpty) ...[
                    const Text(
                      'รายละเอียด',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _cleanHtmlText(gallery.details),
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  String _cleanHtmlText(String text) {
    return text
        .replaceAll('<br>', '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }
}
