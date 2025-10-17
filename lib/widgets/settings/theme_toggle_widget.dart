// lib/widgets/settings/theme_toggle_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:BIBOL/providers/theme_provider.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;

  const ThemeToggleWidget({
    Key? key,
    this.showLabel = false,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        if (isCompact) {
          return _buildCompactToggle(context, themeProvider, isDarkMode);
        }
        
        return _buildFullToggle(context, themeProvider, isDarkMode);
      },
    );
  }

  Widget _buildCompactToggle(BuildContext context, ThemeProvider themeProvider, bool isDarkMode) {
    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isDarkMode 
              ? const Color(0xFF2C2C2C) 
              : const Color(0xFF07325D),
          border: Border.all(
            color: isDarkMode 
                ? Colors.white.withOpacity(0.2)
                : const Color(0xFF07325D).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 16,
              color: isDarkMode 
                  ? const Color(0xFF2C2C2C) 
                  : const Color(0xFF07325D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullToggle(BuildContext context, ThemeProvider themeProvider, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context,
            themeProvider,
            ThemeMode.light,
            Icons.light_mode,
            'ສະຫວ່າງ',
            isDarkMode ? false : true,
          ),
          _buildThemeOption(
            context,
            themeProvider,
            ThemeMode.dark,
            Icons.dark_mode,
            'ມືດ',
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => themeProvider.setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF07325D) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? Colors.white 
                  : Colors.grey[600],
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.notoSansLao(
                  fontSize: 12,
                  fontWeight: isSelected 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                  color: isSelected 
                      ? Colors.white 
                      : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ThemeToggleCard extends StatelessWidget {
  const ThemeToggleCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07325D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.palette,
                      color: Color(0xFF07325D),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ທີມສີ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF07325D),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          themeProvider.themeDescription,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ThemeToggleWidget(isCompact: true),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? const Color(0xFF2C2C2C) 
                      : const Color(0xFFFAFBFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFF07325D).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      themeProvider.themeIcon,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF07325D),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ປັດຈຸບັນ: ${themeProvider.themeName}',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : const Color(0xFF07325D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'ເລືອກທີມສີ',
            style: GoogleFonts.notoSansLao(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF07325D),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.light,
                Icons.light_mode,
                'ທີມສະຫວ່າງ',
                'ສະບາຍຕາຕໍ່າວັນ',
                themeProvider.themeMode == ThemeMode.light,
              ),
              const SizedBox(height: 10),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.dark,
                Icons.dark_mode,
                'ທີມມືດ',
                'ສະບາຍຕາຕໍ່າຄືນ',
                themeProvider.themeMode == ThemeMode.dark,
              ),
              const SizedBox(height: 10),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.system,
                Icons.brightness_auto,
                'ຕາມລະບົບ',
                'ຕາມການຕັ້ງຄ່າລະບົບ',
                themeProvider.themeMode == ThemeMode.system,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'ປິດ',
                style: GoogleFonts.notoSansLao(
                  color: const Color(0xFF07325D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    IconData icon,
    String title,
    String subtitle,
    bool isSelected,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          themeProvider.setThemeMode(mode);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF07325D).withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFF07325D)
                  : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF07325D)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
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
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF07325D),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
