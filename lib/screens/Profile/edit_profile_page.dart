import 'package:BIBOL/services/token/token_service.dart';
import 'package:BIBOL/services/auth/students_auth_service.dart';
import 'package:BIBOL/widgets/shared/shared_header_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _classController = TextEditingController();

  Map<String, dynamic>? userInfo;
  bool _isLoading = true;
  bool _isSaving = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double get _screenWidth => MediaQuery.of(context).size.width;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserProfile();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  // 🔥 ปรับปรุง: ใช้ข้อมูลจาก TokenService แทน API
  void _loadUserProfile() async {
    try {
      // 🎯 ใช้ข้อมูลจาก TokenService (เก็บไว้ตอน login)
      final userData = await TokenService.getUserInfo();

      if (mounted && userData != null) {
        final prefs = await SharedPreferences.getInstance();

        // Load local edits if they exist
        final localPhone = prefs.getString('local_phone_${userData['id']}');
        final localClass = prefs.getString('local_class_${userData['id']}');

        setState(() {
          // ✅ เก็บข้อมูลต้นฉบับจาก TokenService
          userInfo = Map<String, dynamic>.from(userData);

          // แสดงค่าต้นฉบับ
          _emailController.text = userData['email']?.toString() ?? '';

          // แสดงค่า local ใน TextField (ถ้ามี) หรือใช้ค่าจาก server
          _phoneController.text =
              localPhone ?? userData['phone']?.toString() ?? '';
          _classController.text =
              localClass ?? userData['class']?.toString() ?? '';

          _isLoading = false;
        });

        debugPrint('✅ Profile loaded successfully');
        debugPrint(
          '👤 Name: ${userData['first_name']} ${userData['last_name']}',
        );
        debugPrint('📧 Email: ${userData['email']}');
        debugPrint('📱 Phone (local): $localPhone');
        debugPrint('🏫 Class (local): $localClass');
      } else {
        if (mounted) {
          setState(() => _isLoading = false);

          // แสดง error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້',
                      style: GoogleFonts.notoSansLao(),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('💥 Error loading profile: $e');

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ເກີດຂໍ້ຜິດພາດ: $e',
                    style: GoogleFonts.notoSansLao(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _classController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newEmail = _emailController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newClass = _classController.text.trim();

    // 🎯 เปรียบเทียบกับข้อมูลต้นฉบับจาก server
    final originalEmail = userInfo?['email']?.toString() ?? '';
    final originalPhone = userInfo?['phone']?.toString() ?? '';
    final originalClass = userInfo?['class']?.toString() ?? '';

    // Check if there are any changes
    bool hasChanges =
        (originalEmail != newEmail) ||
        (originalPhone != newPhone) ||
        (originalClass != newClass);

    if (!hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ບໍ່ມີການປ່ຽນແປງໃດໆ',
                  style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ຢືນຢັນການປ່ຽນແປງ',
                    style: GoogleFonts.notoSansLao(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF07325D),
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ກະລຸນາກວດສອບຂໍ້ມູນທີ່ຈະປ່ຽນແປງ:',
                    style: GoogleFonts.notoSansLao(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Email changes
                  if (originalEmail != newEmail) ...[
                    _buildChangeItem(
                      label: '📧 ອີເມວ',
                      oldValue: originalEmail.isEmpty ? 'ບໍ່ມີ' : originalEmail,
                      newValue: newEmail,
                      color: Color(0xFF0D5AA7),
                      note: 'ບັນທຶກລົງ Database',
                    ),
                    SizedBox(height: 12),
                  ],

                  // Phone changes
                  if (originalPhone != newPhone) ...[
                    _buildChangeItem(
                      label: '📱 ເບີໂທ',
                      oldValue: originalPhone.isEmpty ? 'ບໍ່ມີ' : originalPhone,
                      newValue: newPhone.isEmpty ? 'ບໍ່ມີ' : newPhone,
                      color: Color(0xFF0A4A85),
                      note: 'ບັນທຶກໃນເຄື່ອງເທົ່ານັ້ນ',
                    ),
                    SizedBox(height: 12),
                  ],

                  // Class changes
                  if (originalClass != newClass) ...[
                    _buildChangeItem(
                      label: '🏫 ຫ້ອງຮຽນ',
                      oldValue: originalClass.isEmpty ? 'ບໍ່ມີ' : originalClass,
                      newValue: newClass.isEmpty ? 'ບໍ່ມີ' : newClass,
                      color: Color(0xFF07325D),
                      note: 'ບັນທຶກໃນເຄື່ອງເທົ່ານັ້ນ',
                    ),
                    SizedBox(height: 12),
                  ],

                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF07325D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF07325D).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF07325D),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການບັນທຶກການປ່ຽນແປງນີ້?',
                            style: GoogleFonts.notoSansLao(
                              color: Color(0xFF07325D),
                              fontSize: 13,
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ຍົກເລີກ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _saveProfile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07325D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'ຢືນຢັນ',
                  style: GoogleFonts.notoSansLao(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildChangeItem({
    required String label,
    required String oldValue,
    required String newValue,
    required Color color,
    String? note,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              if (note != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    note,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ເກົ່າ:',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      oldValue,
                      style: GoogleFonts.notoSansLao(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        decoration: TextDecoration.lineThrough,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ໃໝ່:',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      newValue,
                      style: GoogleFonts.notoSansLao(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() => _isSaving = true);

    try {
      final newEmail = _emailController.text.trim();
      final newPhone = _phoneController.text.trim();
      final newClass = _classController.text.trim();

      // 📱 Save phone and class locally (ไม่ส่งไป API)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_phone_${userInfo?['id']}', newPhone);
      await prefs.setString('local_class_${userInfo?['id']}', newClass);

      debugPrint('✅ Phone & Class saved locally');
      debugPrint('📱 Phone: $newPhone');
      debugPrint('🏫 Class: $newClass');

      // 📧 Call API to update email in backend (เฉพาะอีเมลเท่านั้น)
      final authService = StudentAuthService();
      final result = await authService.updateStudentEmail(email: newEmail);

      if (mounted) {
        setState(() => _isSaving = false);

        if (result['success'] == true) {
          // 🔥 อัพเดท local storage ด้วย
          await TokenService.updateUserInfo({'email': newEmail});

          debugPrint('✅ Email updated in database');

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ບັນທຶກຂໍ້ມູນສຳເລັດແລ້ວ! 🎉',
                      style: GoogleFonts.notoSansLao(),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 3),
            ),
          );

          Navigator.pop(context, true);
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'ເກີດຂໍ້ຜິດພາດ',
                      style: GoogleFonts.notoSansLao(),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('💥 Error saving profile: $e');

      if (mounted) {
        setState(() => _isSaving = false);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ເກີດຂໍ້ຜິດພາດ: $e',
                    style: GoogleFonts.notoSansLao(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      body: _isLoading ? _buildLoadingScreen() : _buildBody(),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07325D), Color(0xFF0A4A85), Color(0xFF0D5AA7)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'ກຳລັງໂຫຼດຂໍ້ມູນ...',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF07325D).withOpacity(0.1),
                              Color(0xFF0A4A85).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFF07325D).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF07325D),
                                    Color(0xFF0A4A85),
                                  ],
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
                              child: Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ຂໍ້ມູນສ່ວນຕົວ',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF07325D),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'ແກ້ໄຂ ອີເມວ, ເບີໂທ ແລະ ຫ້ອງຮຽນ',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      _buildReadOnlyField(
                        label: 'ລະຫັດນັກຮຽນ',
                        value: userInfo?['admission_no']?.toString() ?? 'N/A',
                        icon: Icons.badge_rounded,
                        color: Color(0xFF0D5AA7),
                      ),
                      SizedBox(height: 16),

                      _buildReadOnlyField(
                        label: 'ຊື່',
                        value: userInfo?['first_name']?.toString() ?? 'N/A',
                        icon: Icons.person_outline,
                        color: Color(0xFF0A4A85),
                      ),
                      SizedBox(height: 16),

                      _buildReadOnlyField(
                        label: 'ນາມສະກຸນ',
                        value: userInfo?['last_name']?.toString() ?? 'N/A',
                        icon: Icons.person_outline,
                        color: Color(0xFF0A4A85),
                      ),
                      SizedBox(height: 16),

                      if (userInfo?['gender'] != null) ...[
                        _buildReadOnlyField(
                          label: 'ເພດ',
                          value: _getGenderText(userInfo!['gender'].toString()),
                          icon: Icons.wc_outlined,
                          color: Color(0xFF07325D),
                        ),
                        SizedBox(height: 16),
                      ],

                      if (userInfo?['roll_no'] != null) ...[
                        _buildReadOnlyField(
                          label: 'Roll No',
                          value: userInfo!['roll_no'].toString(),
                          icon: Icons.numbers_rounded,
                          color: Color(0xFF0D5AA7),
                        ),
                        SizedBox(height: 16),
                      ],

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 1.5,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '✏️ ແກ້ໄຂໄດ້',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF07325D),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1.5,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      _buildEditableField(
                        label: 'ອີເມວ',
                        controller: _emailController,
                        icon: Icons.email_rounded,
                        color: Color(0xFF0D5AA7),
                        hint: 'ກະລຸນາໃສ່ອີເມວ',
                        keyboardType: TextInputType.emailAddress,
                        helperText: '💾 ບັນທຶກລົງ Database',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'ກະລຸນາໃສ່ອີເມວ';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'ກະລຸນາໃສ່ອີເມວທີ່ຖືກຕ້ອງ';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      _buildEditableField(
                        label: 'ເບີໂທລະສັບ',
                        controller: _phoneController,
                        icon: Icons.phone_rounded,
                        color: Color(0xFF0A4A85),
                        hint: 'ກະລຸນາໃສ່ເບີໂທລະສັບ',
                        keyboardType: TextInputType.phone,
                        helperText: '📱 ບັນທຶກໃນເຄື່ອງເທົ່ານັ້ນ',
                      ),
                      SizedBox(height: 16),

                      _buildEditableField(
                        label: 'ຫ້ອງຮຽນ',
                        controller: _classController,
                        icon: Icons.school_rounded,
                        color: Color(0xFF07325D),
                        hint: 'ກະລຸນາໃສ່ຫ້ອງຮຽນ',
                        helperText: '🏫 ບັນທຶກໃນເຄື່ອງເທົ່ານັ້ນ',
                      ),
                      SizedBox(height: 32),

                      Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
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
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _showConfirmationDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child:
                              _isSaving
                                  ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save_rounded, size: 24),
                                      SizedBox(width: 12),
                                      Text(
                                        'ບັນທຶກການປ່ຽນແປງ',
                                        style: GoogleFonts.notoSansLao(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),

                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  SharedHeaderButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => Navigator.pop(context),
                    screenWidth: _screenWidth,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ແກ້ໄຂໂປຣໄຟລ໌',
                          style: GoogleFonts.notoSansLao(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'ອັບເດດຂໍ້ມູນຂອງທ່ານ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.edit_rounded,
                    size: 45,
                    color: const Color(0xFF07325D),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lock_outline,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required String hint,
    TextInputType? keyboardType,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  '✏️ ແກ້ໄຂໄດ້',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.notoSansLao(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.notoSansLao(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: color.withOpacity(0.05),
              prefixIcon: Icon(icon, color: color),
              helperText: helperText,
              helperStyle: GoogleFonts.notoSansLao(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: color.withOpacity(0.3), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: color.withOpacity(0.3), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: color, width: 2.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade600, width: 2.5),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  String _getGenderText(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
      case 'm':
        return 'ຊາຍ';
      case 'female':
      case 'f':
        return 'ຍິງ';
      default:
        return gender;
    }
  }
}
