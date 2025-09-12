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
      duration: const Duration(milliseconds: 200),
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
        child: Container(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = widget.currentIndex == index;
    final item = _navItems[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with smooth animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isSelected
                            ? Colors.white.withOpacity(0.15)
                            : Colors.transparent,
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? Colors.white : Colors.white60,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Label with smooth transition
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Active indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(top: 4),
                width: isSelected ? 20 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
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
