import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:BIBOL/models/course/course_model.dart';

// เพิ่ม CustomPainter สำหรับ background pattern
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // สร้าง grid pattern
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // เพิ่มวงกลมเป็น decoration
    final circlePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.08)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      20,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      15,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CourseDetailPage extends StatefulWidget {
  final CourseModel course;

  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupErrorHandling(); // เพิ่ม error handling
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  // ✅ เพิ่มการจัดการ Error สำหรับ Images
  void _setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // ซ่อน error ที่เกี่ยวกับ network images
      if (details.exception.toString().contains('HTTP request failed') ||
          details.exception.toString().contains('images.unsplash.com') ||
          details.exception.toString().contains('404')) {
        // ไม่แสดง error แต่ log ไว้
        print('🖼️ Image loading error (ignored): ${details.exception}');
        return;
      }
      // แสดง error อื่นๆ ตามปกติ
      FlutterError.presentError(details);
    };
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildCourseIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        FontAwesomeIcons.graduationCap,
        size: 40,
        color: Color(0xFF07325D),
      ),
    );
  }

  String _stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';
    String stripped = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    stripped = stripped
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .replaceAll('&hellip;', '...')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–');
    return stripped.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildCourseOverviewCard(),
                    _buildCourseDetailsSection(),
                    _buildCurriculumSection(),
                    _buildCareerProspectsSection(),
                    _buildAdmissionRequirementsSection(),
                    _buildContactSection(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFF07325D),
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.arrow_back_ios, color: Color(0xFF07325D), size: 20),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Share course
          },
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.share_outlined,
              color: Color(0xFF07325D),
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // ✅ Background Pattern ที่ปลอดภัย
              CustomPaint(
                painter: BackgroundPatternPainter(),
                child: Container(),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF07325D).withOpacity(0.8),
                      Color(0xFF0A4A73).withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Icon
                    Hero(
                      tag: 'course_icon_${widget.course.id}',
                      child: _buildCourseIcon(),
                    ),
                    SizedBox(height: 16),

                    // Course Title
                    Hero(
                      tag: 'course_title_${widget.course.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          widget.course.title,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Course Type Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getCourseTypeFromTitle(),
                        style: GoogleFonts.notoSansLao(
                          fontSize: 12,
                          color: Color(0xFF07325D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันใหม่เพื่อดึงประเภทหลักสูตรจากชื่อ
  String _getCourseTypeFromTitle() {
    final title = widget.course.title.toLowerCase();
    if (title.contains('ປະລິນຍາໂທ')) return 'ປະລິນຍາໂທ ລະບົບ 2 ປີ';
    if (title.contains('ຕໍ່ເນື່ອງ') && title.contains('ພາກຄ່ຳ'))
      return 'ຕໍ່ເນື່ອງ ພາກຄ່ຳ ລະບົບ 2 ປີ';
    if (title.contains('ຕໍ່ເນື່ອງ')) return 'ຕໍ່ເນື່ອງ ພາກປົກກະຕິ ລະບົບ 2 ປີ';
    if (title.contains('4 ປີ')) return 'ປະລິນຍາຕີ ລະບົບ 4 ປີ';
    return 'ປະລິນຍາຕີ';
  }

  Widget _buildCourseOverviewCard() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF07325D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school_outlined,
                  color: Color(0xFF07325D),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ລາຍລະອຽດຫຼັກສູດ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07325D),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // แสดง details จาก API
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF07325D).withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF07325D).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              _stripHtmlTags(widget.course.details),
              style: GoogleFonts.notoSansLao(
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.7,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          SizedBox(height: 20),

          // แยกแสดงสาขาต่างๆ ถ้ามี
          if (widget.course.details.contains('ສາຂາ')) ...[
            Row(
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  color: Color(0xFF07325D),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'ສາຂາວິຊາທີ່ເປີດສອນ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07325D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildMajorsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMajorsList() {
    // ดึงชื่อสาขาจาก details
    List<String> majors = _extractMajorsFromDetails(widget.course.details);

    return Column(
      children:
          majors
              .map(
                (major) => Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFF07325D).withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF07325D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          major,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  List<String> _extractMajorsFromDetails(String details) {
    // ดึงสาขาจากข้อความ details
    List<String> majors = [];

    if (details.contains('ສາຂາການທະນາຄານ')) majors.add('ສາຂາການທະນາຄານ');
    if (details.contains('ສາຂາການເງິນ') &&
        !details.contains('ສາຂາການເງິນ-ການທະນາຄານ'))
      majors.add('ສາຂາການເງິນ');
    if (details.contains('ສາຂາບັນຊີ') || details.contains('ສາຂາການບັນຊີ'))
      majors.add('ສາຂາການບັນຊີ');
    if (details.contains('ສາຂາການເງິນຈຸລະພາກ'))
      majors.add('ສາຂາການເງິນຈຸລະພາກ');
    if (details.contains('ສາຂາການບັນຊີແລະກວດສອບ'))
      majors.add('ສາຂາການບັນຊີແລະກວດສອບ');
    if (details.contains('ສາຂາການຕະຫຼາດດີຈິຕອນ'))
      majors.add('ສາຂາການຕະຫຼາດດີຈິຕອນ');
    if (details.contains('ສາຂາການເງິນ-ການທະນາຄານ'))
      majors.add('ສາຂາການເງິນ-ການທະນາຄານ');

    return majors;
  }

  Widget _buildCourseDetailsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          _buildDetailCard(
            icon: Icons.access_time,
            title: 'ໄລຍະເວລາການສຶກສາ',
            content: _getCourseDuration(),
            color: Color(0xFF2E7D32),
          ),
          SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.schedule,
            title: 'ລະບົບການສຶກສາ',
            content: _getCourseSystem(),
            color: Color(0xFF1976D2),
          ),
          SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.school,
            title: 'ລະດັບການສຶກສາ',
            content: _getCourseLevel(),
            color: Color(0xFF7B1FA2),
          ),
          SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.payments,
            title: 'ຄ່າທຳນຽມການສຶກສາ',
            content: 'ຕິດຕໍ່ສອບຖາມລາຄາ',
            color: Color(0xFFE65100),
          ),
        ],
      ),
    );
  }

  String _getCourseDuration() {
    final title = widget.course.title.toLowerCase();
    if (title.contains('4 ປີ')) return '4 ປີ (8 ພາກການສຶກສາ)';
    if (title.contains('2 ປີ')) return '2 ປີ (4 ພາກການສຶກສາ)';
    return 'ຕິດຕໍ່ສອບຖາມ';
  }

  String _getCourseSystem() {
    final title = widget.course.title.toLowerCase();
    if (title.contains('ພາກຄ່ຳ')) return 'ພາກຄ່ຳ (Evening Program)';
    if (title.contains('ພາກປົກກະຕິ')) return 'ພາກປົກກະຕິ (Regular Program)';
    if (title.contains('ຕໍ່ເນື່ອງ')) return 'ຕໍ່ເນື່ອງ (Continuing Education)';
    return 'ພາກປົກກະຕິ (Regular Program)';
  }

  String _getCourseLevel() {
    final title = widget.course.title.toLowerCase();
    if (title.contains('ປະລິນຍາໂທ')) return 'ປະລິນຍາໂທ (Master\'s Degree)';
    if (title.contains('ປະລິນຍາຕີ')) return 'ປະລິນຍາຕີ (Bachelor\'s Degree)';
    return 'ປະລິນຍາຕີ (Bachelor\'s Degree)';
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculumSection() {
    // แยกข้อมูลหลักสูตรจาก details
    List<String> majors = _extractMajorsFromDetails(widget.course.details);

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: Color(0xFF07325D), size: 24),
              SizedBox(width: 8),
              Text(
                'ຫຼັກສູດການສຶກສາ',
                style: GoogleFonts.notoSansLao(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF07325D),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // ข้อมูลหลักสูตรหลัก
          Container(
            width: double.infinity,
            child: Column(
              children: [
                // ระยะเวลาการศึกษา
                _buildCurriculumInfoCard(
                  Icons.access_time,
                  'ໄລຍະເວລາການສຶກສາ',
                  _getCourseDuration(),
                  Color(0xFF4CAF50),
                ),

                SizedBox(height: 12),

                // ระบบการศึกษา
                _buildCurriculumInfoCard(
                  Icons.schedule,
                  'ລະບົບການສຶກສາ',
                  _getCourseSystem(),
                  Color(0xFFFF9800),
                ),

                SizedBox(height: 12),

                // ภาษาการศึกษา
                _buildCurriculumInfoCard(
                  Icons.language,
                  'ພາສາການສຶກສາ',
                  'ລາວ, ອັງກິດ',
                  Color(0xFF9C27B0),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // หลักสูตรประกอบด้วย
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  majors.isNotEmpty ? 'ສາຂາວິຊາທີ່ເປີດສອນ' : 'ຫຼັກສູດປະກອບດ້ວຍ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // แสดงรายการหลักสูตร
          _buildCurriculumComponents(),
        ],
      ),
    );
  }

  // ✅ Widget สำหรับแสดงข้อมูลหลักสูตร
  Widget _buildCurriculumInfoCard(
    IconData icon,
    String title,
    String content,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  content,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculumComponents() {
    List<String> majors = _extractMajorsFromDetails(widget.course.details);

    // ถ้าไม่มีสาขา ให้ใช้รายการหลักสูตรทั่วไป
    List<String> curriculumComponents =
        majors.isNotEmpty
            ? majors
            : [
              'ວິຊາພື້ນຖານ (General Education)',
              'ວິຊາແກນ (Core Courses)',
              'ວິຊາເອກ (Major Courses)',
              'ວິຊາເລືອກ (Elective Courses)',
              'ການຝຶກງານ (Internship)',
              'ວິທະຍານິພົນ (Thesis/Capstone Project)',
            ];

    return Column(
      children:
          curriculumComponents
              .map(
                (component) => Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFF07325D).withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF07325D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          component,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildCareerProspectsSection() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_outline, color: Color(0xFF07325D), size: 24),
              SizedBox(width: 8),
              Text(
                'ໂອກາດໃນການເຮັດວຽກ',
                style: GoogleFonts.notoSansLao(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF07325D),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildCareerOption(
            'ທະນາຄານ',
            'ນັກວິເຄາະສິນເຊື່ອ, ບັນດາເຈົ້າໜ້າທີ່ທະນາຄານ',
            FontAwesomeIcons.university,
          ),
          SizedBox(height: 12),
          _buildCareerOption(
            'ບໍລິສັດການເງິນ',
            'ທີ່ປຶກສາການເງິນ, ນັກວິເຄາະການລົງທຶນ',
            FontAwesomeIcons.chartLine,
          ),
          SizedBox(height: 12),
          _buildCareerOption(
            'ລັດວິສາຫະກິດ',
            'ເຈົ້າໜ້າທີ່ການເງິນ, ນັກບັນຊີ',
            FontAwesomeIcons.building,
          ),
        ],
      ),
    );
  }

  Widget _buildCareerOption(String title, String description, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF07325D).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF07325D).withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF07325D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF07325D), size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07325D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmissionRequirementsSection() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: Color(0xFF07325D),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'ເງື່ອນໄຂການເຂົ້າສຶກສາ',
                style: GoogleFonts.notoSansLao(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF07325D),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildRequirementItem('ຈົບການສຶກສາຊັ້ນມັດທະຍົມຕອນປາຍ ຫຼື ເທົ່າທຽມ'),
          _buildRequirementItem('ຜ່ານການສອບເຂົ້າຂອງສະຖາບັນ'),
          _buildRequirementItem('ມີສຸຂະພາບແຂງແຮງ'),
          _buildRequirementItem('ສົ່ງເອກະສານຄົບຖ້ວນ'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 12),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              requirement,
              style: GoogleFonts.notoSansLao(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_support_outlined,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'ຕິດຕໍ່ສອບຖາມ',
                style: GoogleFonts.notoSansLao(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildContactItem(
            Icons.phone,
            'ໂທລະສັບ',
            '020 5555 5555',
            Colors.white,
          ),
          SizedBox(height: 12),
          _buildContactItem(
            Icons.email_outlined,
            'ອີເມລ',
            'info@bibol.edu.la',
            Colors.white,
          ),
          SizedBox(height: 12),
          _buildContactItem(
            Icons.location_on_outlined,
            'ທີ່ຕັ້ງ',
            'ວຽງຈັນ, ສປປ ລາວ',
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String content,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 20),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.notoSansLao(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
            Text(
              content,
              style: GoogleFonts.notoSansLao(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        // Show application form or contact
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder:
              (context) => Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'ສົນໃຈສະໝັກຮຽນ?',
                            style: GoogleFonts.notoSansLao(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF07325D),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Handle application
                            },
                            icon: Icon(Icons.app_registration),
                            label: Text(
                              'ແບບຟອມສະໝັກຮຽນ',
                              style: GoogleFonts.notoSansLao(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF07325D),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Handle contact
                            },
                            icon: Icon(Icons.phone),
                            label: Text(
                              'ຕິດຕໍ່ສອບຖາມ',
                              style: GoogleFonts.notoSansLao(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF07325D),
                              side: BorderSide(color: Color(0xFF07325D)),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
      },
      backgroundColor: Color(0xFF07325D),
      foregroundColor: Colors.white,
      icon: Icon(Icons.school),
      label: Text(
        'ສະໝັກຮຽນ',
        style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600),
      ),
    );
  }
}
