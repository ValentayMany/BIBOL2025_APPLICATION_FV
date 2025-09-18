// widgets/banner_overlay_widget.dart
import 'package:flutter/material.dart';
import '../models/Banner_Models.dart';

class BannerOverlayWidget extends StatelessWidget {
  final BannerModel banner;
  final bool showIndicators;

  const BannerOverlayWidget({
    Key? key,
    required this.banner,
    this.showIndicators = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ปิดการแสดงผล overlay ทั้งหมด - ไม่แสดงข้อความใดๆ
    return const SizedBox.shrink();

    // เก็บโค้ดเดิมไว้ในกรณีที่ต้องการใช้ภายหลัง
    /*
    final hasTitle = banner.hasTitle;
    final hasDetails = banner.hasDetails;

    if (!hasTitle && !hasDetails) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: showIndicators ? 60 : 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasTitle) ...[
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      banner.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (hasTitle && hasDetails) const SizedBox(height: 8),
            if (hasDetails) ...[
              Container(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  banner.details!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (banner.hasLink) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(left: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link,
                        color: Colors.white.withOpacity(0.9),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'อ่านเพิ่มเติม',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    */
  }
}
