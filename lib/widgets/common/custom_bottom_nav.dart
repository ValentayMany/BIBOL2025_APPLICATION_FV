import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'ໜ້າຫຼັກ',
    ),
    NavItem(
      icon: Icons.article_outlined,
      activeIcon: Icons.article,
      label: 'ຂ່າວສານ',
    ),
    NavItem(
      icon: Icons.photo_library_outlined,
      activeIcon: Icons.photo_library,
      label: 'ຄັງຮູບ',
    ),
    NavItem(
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance,
      label: 'ກ່ຽວກັບ',
    ),
    NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'ໂປຣໄຟລ',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CustomBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isVerySmallScreen = screenSize.width < 320;
    
    // Calculate responsive height
    double navHeight = 65;
    if (isVerySmallScreen) {
      navHeight = 55;
    } else if (isSmallScreen) {
      navHeight = 60;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF07325D),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: navHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(index, navHeight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, double navHeight) {
    final isSelected = widget.currentIndex == index;
    final item = _navItems[index];
    
    // Calculate responsive sizes based on nav height
    final iconSize = navHeight < 60 ? 20.0 : (navHeight < 65 ? 22.0 : 24.0);
    final activeIconSize = navHeight < 60 ? 22.0 : (navHeight < 65 ? 24.0 : 26.0);
    final fontSize = navHeight < 60 ? 9.0 : (navHeight < 65 ? 10.0 : 11.0);
    final activeFontSize = navHeight < 60 ? 9.5 : (navHeight < 65 ? 10.5 : 11.5);
    final padding = navHeight < 60 ? 4.0 : (navHeight < 65 ? 6.0 : 8.0);
    final indicatorWidth = navHeight < 60 ? 20.0 : (navHeight < 65 ? 22.0 : 24.0);
    final indicatorHeight = navHeight < 60 ? 2.0 : (navHeight < 65 ? 2.5 : 3.0);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onTap(index),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: navHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                // Icon with smooth animation and bounce effect
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  tween: Tween<double>(begin: 1.0, end: isSelected ? 1.0 : 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.all(isSelected ? padding : padding - 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.transparent,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            key: ValueKey(isSelected),
                            color: isSelected ? Colors.white : Colors.white70,
                            size: isSelected ? activeIconSize : iconSize,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: navHeight < 60 ? 0.5 : 1),

                // Label with smooth transition
                Flexible( // Use Flexible to prevent overflow
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: isSelected ? activeFontSize : fontSize,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      letterSpacing: isSelected ? 0.2 : 0,
                    ),
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      offset: Offset(0, isSelected ? 0 : 0.1),
                      child: Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: navHeight < 60 ? 0.5 : 1),

                // Active indicator with smooth animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(top: navHeight < 60 ? 1 : 2),
                  width: isSelected ? indicatorWidth : 0,
                  height: isSelected ? indicatorHeight : indicatorHeight - 1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                            : [],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
