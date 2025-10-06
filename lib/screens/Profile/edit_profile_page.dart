import 'package:BIBOL/services/token/token_service.dart';
import 'package:BIBOL/services/auth/students_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  Map<String, dynamic>? userInfo;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final user = await TokenService.getUserInfo();
    
    if (mounted) {
      setState(() {
        userInfo = user;
        _emailController.text = user?['email']?.toString() ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newEmail = _emailController.text.trim();
      final studentId = userInfo?['id'];

      if (studentId == null) {
        throw Exception('Student ID not found');
      }

      // Call API to update email in backend
      final authService = StudentAuthService();
      final result = await authService.updateStudentEmail(
        studentId: studentId,
        email: newEmail,
      );

      if (mounted) {
        setState(() => _isSaving = false);

        if (result['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ອັບເດດອີເມວສຳເລັດແລ້ວ',
                      style: GoogleFonts.notoSansLao(),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
            ),
          );

          // Go back to profile page
          Navigator.pop(context, true);
        } else {
          // Show error message from server
          ScaffoldMessenger.of(context).showSnackBar(
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
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
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
              borderRadius: BorderRadius.circular(12),
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
        statusBarColor: Color(0xFF07325D),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _isLoading ? _buildLoadingScreen() : _buildBody(),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'ກຳລັງໂຫຼດ...',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'ຂໍ້ມູນສ່ວນຕົວ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF07325D),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ທ່ານສາມາດແກ້ໄຂອີເມວເທົ່ານັ້ນ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Read-only: Admission No
                  _buildReadOnlyField(
                    label: 'ລະຫັດນັກຮຽນ',
                    value: userInfo?['admission_no']?.toString() ?? 'N/A',
                    icon: Icons.badge_rounded,
                  ),
                  SizedBox(height: 16),
                  
                  // Read-only: First Name
                  _buildReadOnlyField(
                    label: 'ຊື່',
                    value: userInfo?['first_name']?.toString() ?? 'N/A',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 16),
                  
                  // Read-only: Last Name
                  _buildReadOnlyField(
                    label: 'ນາມສະກຸນ',
                    value: userInfo?['last_name']?.toString() ?? 'N/A',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 16),
                  
                  // Editable: Email
                  _buildEditableEmailField(),
                  SizedBox(height: 16),
                  
                  // Read-only: Phone
                  if (userInfo?['phone'] != null) ...[
                    _buildReadOnlyField(
                      label: 'ເບີໂທລະສັບ',
                      value: userInfo!['phone'].toString(),
                      icon: Icons.phone_outlined,
                    ),
                    SizedBox(height: 16),
                  ],
                  
                  // Read-only: Gender
                  if (userInfo?['gender'] != null) ...[
                    _buildReadOnlyField(
                      label: 'ເພດ',
                      value: _getGenderText(userInfo!['gender'].toString()),
                      icon: Icons.wc_outlined,
                    ),
                    SizedBox(height: 16),
                  ],
                  
                  // Read-only: Class
                  if (userInfo?['class'] != null) ...[
                    _buildReadOnlyField(
                      label: 'ຫ້ອງຮຽນ',
                      value: userInfo!['class'].toString(),
                      icon: Icons.class_outlined,
                    ),
                    SizedBox(height: 16),
                  ],
                  
                  // Read-only: Roll No
                  if (userInfo?['roll_no'] != null) ...[
                    _buildReadOnlyField(
                      label: 'Roll No',
                      value: userInfo!['roll_no'].toString(),
                      icon: Icons.numbers_rounded,
                    ),
                    SizedBox(height: 16),
                  ],
                  
                  SizedBox(height: 24),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF07325D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                      child: _isSaving
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
                                Icon(Icons.save_rounded, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'ບັນທຶກການປ່ຽນແປງ',
                                  style: GoogleFonts.notoSansLao(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'ແກ້ໄຂໂປຣໄຟລ໌',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Profile Icon
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
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey.shade600, size: 22),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline,
            color: Colors.grey.shade400,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.email_rounded,
                color: Colors.green.shade600,
                size: 20,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'ອີເມວ',
              style: GoogleFonts.notoSansLao(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF07325D),
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'ແກ້ໄຂໄດ້',
                style: GoogleFonts.notoSansLao(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.notoSansLao(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'ກະລຸນາໃສ່ອີເມວ',
            hintStyle: GoogleFonts.notoSansLao(
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.green.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.green.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'ກະລຸນາໃສ່ອີເມວ';
            }
            // Simple email validation
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'ກະລຸນາໃສ່ອີເມວທີ່ຖືກຕ້ອງ';
            }
            return null;
          },
        ),
      ],
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
