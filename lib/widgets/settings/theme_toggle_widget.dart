// lib/widgets/settings/theme_toggle_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:BIBOL/providers/theme_provider.dart';

/// 🌙 Theme Toggle Widget
/// Beautiful animated toggle for switching between light/dark mode
/// 
/// Usage:
/// ```dart
/// // Simple toggle button
/// ThemeToggleWidget()
/// 
/// // Or use the card version
/// ThemeToggleCard()
/// ```
class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;

  const ThemeToggleWidget({
    Key? key,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => themeProvider.toggleTheme(),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey.shade800 
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      key: ValueKey(isDark),
                      color: isDark ? Colors.yellow.shade700 : Colors.orange.shade700,
                      size: 24,
                    ),
                  ),
                  
                  if (showLabel) ...[
                    const SizedBox(width: 8),
                    Text(
                      isDark ? 'ມືດ' : 'ສະຫວ່າງ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🎨 Theme Toggle Card
/// Card version with more details
class ThemeToggleCard extends StatelessWidget {
  const ThemeToggleCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => themeProvider.toggleTheme(),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.purple.shade600, Colors.deepPurple.shade700]
                            : [Colors.amber.shade400, Colors.orange.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.purple : Colors.orange)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        key: ValueKey(isDark),
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Text info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDark ? 'ໂໝດມືດ' : 'ໂໝດສະຫວ່າງ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDark 
                              ? 'ສະບາຍຕາໃນຕອນກາງຄືນ' 
                              : 'ເຫມາະສຳລັບຕອນກາງວັນ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Toggle switch
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 56,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.purple.shade600, Colors.deepPurple.shade700]
                            : [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: isDark ? 26 : 2,
                          top: 2,
                          bottom: 2,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              size: 16,
                              color: isDark 
                                  ? Colors.purple.shade700 
                                  : Colors.orange.shade700,
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
      },
    );
  }
}

/// 🎯 Theme Selection Dialog
/// Shows options for Light, Dark, and System theme
class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'ເລືອກໂໝດສີ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Light mode option
                _buildThemeOption(
                  context: context,
                  themeMode: ThemeMode.light,
                  icon: Icons.light_mode_rounded,
                  title: 'ໂໝດສະຫວ່າງ',
                  subtitle: 'ເຫມາະສຳລັບຕອນກາງວັນ',
                  color: Colors.orange.shade600,
                  isSelected: themeProvider.themeMode == ThemeMode.light,
                  onTap: () {
                    themeProvider.setLightMode();
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 12),

                // Dark mode option
                _buildThemeOption(
                  context: context,
                  themeMode: ThemeMode.dark,
                  icon: Icons.dark_mode_rounded,
                  title: 'ໂໝດມືດ',
                  subtitle: 'ສະບາຍຕາໃນຕອນກາງຄືນ',
                  color: Colors.purple.shade600,
                  isSelected: themeProvider.themeMode == ThemeMode.dark,
                  onTap: () {
                    themeProvider.setDarkMode();
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 12),

                // System mode option
                _buildThemeOption(
                  context: context,
                  themeMode: ThemeMode.system,
                  icon: Icons.brightness_auto_rounded,
                  title: 'ອັດຕະໂນມັດ',
                  subtitle: 'ຕາມລະບົບ',
                  color: Colors.blue.shade600,
                  isSelected: themeProvider.themeMode == ThemeMode.system,
                  onTap: () {
                    themeProvider.setSystemTheme();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeMode themeMode,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? color.withOpacity(0.1) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSansLao(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSansLao(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
