// widgets/home_widgets/quick_action_widget.dart - Fixed Version
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:BIBOL/services/website/contact_service.dart';
import 'package:BIBOL/models/website/contact_model.dart';
import 'package:BIBOL/utils/snackbar_utils.dart';

class QuickActionWidget extends StatefulWidget {
  final double screenWidth;

  const QuickActionWidget({Key? key, required this.screenWidth})
    : super(key: key);

  @override
  State<QuickActionWidget> createState() => _QuickActionWidgetState();
}

class _QuickActionWidgetState extends State<QuickActionWidget> {
  List<ContactModel> contacts = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      // ✅ เช็คก่อน setState แรก
      if (!mounted) return;

      setState(() {
        isLoading = true;
        hasError = false;
      });

      final contactsData = await ContactService.getContacts();

      print('✅ Contacts loaded: ${contactsData.length}');
      for (var contact in contactsData) {
        print('Contact: ${contact.displayName}');
        print('  - phone: ${contact.phone}');
        print('  - mobile: ${contact.mobile}');
        print('  - hasPhone: ${contact.hasPhone}');
        print('  - formattedPhone: ${contact.formattedPhone}');
      }

      // ✅ เช็คหลัง async operation
      if (!mounted) return;

      setState(() {
        contacts = contactsData;
        isLoading = false;
      });
    } catch (e) {
      // ✅ เช็คก่อน setState ใน catch block
      if (!mounted) return;

      setState(() {
        hasError = true;
        isLoading = false;
      });

      if (mounted) {
        SnackBarUtils.showError(
          context,
          'ເກີດຂໍ້ຜິດພາດໃນການໂຫຼດຂໍ້ມູນຕິດຕໍ່: $e',
        );
      }
    }
  }

  void _showComingSoon() {
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

  // Responsive helper methods
  bool get _isExtraSmallScreen => widget.screenWidth < 320;
  bool get _isSmallScreen => widget.screenWidth < 375;
  bool get _isMediumScreen => widget.screenWidth < 414;
  bool get _isTablet => widget.screenWidth >= 600;

  double get _basePadding {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 16.0;
    if (_isTablet) return 24.0;
    return 20.0;
  }

  double get _titleFontSize {
    if (_isExtraSmallScreen) return 18.0;
    if (_isSmallScreen) return 20.0;
    if (_isMediumScreen) return 24.0;
    if (_isTablet) return 30.0;
    return 26.0;
  }

  double get _bodyFontSize {
    if (_isExtraSmallScreen) return 13.0;
    if (_isSmallScreen) return 14.0;
    if (_isMediumScreen) return 15.0;
    if (_isTablet) return 17.0;
    return 16.0;
  }

  double get _captionFontSize {
    if (_isExtraSmallScreen) return 11.0;
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 13.0;
    if (_isTablet) return 15.0;
    return 14.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(_basePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: _titleFontSize * 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: _basePadding * 0.6),
              Text(
                'ການດຳເນີນງານດ່ວນ',
                style: GoogleFonts.notoSansLao(
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF07325D),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (isLoading)
            _buildLoadingState()
          else if (hasError)
            _buildErrorState()
          else
            _buildContactsContent(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return _isExtraSmallScreen || _isSmallScreen
        ? Column(
            children: [
              _buildLoadingCard(),
              const SizedBox(height: 14),
              _buildLoadingCard(),
            ],
          )
        : Row(
            children: [
              Expanded(child: _buildLoadingCard()),
              const SizedBox(width: 14),
              Expanded(child: _buildLoadingCard()),
            ],
          );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(_basePadding),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 32),
          const SizedBox(height: 8),
          Text(
            'ເກີດຂໍ້ຜິດພາດໃນການໂຫຼດຂໍ້ມູນ',
            style: GoogleFonts.notoSansLao(
              fontSize: _bodyFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadContacts,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'ລອງໃໝ່',
              style: GoogleFonts.notoSansLao(
                fontSize: _captionFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsContent() {
    final primaryContact = contacts.isNotEmpty ? contacts.first : null;

    String phoneSubtitle = 'ສອບຖາມຂໍ້ມູນເພີ່ມເຕີມ';

    if (primaryContact != null) {
      final phoneNumber = primaryContact.formattedPhone;
      if (phoneNumber.isNotEmpty) {
        phoneSubtitle = phoneNumber;
      }
    }

    return _isExtraSmallScreen || _isSmallScreen
        ? Column(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: _buildQuickActionCard(
                          icon: Icons.phone_rounded,
                          title: 'ຕິດຕໍ່ເຮົາ',
                          subtitle: phoneSubtitle,
                          gradientColors: [
                            Color(0xFF10B981),
                            Color(0xFF059669),
                          ],
                          onTap: () => _handleContactTap(primaryContact),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 450),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: _buildQuickActionCard(
                          icon: Icons.school_rounded,
                          title: 'ສະໝັກຮຽນ',
                          subtitle: 'ລົງທະບຽນຮຽນ',
                          gradientColors: [
                            Color(0xFFF59E0B),
                            Color(0xFFD97706),
                          ],
                          onTap:
                              _showComingSoon, // ✅ เปลี่ยนจาก () {} เป็น _showComingSoon
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: _buildQuickActionCard(
                          icon: Icons.phone_rounded,
                          title: 'ຕິດຕໍ່ເຮົາ',
                          subtitle: phoneSubtitle,
                          gradientColors: [
                            Color(0xFF10B981),
                            Color(0xFF059669),
                          ],
                          onTap: () => _handleContactTap(primaryContact),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 450),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: _buildQuickActionCard(
                          icon: Icons.school_rounded,
                          title: 'ສະໝັກຮຽນ',
                          subtitle: 'ລົງທະບຽນຮຽນ',
                          gradientColors: [
                            Color(0xFFF59E0B),
                            Color(0xFFD97706),
                          ],
                          onTap:
                              _showComingSoon, // ✅ เปลี่ยนจาก () {} เป็น _showComingSoon
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  void _handleContactTap(ContactModel? contact) {
    if (contact == null) {
      SnackBarUtils.showInfo(context, 'ບໍ່ພົບຂໍ້ມູນຕິດຕໍ່');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _buildContactDialog(contact),
    );
  }

  Widget _buildContactDialog(ContactModel contact) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        contact.displayName,
        style: GoogleFonts.notoSansLao(
          fontSize: _titleFontSize * 0.8,
          fontWeight: FontWeight.w800,
          color: Color(0xFF07325D),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contact.hasPhone) ...[
            _buildContactInfo(
              Icons.phone_rounded,
              'ເບີໂທ',
              contact.formattedPhone,
              () => _makePhoneCall(contact.primaryPhone ?? ''),
            ),
            const SizedBox(height: 12),
          ],
          if (contact.hasFax) ...[
            _buildContactInfo(Icons.fax_rounded, 'ແຟັກ', contact.fax!, null),
            const SizedBox(height: 12),
          ],
          if (contact.hasEmail) ...[
            _buildContactInfo(
              Icons.email_rounded,
              'ອີເມວ',
              contact.email!,
              () => _sendEmail(contact.email!),
            ),
            const SizedBox(height: 12),
          ],
          if (contact.hasAddress) ...[
            _buildContactInfo(
              Icons.location_on_rounded,
              'ທີ່ຢູ່',
              contact.address!,
              null,
            ),
            const SizedBox(height: 12),
          ],
          if (contact.hasWorkingTime) ...[
            _buildContactInfo(
              Icons.access_time_rounded,
              'ເວລາເຮັດວຽກ',
              contact.workingTime!,
              null,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'ປິດ',
            style: GoogleFonts.notoSansLao(
              fontSize: _bodyFontSize,
              fontWeight: FontWeight.w600,
              color: Color(0xFF07325D),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(
    IconData icon,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Color(0xFF07325D)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize * 0.9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF07325D),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    SnackBarUtils.showInfo(context, 'ກຳລັງໂທຫາ: $phoneNumber');
  }

  void _sendEmail(String email) {
    SnackBarUtils.showInfo(context, 'ກຳລັງສົ່ງອີເມວໄປ: $email');
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradientColors.first.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(
              _isExtraSmallScreen ? 14.0 : _basePadding * 1.2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        _isExtraSmallScreen ? 10.0 : _basePadding * 0.8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors.first.withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: _isExtraSmallScreen
                            ? 22.0
                            : _isSmallScreen
                            ? 24.0
                            : 28.0,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: gradientColors.first.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _isExtraSmallScreen ? 12.0 : _basePadding),
                FittedBox(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize * 1.1,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF07325D),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansLao(
                    fontSize: _captionFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
