// lib/screens/settings/settings_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ຕັ້ງຄ່າ',
          style: GoogleFonts.notoSansLao(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF07325D),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF07325D),
              Color(0xFF0A4A85),
              Color(0xFFFAFBFF),
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(),
                
                const SizedBox(height: 30),
                
                // App Settings Section
                _buildAppSettingsSection(context),
                
                const SizedBox(height: 30),
                
                // About Section
                _buildAboutSection(context),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ການຕັ້ງຄ່າແອັບ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'ປັບແຕ່ງການຕັ້ງຄ່າຕາມຄວາມຕ້ອງການ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAppSettingsSection(BuildContext context) {
    return _buildSectionCard(
      title: 'ການຕັ້ງຄ່າແອັບ',
      icon: Icons.app_settings_alt,
      children: [
        _buildSettingsItem(
          icon: Icons.notifications,
          title: 'ການແຈ້ງເຕືອນ',
          subtitle: 'ຈັດການການແຈ້ງເຕືອນ',
          onTap: () => _showComingSoon(context),
        ),
        _buildSettingsItem(
          icon: Icons.language,
          title: 'ພາສາ',
          subtitle: 'ເລືອກພາສາ',
          onTap: () => _showComingSoon(context),
        ),
        _buildSettingsItem(
          icon: Icons.storage,
          title: 'ການເກັບຂໍ້ມູນ',
          subtitle: 'ຈັດການການເກັບຂໍ້ມູນ',
          onTap: () => _showComingSoon(context),
        ),
        _buildSettingsItem(
          icon: Icons.security,
          title: 'ຄວາມປອດໄພ',
          subtitle: 'ການຕັ້ງຄ່າຄວາມປອດໄພ',
          onTap: () => _showComingSoon(context),
        ),
        _buildSettingsItem(
          icon: Icons.backup,
          title: 'ສຳຮອງຂໍ້ມູນ',
          subtitle: 'ສຳຮອງແລະກູ້ຄືນຂໍ້ມູນ',
          onTap: () => _showComingSoon(context),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSectionCard(
      title: 'ກ່ຽວກັບ',
      icon: Icons.info,
      children: [
        _buildSettingsItem(
          icon: Icons.info_outline,
          title: 'ກ່ຽວກັບແອັບ',
          subtitle: 'ຂໍ້ມູນແອັບ',
          onTap: () => _showAboutDialog(context),
        ),
        _buildSettingsItem(
          icon: Icons.help_outline,
          title: 'ຊ່ວຍເຫຼືອ',
          subtitle: 'ຄູ່ມືການໃຊ້ງານ',
          onTap: () => _showComingSoon(context),
        ),
        _buildSettingsItem(
          icon: Icons.privacy_tip_outlined,
          title: 'ນະໂຍບາຍຄວາມເປັນສ່ວນຕົວ',
          subtitle: 'ອ່ານນະໂຍບາຍ',
          onTap: () => _showComingSoon(context),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF07325D).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07325D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF07325D),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF07325D),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07325D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF07325D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.notoSansLao(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF07325D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.notoSansLao(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
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
          style: GoogleFonts.notoSansLao(
            color: Colors.grey[600],
          ),
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'BIBOL App',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF07325D),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.account_balance,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        Text(
          'ແອັບພລິເຄຊັນສຳລັບສະຖາບັນການທະນາຄານລາວ',
          style: GoogleFonts.notoSansLao(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
