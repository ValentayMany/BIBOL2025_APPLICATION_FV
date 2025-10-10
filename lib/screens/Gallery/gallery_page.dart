import 'package:BIBOL/models/gallery/gallery_model.dart';
import 'package:BIBOL/screens/gallery/gallery_detail_page.dart';
import 'package:BIBOL/services/gallery/gallery_service.dart';
import 'package:BIBOL/widgets/common/custom_bottom_nav.dart';
import 'package:BIBOL/services/token/token_service.dart';
import 'package:BIBOL/widgets/shared/modern_drawer_widget.dart';
import 'package:BIBOL/widgets/shared/shared_header_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with SingleTickerProviderStateMixin {
  final GalleryService _galleryService = GalleryService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  List<GalleryModel> galleryItems = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  final int itemsPerPage = 10;
  String userId = '1';

  int _currentIndex = 2;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userInfo;

  late AnimationController _animationController;
  String _selectedFilter = 'ທັງໝົດ';
  final List<String> _filters = ['ທັງໝົດ', 'ຫຼ້າສຸດ', 'ຍອດນິຍົມ'];

  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;
  bool get _isTablet => _screenWidth >= 600;

  double get _basePadding {
    if (_screenWidth < 320) return 8.0;
    if (_screenWidth < 360) return 12.0;
    if (_screenWidth < 400) return 16.0;
    if (_screenWidth < 480) return 18.0;
    return 20.0;
  }

  double _scale(double value) {
    if (_screenWidth < 320) return value * 0.8;
    if (_screenWidth < 375) return value * 0.9;
    if (_isTablet) return value * 1.2;
    return value;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController.addListener(_onScroll);
    _checkLoginStatus();
    loadGallery();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && galleryItems.length >= itemsPerPage) {
        loadMoreItems();
      }
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await TokenService.isLoggedIn();
      final userInfo = await TokenService.getUserInfo();

      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _userInfo = userInfo;
        });
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  Future<void> loadGallery() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await _galleryService.getUserGallery(
      userId: userId,
      page: currentPage,
      count: itemsPerPage,
    );

    setState(() {
      if (response != null) {
        galleryItems = response.topics;
      }
      isLoading = false;
    });

    _animationController.forward();
  }

  Future<void> loadMoreItems() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    final response = await _galleryService.getUserGallery(
      userId: userId,
      page: currentPage,
      count: itemsPerPage,
    );

    setState(() {
      if (response != null) {
        galleryItems.addAll(response.topics);
      }
      isLoadingMore = false;
    });
  }

  Future<void> refreshGallery() async {
    currentPage = 1;
    galleryItems.clear();
    _animationController.reset();
    await loadGallery();
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/news');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/about');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  Future<void> _handleLogout() async {
    // Save reference to ScaffoldMessenger before any async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'ອອກຈາກລະບົບ',
                  style: GoogleFonts.notoSansLao(
                    color: const Color(0xFF07325D),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
              'ທ່ານຕ້ອງການອອກຈາກລະບົບບໍ່?',
              style: GoogleFonts.notoSansLao(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ຍົກເລີກ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await TokenService.clearAll();
                  await _checkLoginStatus();
                  if (mounted) {
                    // Use the saved reference instead of looking it up from context
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'ອອກຈາກລະບົບສຳເລັດ',
                          style: GoogleFonts.notoSansLao(fontSize: 14),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'ອອກຈາກລະບົບ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleLogin() async {
    final result = await Navigator.pushNamed(context, '/login');
    if (result == true) await _checkLoginStatus();
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
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFF),
      extendBodyBehindAppBar: true,
      drawer: ModernDrawerWidget(
        isLoggedIn: _isLoggedIn,
        userInfo: _userInfo,
        screenWidth: _screenWidth,
        screenHeight: _screenHeight,
        onLogoutPressed: _handleLogout,
        onLoginPressed: _handleLogin,
        currentRoute: '/gallery',
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(),
          SliverToBoxAdapter(child: _buildModernStats()),
          SliverToBoxAdapter(child: _buildModernFilterChips()),
          _buildGalleryContent(),
          if (isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF07325D).withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF07325D),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: _scale(200),
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF07325D),
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF06304F), Color(0xFF07325D), Color(0xFF0A4A85)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SharedHeaderButton(
                        icon: Icons.menu_rounded,
                        onPressed:
                            () => _scaffoldKey.currentState?.openDrawer(),
                        screenWidth: _screenWidth,
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: refreshGallery,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(_scale(10)),
                              child: Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: _scale(22),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(_scale(12)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.collections_rounded,
                          color: Colors.white,
                          size: _scale(32),
                        ),
                      ),
                      SizedBox(width: _scale(16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ແກລເລີຣີ',
                              style: GoogleFonts.notoSansLao(
                                color: Colors.white,
                                fontSize: _scale(30),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: _scale(4)),
                            Text(
                              'ຄັງຮູບພາບແລະວິດີໂອ',
                              style: GoogleFonts.notoSansLao(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: _scale(14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernStats() {
    return Padding(
      padding: EdgeInsets.fromLTRB(_basePadding, _basePadding, _basePadding, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(_scale(16)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF8FAFF)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Color(0xFF07325D).withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF07325D).withOpacity(0.08),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(_scale(10)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: _scale(24),
                    ),
                  ),
                  SizedBox(width: _scale(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ທັງໝົດ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: _scale(12),
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: _scale(2)),
                        Text(
                          '${galleryItems.length}',
                          style: GoogleFonts.notoSansLao(
                            fontSize: _scale(24),
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF07325D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: _scale(12)),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(_scale(16)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF8FAFF)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Color(0xFF10B981).withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF10B981).withOpacity(0.08),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(_scale(10)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.visibility_rounded,
                      color: Colors.white,
                      size: _scale(24),
                    ),
                  ),
                  SizedBox(width: _scale(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ເບິ່ງແລ້ວ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: _scale(12),
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: _scale(2)),
                        Text(
                          '${galleryItems.fold<int>(0, (sum, item) => sum + item.visits)}',
                          style: GoogleFonts.notoSansLao(
                            fontSize: _scale(24),
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF07325D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _basePadding,
        vertical: _scale(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          children:
              _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(right: _scale(10)),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: _scale(20),
                        vertical: _scale(12),
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            isSelected
                                ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF07325D),
                                    Color(0xFF0A4A85),
                                  ],
                                )
                                : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Color(0xFF07325D)
                                  : Colors.grey.shade300,
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Color(0xFF07325D).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ]
                                : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: _scale(16),
                            ),
                            SizedBox(width: _scale(6)),
                          ],
                          Text(
                            filter,
                            style: GoogleFonts.notoSansLao(
                              color:
                                  isSelected ? Colors.white : Color(0xFF07325D),
                              fontSize: _scale(14),
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildGalleryContent() {
    if (isLoading && galleryItems.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF07325D).withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
            ),
          ),
        ),
      );
    }

    if (galleryItems.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(_scale(32)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF07325D).withOpacity(0.1),
                      Color(0xFF0A4A85).withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: _scale(64),
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: _scale(24)),
              Text(
                'ບໍ່ມີຮູບພາບ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.grey[700],
                  fontSize: _scale(18),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: _scale(8)),
              Text(
                'ລໍຖ້າຮູບພາບໃໝ່ໆເຂົ້າມາໃນໄວໆນີ້',
                style: GoogleFonts.notoSansLao(
                  color: Colors.grey[500],
                  fontSize: _scale(14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.all(_basePadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _isTablet ? 3 : 2,
          crossAxisSpacing: _scale(12),
          mainAxisSpacing: _scale(12),
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 50)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: _buildModernGalleryCard(galleryItems[index]),
                ),
              );
            },
          );
        }, childCount: galleryItems.length),
      ),
    );
  }

  Widget _buildModernGalleryCard(GalleryModel item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailScreen(gallery: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(_scale(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFAFBFF)],
          ),
          borderRadius: BorderRadius.circular(_scale(16)),
          border: Border.all(
            color: Color(0xFF07325D).withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF07325D).withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_scale(16)),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child:
                          item.photoFile.isNotEmpty
                              ? Image.network(
                                item.photoFile,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.grey.shade200,
                                          Colors.grey.shade100,
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: _scale(40),
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.grey.shade200,
                                          Colors.grey.shade100,
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFF07325D),
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey.shade200,
                                      Colors.grey.shade100,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: _scale(40),
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(_scale(16)),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Views badge
                  Positioned(
                    top: _scale(10),
                    right: _scale(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _scale(10),
                        vertical: _scale(6),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(_scale(16)),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: _scale(14),
                            color: Colors.white,
                          ),
                          SizedBox(width: _scale(4)),
                          Text(
                            '${item.visits}',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _scale(11),
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(_scale(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.notoSansLao(
                        fontSize: _scale(14),
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF07325D),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(_scale(4)),
                          decoration: BoxDecoration(
                            color: Color(0xFF07325D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: _scale(12),
                            color: Color(0xFF07325D),
                          ),
                        ),
                        SizedBox(width: _scale(6)),
                        Expanded(
                          child: Text(
                            item.date,
                            style: GoogleFonts.notoSansLao(
                              fontSize: _scale(11),
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
