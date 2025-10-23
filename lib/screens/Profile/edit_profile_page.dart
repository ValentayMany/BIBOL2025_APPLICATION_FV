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

  // Focus nodes for better UX
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _classFocus = FocusNode();

  double get _screenWidth => MediaQuery.of(context).size.width;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserProfile();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  void _loadUserProfile() async {
    try {
      final userData = await TokenService.getUserInfo();

      if (mounted && userData != null) {
        final prefs = await SharedPreferences.getInstance();
        final localPhone = prefs.getString('local_phone_${userData['id']}');
        final localClass = prefs.getString('local_class_${userData['id']}');

        setState(() {
          userInfo = Map<String, dynamic>.from(userData);
          _emailController.text = userData['email']?.toString() ?? '';
          _phoneController.text =
              localPhone ?? userData['phone']?.toString() ?? '';
          _classController.text =
              localClass ?? userData['class']?.toString() ?? '';
          _isLoading = false;
        });

        debugPrint('✅ Profile loaded successfully');
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້', isError: true);
        }
      }
    } catch (e) {
      debugPrint('💥 Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('ເກີດຂໍ້ຜິດພາດ: $e', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _classController.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _classFocus.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(child: Text(message, style: GoogleFonts.notoSansLao())),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showConfirmationDialog() {
    if (!_formKey.currentState!.validate()) return;

    final newEmail = _emailController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newClass = _classController.text.trim();

    final originalEmail = userInfo?['email']?.toString() ?? '';
    final originalPhone = userInfo?['phone']?.toString() ?? '';
    final originalClass = userInfo?['class']?.toString() ?? '';

    bool hasChanges =
        (originalEmail != newEmail) ||
        (originalPhone != newPhone) ||
        (originalClass != newClass);

    if (!hasChanges) {
      _showSnackBar('ບໍ່ມີການປ່ຽນແປງໃດໆ', isError: true);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _buildConfirmDialog(
            originalEmail: originalEmail,
            newEmail: newEmail,
            originalPhone: originalPhone,
            newPhone: newPhone,
            originalClass: originalClass,
            newClass: newClass,
          ),
    );
  }

  Widget _buildConfirmDialog({
    required String originalEmail,
    required String newEmail,
    required String originalPhone,
    required String newPhone,
    required String originalClass,
    required String newClass,
  }) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
            if (originalEmail != newEmail)
              _buildChangeItem(
                label: '📧 ອີເມວ',
                oldValue: originalEmail.isEmpty ? 'ບໍ່ມີ' : originalEmail,
                newValue: newEmail,
                color: Color(0xFF0D5AA7),
                note: 'ບັນທຶກລົງ Database',
              ),
            if (originalPhone != newPhone) ...[
              if (originalEmail != newEmail) SizedBox(height: 12),
              _buildChangeItem(
                label: '📱 ເບີໂທ',
                oldValue: originalPhone.isEmpty ? 'ບໍ່ມີ' : originalPhone,
                newValue: newPhone.isEmpty ? 'ບໍ່ມີ' : newPhone,
                color: Color(0xFF0A4A85),
                note: 'ບັນທຶກໃນເຄື່ອງ',
              ),
            ],
            if (originalClass != newClass) ...[
              if (originalEmail != newEmail || originalPhone != newPhone)
                SizedBox(height: 12),
              _buildChangeItem(
                label: '🏫 ຫ້ອງຮຽນ',
                oldValue: originalClass.isEmpty ? 'ບໍ່ມີ' : originalClass,
                newValue: newClass.isEmpty ? 'ບໍ່ມີ' : newClass,
                color: Color(0xFF07325D),
                note: 'ບັນທຶກໃນເຄື່ອງ',
              ),
            ],
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF07325D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF07325D).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF07325D), size: 20),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'ຢືນຢັນ',
            style: GoogleFonts.notoSansLao(fontWeight: FontWeight.bold),
          ),
        ),
      ],
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
                      style: GoogleFonts.notoSansLao(fontSize: 11),
                    ),
                    Text(
                      oldValue,
                      style: GoogleFonts.notoSansLao(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.lineThrough,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ໃໝ່:', style: GoogleFonts.notoSansLao(fontSize: 11)),
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
    setState(() => _isSaving = true);

    try {
      final newEmail = _emailController.text.trim();
      final newPhone = _phoneController.text.trim();
      final newClass = _classController.text.trim();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_phone_${userInfo?['id']}', newPhone);
      await prefs.setString('local_class_${userInfo?['id']}', newClass);

      final authService = StudentAuthService();
      final result = await authService.updateStudentEmail(email: newEmail);

      if (mounted) {
        setState(() => _isSaving = false);

        if (result['success'] == true) {
          await TokenService.updateUserInfo({'email': newEmail});
          _showSnackBar('ບັນທຶກຂໍ້ມູນສຳເລັດແລ້ວ! 🎉');
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context, true);
        } else {
          _showSnackBar(result['message'] ?? 'ເກີດຂໍ້ຜິດພາດ', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar('ເກີດຂໍ້ຜິດພາດ: $e', isError: true);
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
      backgroundColor: const Color(0xFFF8F9FB),
      extendBodyBehindAppBar: true,
      body: _isLoading ? _buildLoadingScreen() : _buildBody(),
      floatingActionButton:
          _isLoading || _isSaving ? null : _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07325D), Color(0xFF0A4A85), Color(0xFF0D5AA7)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3.5,
              ),
            ),
            SizedBox(height: 28),
            Text(
              'ກຳລັງໂຫຼດຂໍ້ມູນ...',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07325D), Color(0xFF0D5AA7)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showConfirmationDialog,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_rounded, color: Colors.white, size: 26),
                SizedBox(width: 12),
                Text(
                  'ບັນທຶກການປ່ຽນແປງ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: 100,
              ),
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileInfoCard(),
                      SizedBox(height: 24),

                      _buildSectionHeader(
                        title: 'ຂໍ້ມູນທົ່ວໄປ',
                        subtitle: 'ຂໍ້ມູນເຫຼົ່ານີ້ບໍ່ສາມາດແກ້ໄຂໄດ້',
                        icon: Icons.lock_outline,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(height: 16),

                      _buildReadonlyInfoGrid(),
                      SizedBox(height: 32),

                      _buildSectionHeader(
                        title: 'ແກ້ໄຂຂໍ້ມູນ',
                        subtitle: 'ທ່ານສາມາດອັບເດດຂໍ້ມູນເຫຼົ່ານີ້ໄດ້',
                        icon: Icons.edit_rounded,
                        color: Color(0xFF07325D),
                      ),
                      SizedBox(height: 16),

                      _buildEditableFields(),
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

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07325D), Color(0xFF0D5AA7)],
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
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 24),
          child: Row(
            children: [
              SharedHeaderButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.pop(context),
                screenWidth: _screenWidth,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ແກ້ໄຂໂປຣໄຟລ໌',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ອັບເດດຂໍ້ມູນສ່ວນຕົວຂອງທ່ານ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
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

  Widget _buildProfileInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF07325D).withOpacity(0.05),
            Color(0xFF0D5AA7).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFF07325D).withOpacity(0.2), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF07325D), Color(0xFF0D5AA7)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF07325D).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${userInfo?['first_name'] ?? ''} ${userInfo?['last_name'] ?? ''}',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07325D),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'ລະຫັດ: ${userInfo?['admission_no'] ?? 'N/A'}',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSansLao(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.notoSansLao(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadonlyInfoGrid() {
    List<Widget> chips = [];

    if (userInfo?['gender'] != null) {
      chips.add(
        _buildReadonlyChip(
          icon: Icons.wc_outlined,
          label: 'ເພດ',
          value: _getGenderText(userInfo!['gender'].toString()),
        ),
      );
    }

    if (userInfo?['roll_no'] != null) {
      chips.add(
        _buildReadonlyChip(
          icon: Icons.numbers_rounded,
          label: 'Roll No',
          value: userInfo!['roll_no'].toString(),
        ),
      );
    }

    if (chips.isEmpty) return SizedBox.shrink();

    return Wrap(spacing: 12, runSpacing: 12, children: chips);
  }

  Widget _buildReadonlyChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSansLao(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.notoSansLao(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableFields() {
    return Column(
      children: [
        _buildModernTextField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: 'ອີເມວ',
          icon: Icons.email_rounded,
          color: Color(0xFF0D5AA7),
          hint: 'example@email.com',
          keyboardType: TextInputType.emailAddress,
          badge: '💾 Database',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'ກະລຸນາໃສ່ອີເມວ';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'ກະລຸນາໃສ່ອີເມວທີ່ຖືກຕ້ອງ';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        _buildModernTextField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          label: 'ເບີໂທລະສັບ',
          icon: Icons.phone_rounded,
          color: Color(0xFF0A4A85),
          hint: '020 XXXX XXXX',
          keyboardType: TextInputType.phone,
          badge: '📱 ເຄື່ອງ',
        ),
        SizedBox(height: 16),

        _buildModernTextField(
          controller: _classController,
          focusNode: _classFocus,
          label: 'ຫ້ອງຮຽນ',
          icon: Icons.school_rounded,
          color: Color(0xFF07325D),
          hint: 'ເຊັ່ນ: ມ.6/1',
          badge: '🏫 ເຄື່ອງ',
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required Color color,
    required String hint,
    required String badge,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isFocused ? color : color.withOpacity(0.2),
              width: isFocused ? 2.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isFocused ? color.withOpacity(0.2) : Colors.grey.shade200,
                blurRadius: isFocused ? 16 : 8,
                offset: Offset(0, isFocused ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.8), color],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          badge,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 11,
                            color: color.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: color, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'ແກ້ໄຂ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: controller,
                focusNode: focusNode,
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: color.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: color.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.red.shade600,
                      width: 2,
                    ),
                  ),
                  errorStyle: GoogleFonts.notoSansLao(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                validator: validator,
              ),
            ],
          ),
        );
      },
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
