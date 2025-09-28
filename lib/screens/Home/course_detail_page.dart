import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:BIBOL/models/course/course_model.dart';

// Enhanced CustomPainter with more beautiful patterns
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

    // Create beautiful geometric pattern
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Add elegant decorative circles with gradient effect
    final circlePaint1 =
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.8, size.height * 0.3),
              radius: 30,
            ),
          );

    final circlePaint2 =
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.03),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.2, size.height * 0.7),
              radius: 25,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      30,
      circlePaint1,
    );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      25,
      circlePaint2,
    );

    // Add diamond shapes
    final diamondPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.06)
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.2);
    path.lineTo(size.width * 0.12, size.height * 0.18);
    path.lineTo(size.width * 0.14, size.height * 0.2);
    path.lineTo(size.width * 0.12, size.height * 0.22);
    path.close();
    canvas.drawPath(path, diamondPaint);
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
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupErrorHandling();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('HTTP request failed') ||
          details.exception.toString().contains('images.unsplash.com') ||
          details.exception.toString().contains('404')) {
        print('🖼️ Image loading error (ignored): ${details.exception}');
        return;
      }
      FlutterError.presentError(details);
    };
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildCourseIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: Offset(-5, -5),
          ),
        ],
      ),
      child: Icon(
        FontAwesomeIcons.graduationCap,
        size: 45,
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
                child: ScaleTransition(
                  scale: _scaleAnimation,
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
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
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
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
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
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
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
              colors: [Color(0xFF07325D), Color(0xFF0A4A73), Color(0xFF0D5A8A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Enhanced Background Pattern
              CustomPaint(
                painter: BackgroundPatternPainter(),
                child: Container(),
              ),

              // Beautiful Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF07325D).withOpacity(0.7),
                      Color(0xFF0A4A73).withOpacity(0.8),
                      Color(0xFF0D5A8A).withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Content with enhanced styling
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Course Icon with animation
                    Hero(
                      tag: 'course_icon_${widget.course.id}',
                      child: _buildCourseIcon(),
                    ),
                    SizedBox(height: 20),

                    // Enhanced Course Title with shadow
                    Hero(
                      tag: 'course_title_${widget.course.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            widget.course.title,
                            style: GoogleFonts.notoSansLao(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    // Enhanced Course Type Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _getCourseTypeFromTitle(),
                        style: GoogleFonts.notoSansLao(
                          fontSize: 13,
                          color: Color(0xFF07325D),
                          fontWeight: FontWeight.w700,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: Offset(-5, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF07325D).withOpacity(0.1),
                        Color(0xFF07325D).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: Color(0xFF07325D),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'ລາຍລະອຽດຫຼັກສູດ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF07325D),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF07325D).withOpacity(0.02),
                    Color(0xFF07325D).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFF07325D).withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Text(
                _stripHtmlTags(widget.course.details),
                style: GoogleFonts.notoSansLao(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: 24),

            if (widget.course.details.contains('ສາຂາ')) ...[
              Row(
                children: [
                  Icon(
                    Icons.account_tree_outlined,
                    color: Color(0xFF07325D),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'ສາຂາວິຊາທີ່ເປີດສອນ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF07325D),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildMajorsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMajorsList() {
    List<String> majors = _extractMajorsFromDetails(widget.course.details);

    return Column(
      children:
          majors
              .map(
                (major) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Color(0xFF07325D).withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          major,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 15,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF07325D).withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  List<String> _extractMajorsFromDetails(String details) {
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
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          ),
          SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.schedule,
            title: 'ລະບົບການສຶກສາ',
            content: _getCourseSystem(),
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          ),
          SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.school,
            title: 'ລະດັບການສຶກສາ',
            content: _getCourseLevel(),
            colors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
          ),
          SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.payments,
            title: 'ຄ່າທຳນຽມການສຶກສາ',
            content: 'ຕິດຕໍ່ສອບຖາມລາຄາ',
            colors: [Color(0xFFE65100), Color(0xFFFF9800)],
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
    required List<Color> colors,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors[0].withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors.map((c) => c.withOpacity(0.15)).toList(),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colors[0], size: 28),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  content,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors[0],
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
    List<String> majors = _extractMajorsFromDetails(widget.course.details);

    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, color: Color(0xFF07325D), size: 28),
                SizedBox(width: 12),
                Text(
                  'ຫຼັກສູດການສຶກສາ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF07325D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            Column(
              children: [
                _buildCurriculumInfoCard(
                  Icons.access_time,
                  'ໄລຍະເວລາການສຶກສາ',
                  _getCourseDuration(),
                  [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                ),
                SizedBox(height: 16),
                _buildCurriculumInfoCard(
                  Icons.schedule,
                  'ລະບົບການສຶກສາ',
                  _getCourseSystem(),
                  [Color(0xFFFF9800), Color(0xFFFFB74D)],
                ),
                SizedBox(height: 16),
                _buildCurriculumInfoCard(
                  Icons.language,
                  'ພາສາການສຶກສາ',
                  'ລາວ, ອັງກິດ',
                  [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                ),
              ],
            ),

            SizedBox(height: 24),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF07325D).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.list_alt, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    majors.isNotEmpty
                        ? 'ສາຂາວິຊາທີ່ເປີດສອນ'
                        : 'ຫຼັກສູດປະກອບດ້ວຍ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            _buildCurriculumComponents(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculumInfoCard(
    IconData icon,
    String title,
    String content,
    List<Color> colors,
  ) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors[0].withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors.map((c) => c.withOpacity(0.15)).toList(),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors[0], size: 24),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 16,
                    color: colors[0],
                    fontWeight: FontWeight.w800,
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
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Color(0xFF07325D).withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          component,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 15,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work_outline, color: Color(0xFF07325D), size: 28),
                SizedBox(width: 12),
                Text(
                  'ໂອກາດໃນການເຮັດວຽກ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF07325D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildCareerOption(
              'ທະນາຄານ',
              'ນັກວິເຄາະສິນເຊື່ອ, ບັນດາເຈົ້າໜ້າທີ່ທະນາຄານ',
              FontAwesomeIcons.university,
              [Color(0xFF1976D2), Color(0xFF42A5F5)],
            ),
            SizedBox(height: 16),
            _buildCareerOption(
              'ບໍລິສັດການເງິນ',
              'ທີ່ປຶກສາການເງິນ, ນັກວິເຄາະການລົງທຶນ',
              FontAwesomeIcons.chartLine,
              [Color(0xFF388E3C), Color(0xFF66BB6A)],
            ),
            SizedBox(height: 16),
            _buildCareerOption(
              'ລັດວິສາຫະກິດ',
              'ເຈົ້າໜ້າທີ່ການເງິນ, ນັກບັນຊີ',
              FontAwesomeIcons.building,
              [Color(0xFFE65100), Color(0xFFFF9800)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerOption(
    String title,
    String description,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.map((c) => c.withOpacity(0.08)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors[0].withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors.map((c) => c.withOpacity(0.15)).toList(),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors[0], size: 24),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors[0],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  color: Color(0xFF07325D),
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'ເງື່ອນໄຂການເຂົ້າສຶກສາ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF07325D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildRequirementItem('ຈົບການສຶກສາຊັ້ນມັດທະຍົມຕອນປາຍ ຫຼື ເທົ່າທຽມ'),
            _buildRequirementItem('ຜ່ານການສອບເຂົ້າຂອງສະຖາບັນ'),
            _buildRequirementItem('ມີສຸຂະພາບແຂງແຮງ'),
            _buildRequirementItem('ສົ່ງເອກະສານຄົບຖ້ວນ'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String requirement) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.check, color: Colors.white, size: 14),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              requirement,
              style: GoogleFonts.notoSansLao(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.6,
                fontWeight: FontWeight.w500,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07325D), Color(0xFF0A4A73), Color(0xFF0D5A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_support_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'ຕິດຕໍ່ສອບຖາມ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildContactItem(
              Icons.phone,
              'ໂທລະສັບ',
              '020 5555 5555',
              Colors.white,
            ),
            SizedBox(height: 16),
            _buildContactItem(
              Icons.email_outlined,
              'ອີເມລ',
              'info@bibol.edu.la',
              Colors.white,
            ),
            SizedBox(height: 16),
            _buildContactItem(
              Icons.location_on_outlined,
              'ທີ່ຕັ້ງ',
              'ວຽງຈັນ, ສປປ ລາວ',
              Colors.white,
            ),
          ],
        ),
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
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.notoSansLao(
                fontSize: 13,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2),
            Text(
              content,
              style: GoogleFonts.notoSansLao(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
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
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder:
                (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[50]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        margin: EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(28),
                        child: Column(
                          children: [
                            Text(
                              'ສົນໃຈສະໝັກຮຽນ?',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF07325D),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'ເລືອກວິທີການທີ່ທ່ານຕ້ອງການ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Handle application
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8,
                                  shadowColor: Color(
                                    0xFF07325D,
                                  ).withOpacity(0.4),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Handle contact
                                },
                                icon: Icon(Icons.phone, size: 24),
                                label: Text(
                                  'ຕິດຕໍ່ສອບຖາມ',
                                  style: GoogleFonts.notoSansLao(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Color(0xFF07325D),
                                  side: BorderSide(
                                    color: Color(0xFF07325D),
                                    width: 2,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
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
}
