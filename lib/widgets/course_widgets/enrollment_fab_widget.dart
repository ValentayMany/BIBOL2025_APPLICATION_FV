// lib/widgets/course_widgets/enrollment_fab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EnrollmentFabWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showEnrollmentModal(context);
        },
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: Icon(Icons.school, size: 24),
        label: Text(
          'ສະໝັກຮຽນ',
          style: GoogleFonts.notoSansLao(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showEnrollmentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // ตัวจับลาก
            Container(
              width: 50,
              height: 5,
              margin: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // เนื้อหา
            Padding(
              padding: EdgeInsets.all(28),
              child: Column(
                children: [
                  // หัวข้อ
                  Text(
                    'ສົນໃຈສະໝັກຮຽນ?',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF07325D),
                    ),
                  ),
                  SizedBox(height: 32),

                  // ปุ่มแบบฟอร์ม
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // ปิด modal ก่อน
                        _showComingSoon(context); // แสดง Coming Soon
                      },
                      icon: Icon(Icons.app_registration, size: 24),
                      label: Text(
                        'ແບບຟອມສະໝັກຮຽນ',
                        style: GoogleFonts.notoSansLao(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF07325D),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'ກຳລັງພັດທະນາ',
          style: GoogleFonts.notoSansLao(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF07325D),
          ),
        ),
        content: Text(
          'ຟີເຈີນີ້ກຳລັງພັດທະນາ ກະລຸນາລໍຖ້າໃນອະນາຄົດ',
          style: GoogleFonts.notoSansLao(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ຕົກລົງ',
              style: GoogleFonts.notoSansLao(
                color: const Color(0xFF07325D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
