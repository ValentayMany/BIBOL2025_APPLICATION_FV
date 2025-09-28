import 'dart:ui';
import 'package:BIBOL/screens/News/all_news_details.dart';
import 'package:flutter/material.dart';
import 'package:BIBOL/services/news/news_service.dart';
import 'package:BIBOL/models/news/news_response.dart';
import 'package:BIBOL/models/topic/topic_model.dart';
import 'package:BIBOL/models/topic/joined_category_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'package:BIBOL/services/token/token_service.dart';

const Color kPrimaryColor = Color(0xFF07325D);

class NewsListPage extends StatefulWidget {
  final String? categoryId;
  final String? categoryTitle;

  const NewsListPage({Key? key, this.categoryId, this.categoryTitle})
    : super(key: key);

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage>
    with TickerProviderStateMixin {
  int _currentIndex = 1;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userInfo;
  NewsResponse? _newsResponse;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 35;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Category management
  List<Topic> _allTopics = [];
  List<JoinedCategory> _availableCategories = [];
  String _selectedCategoryId = 'all';
  bool _hasMoreData = true;

  final primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
  );

  // Enhanced responsive breakpoints
  static const double _verySmallBreakpoint = 320;
  static const double _smallBreakpoint = 360;
  static const double _mediumBreakpoint = 400;
  static const double _largeBreakpoint = 480;
  static const double _tabletBreakpoint = 600;

  // Screen size helpers with more granular breakpoints
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  bool get _isVerySmallScreen => _screenWidth < _verySmallBreakpoint;
  bool get _isTinyScreen => _screenWidth < _smallBreakpoint;
  bool get _isSmallScreen => _screenWidth < _mediumBreakpoint;
  bool get _isMediumScreen => _screenWidth < _largeBreakpoint;
  bool get _isLargeScreen => _screenWidth < _tabletBreakpoint;
  bool get _isShortScreen => _screenHeight < 700;
  bool get _isVeryShortScreen => _screenHeight < 600;

  // Responsive dimensions with more granular scaling
  double get _basePadding {
    if (_isVerySmallScreen) return 8.0;
    if (_isTinyScreen) return 12.0;
    if (_isSmallScreen) return 16.0;
    if (_isMediumScreen) return 18.0;
    if (_isLargeScreen) return 20.0;
    return 24.0;
  }

  double get _smallPadding => _basePadding * 0.75;
  double get _largePadding => _basePadding * 1.5;

  // Responsive font sizes
  double get _titleFontSize {
    if (_isVerySmallScreen) return 18.0;
    if (_isTinyScreen) return 20.0;
    if (_isSmallScreen) return 22.0;
    if (_isMediumScreen) return 24.0;
    return 26.0;
  }

  double get _subtitleFontSize {
    if (_isVerySmallScreen) return 10.0;
    if (_isTinyScreen) return 11.0;
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 13.0;
    return 14.0;
  }

  double get _bodyFontSize {
    if (_isVerySmallScreen) return 11.0;
    if (_isTinyScreen) return 12.0;
    if (_isSmallScreen) return 13.0;
    if (_isMediumScreen) return 14.0;
    return 15.0;
  }

  double get _captionFontSize {
    if (_isVerySmallScreen) return 9.0;
    if (_isTinyScreen) return 10.0;
    if (_isSmallScreen) return 11.0;
    return 12.0;
  }

  // Responsive icon sizes
  double get _iconSize {
    if (_isVerySmallScreen) return 16.0;
    if (_isTinyScreen) return 18.0;
    if (_isSmallScreen) return 20.0;
    if (_isMediumScreen) return 22.0;
    return 24.0;
  }

  double get _logoSize {
    if (_isVerySmallScreen) return 50.0;
    if (_isTinyScreen) return 60.0;
    if (_isSmallScreen) return 70.0;
    if (_isMediumScreen) return 80.0;
    return 90.0;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollController.addListener(_onScroll);
    _loadInitialNews();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreNews();
    }

    if (_scrollController.position.pixels > 100) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  Future<void> _loadInitialNews() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final response = await NewsService.getNews(limit: _itemsPerPage, page: 1);

      if (!mounted) return;

      if (response.success && response.data.isNotEmpty) {
        final allTopics = <Topic>[];
        for (final newsModel in response.data) {
          allTopics.addAll(newsModel.topics);
        }

        setState(() {
          _allTopics = allTopics;
          _currentPage = 1;
          _hasMoreData = allTopics.length >= _itemsPerPage;
          _updateAvailableCategories();
          _isLoading = false;
        });

        if (mounted) {
          _animationController.forward();
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage('ຜິດພາດ: $e');
    }
  }

  Future<void> _loadNews({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _selectedCategoryId = 'all';
        _allTopics.clear();
        _availableCategories.clear();
      });
      await _loadInitialNews();
    }
  }

  void _updateAvailableCategories() {
    final Map<String, JoinedCategory> uniqueCategories = {};

    for (final topic in _allTopics) {
      if (topic.joinedCategories.isNotEmpty) {
        for (final category in topic.joinedCategories) {
          uniqueCategories[category.title] = category;
        }
      }
    }

    setState(() {
      _availableCategories =
          uniqueCategories.values.toList()
            ..sort((a, b) => a.title.compareTo(b.title));
    });
  }

  List<Topic> get _filteredTopics {
    if (_selectedCategoryId == 'all') {
      return _allTopics;
    }

    final selectedCategory = _availableCategories.firstWhere(
      (cat) => cat.id.toString() == _selectedCategoryId,
      orElse:
          () => JoinedCategory(
            id: 0,
            title: '',
            icon: null,
            photo: null,
            href: '',
          ),
    );

    if (selectedCategory.title.isEmpty) return _allTopics;

    return _allTopics.where((topic) {
      return topic.joinedCategories.any(
        (cat) => cat.title == selectedCategory.title,
      );
    }).toList();
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);

    try {
      final response = await NewsService.getNews(
        limit: _itemsPerPage,
        page: _currentPage + 1,
      );

      if (response.success && response.data.isNotEmpty) {
        final newTopics = <Topic>[];
        for (final newsModel in response.data) {
          newTopics.addAll(newsModel.topics);
        }

        setState(() {
          _allTopics.addAll(newTopics);
          _currentPage++;
          _isLoadingMore = false;
          _hasMoreData = newTopics.length >= _itemsPerPage;
          _updateAvailableCategories();
        });
      } else {
        setState(() {
          _isLoadingMore = false;
          _hasMoreData = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _hasMoreData = false;
      });
      _showMessage('ຜິດພາດໃນການໂຫຼດຂ່າວເພີ່ມເຕີມ: $e');
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
      print('❌ Error checking login status: $e');
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Color(0xFF07325D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'ອອກຈາກລະບົບ',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: _bodyFontSize,
              ),
            ),
            content: Text(
              'ທ່ານຕ້ອງການອອກຈາກລະບົບບໍ່?',
              style: GoogleFonts.notoSansLao(
                color: Colors.white70,
                fontSize: _subtitleFontSize,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ຍົກເລີກ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white70,
                    fontSize: _captionFontSize,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await TokenService.clearAll();
                  await _checkLoginStatus();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: _iconSize,
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'ອອກຈາກລະບົບສຳເລັດ',
                                style: GoogleFonts.notoSansLao(
                                  fontSize: _subtitleFontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.all(_basePadding),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'ອອກຈາກລະບົບ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white,
                    fontSize: _captionFontSize,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _searchNews(String query) async {
    if (query.trim().isEmpty) {
      _loadNews(isRefresh: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await NewsService.searchNews(
        query.trim(),
        limit: 50,
        page: 1,
      );

      if (response.success) {
        final searchTopics = <Topic>[];
        for (final newsModel in response.data) {
          searchTopics.addAll(newsModel.topics);
        }

        setState(() {
          _allTopics = searchTopics;
          _isLoading = false;
          _hasMoreData = false;
          _selectedCategoryId = 'all';
          _updateAvailableCategories();
        });
      } else {
        setState(() => _isLoading = false);
        _showMessage('ບໍ່ພົບຜົນການຄົ້ນຫາ');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('ຜິດພາດໃນການຄົ້ນຫາ: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(_smallPadding),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.white,
                size: _iconSize,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.notoSansLao(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: _subtitleFontSize,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(_basePadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 12,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);

    final routes = ['/home', '/news', '/gallery', '/about', '/profile'];
    if (index != 1) Navigator.pushReplacementNamed(context, routes[index]);
  }

  void _onTopicTap(Topic topic) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                TopicDetailPage(topic: topic),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} ວັນທີ່ຜ່ານມາ';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ຊົ່ວໂມງທີ່ຜ່ານມາ';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ນາທີທີ່ຜ່ານມາ';
      } else {
        return 'ຫາກໍ່ນີ້';
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFF8FAFF),
      drawer: _buildModernDrawer(),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimationController,
        child: FloatingActionButton.extended(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            );
          },
          backgroundColor: Color(0xFF07325D),
          icon: Icon(
            Icons.keyboard_arrow_up_rounded,
            color: Colors.white,
            size: _iconSize,
          ),
          label: Text(
            'ກັບຂື້ນ',
            style: GoogleFonts.notoSansLao(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: _captionFontSize,
            ),
          ),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          _buildHeaderSection(),
          if (_availableCategories.isNotEmpty) _buildCategoryFilterSection(),
          _isLoading && _allTopics.isEmpty
              ? SliverFillRemaining(child: _buildLoadingState())
              : _buildNewsGrid(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(_basePadding * 2),
            bottomRight: Radius.circular(_basePadding * 2),
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
            padding: EdgeInsets.all(_basePadding),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildHeaderButton(
                      icon: Icons.menu_rounded,
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Spacer(),
                    _buildHeaderButton(
                      icon: Icons.notifications_outlined,
                      onPressed: () {
                        // TODO: Handle notifications
                      },
                      hasNotification: true,
                    ),
                  ],
                ),
                SizedBox(height: _smallPadding),
                TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: Column(
                          children: [
                            Container(
                              width: _logoSize,
                              height: _logoSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(_smallPadding),
                                child: Image.asset(
                                  'assets/images/LOGO.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            FittedBox(
                              child: Text(
                                'ຂ່າວສານ',
                                style: GoogleFonts.notoSansLao(
                                  fontSize: _titleFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Text(
                              'ສະຖາບັນການທະນາຄານ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: _subtitleFontSize,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),
                _buildSearchSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool hasNotification = false,
  }) {
    final buttonSize = _isVerySmallScreen ? 40.0 : 44.0;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(icon, color: Colors.white, size: _iconSize),
            onPressed: onPressed,
            constraints: BoxConstraints(
              minWidth: buttonSize,
              minHeight: buttonSize,
            ),
            padding: EdgeInsets.zero,
          ),
          if (hasNotification)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 600,
        minHeight: _isVerySmallScreen ? 45 : 55,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
                Future.delayed(Duration(milliseconds: 500), () {
                  if (_searchQuery == value) {
                    _searchNews(value);
                  }
                });
              },
              style: GoogleFonts.notoSansLao(fontSize: _bodyFontSize),
              decoration: InputDecoration(
                hintText:
                    _isVerySmallScreen
                        ? 'ຄົ້ນຫາ...'
                        : _isTinyScreen
                        ? 'ຄົ້ນຫາຂ່າວ...'
                        : 'ຄົ້ນຫາຂ່າວທີ່ສົນໃຈ...',
                hintStyle: GoogleFonts.notoSansLao(
                  color: Colors.grey[500],
                  fontSize: _bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Container(
                  padding: EdgeInsets.all(_smallPadding),
                  child: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF07325D),
                    size: _iconSize * 1.2,
                  ),
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? Container(
                          padding: EdgeInsets.all(8),
                          child: IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.grey[600],
                                size: _iconSize * 0.8,
                              ),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _loadNews(isRefresh: true);
                            },
                          ),
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: _basePadding,
                  vertical: _basePadding * 0.8,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: _basePadding, vertical: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildGlassCategoryChip(
                id: 'all',
                title: 'ທັງໝົດ',
                icon: Icons.grid_view_rounded,
                isSelected: _selectedCategoryId == 'all',
              ),
              SizedBox(width: 16),
              ..._availableCategories.map((category) {
                return Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: _buildGlassCategoryChip(
                    id: category.id.toString(),
                    title: category.title,
                    icon: Icons.label_rounded,
                    isSelected: _selectedCategoryId == category.id.toString(),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCategoryChip({
    required String id,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = id;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        padding: EdgeInsets.symmetric(
          horizontal: _basePadding,
          vertical: _smallPadding,
        ),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                  )
                  : null,
          color: isSelected ? null : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                isSelected
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Color(0xFF07325D).withOpacity(0.4),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: _iconSize * 0.8,
              color: isSelected ? Colors.white : Color(0xFF07325D),
            ),
            SizedBox(width: _smallPadding * 0.5),
            Text(
              title,
              style: GoogleFonts.notoSansLao(
                fontSize: _subtitleFontSize,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      width:
          MediaQuery.of(context).size.width * (_isVerySmallScreen ? 0.85 : 0.8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(),
              Expanded(child: _buildDrawerMenu()),
              _buildDrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: EdgeInsets.all(_basePadding),
      child: Column(
        children: [
          Container(
            width: _logoSize * 0.8,
            height: _logoSize * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _isLoggedIn
                  ? Icons.account_circle_rounded
                  : Icons.menu_book_rounded,
              color: Color(0xFF07325D),
              size: _logoSize * 0.5,
            ),
          ),
          SizedBox(height: _smallPadding),
          FittedBox(
            child: Text(
              'ສະບາຍດີ!',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: _titleFontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (_isLoggedIn && _userInfo != null) ...[
            SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: Column(
                children: [
                  Text(
                    "${_userInfo!['first_name'] ?? ''} ${_userInfo!['last_name'] ?? ''}"
                        .trim(),
                    style: GoogleFonts.notoSansLao(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_userInfo!['student_id'] != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'ລະຫັດ: ${_userInfo!['student_id']}',
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: _subtitleFontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ] else
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: Text(
                'ຍິນດີຕ້ອນຮັບ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: _bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerMenu() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _smallPadding),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildDrawerItem(
              icon: Icons.home_rounded,
              title: 'ໜ້າຫຼັກ',
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            _buildDrawerItem(
              icon: Icons.newspaper_rounded,
              title: 'ຂ່າວສານ',
              isSelected: true,
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.photo_library_rounded,
              title: 'ຮູບພາບ',
              onTap: () => Navigator.pushReplacementNamed(context, '/gallery'),
            ),
            _buildDrawerItem(
              icon: Icons.info_rounded,
              title: 'ກ່ຽວກັບ',
              onTap: () => Navigator.pushReplacementNamed(context, '/about'),
            ),
            if (_isLoggedIn)
              _buildDrawerItem(
                icon: Icons.person_rounded,
                title: 'ໂປຣໄຟລ໌',
                onTap:
                    () => Navigator.pushReplacementNamed(context, '/profile'),
              ),
            Container(
              margin: EdgeInsets.symmetric(vertical: _smallPadding),
              child: Divider(color: Colors.white.withOpacity(0.3)),
            ),
            _buildDrawerItem(
              icon: Icons.settings_rounded,
              title: 'ຕັ້ງຄ່າ',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.help_rounded,
              title: 'ຊ່ວຍເຫຼືອ',
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: _basePadding),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final itemHeight = _isVerySmallScreen ? 44.0 : 52.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: _smallPadding * 0.5),
      constraints: BoxConstraints(minHeight: itemHeight),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: _smallPadding,
              vertical: _smallPadding,
            ),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: _iconSize),
                SizedBox(width: _smallPadding),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansLao(
                      color: Colors.white,
                      fontSize: _subtitleFontSize,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: EdgeInsets.all(_basePadding),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 280,
          minHeight: _isVerySmallScreen ? 40 : 48,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                _isLoggedIn
                    ? _handleLogout
                    : () async {
                      Navigator.pop(context);
                      final result = await Navigator.pushNamed(
                        context,
                        '/login',
                      );
                      if (result == true) {
                        await _checkLoginStatus();
                      }
                    },
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _smallPadding,
                vertical: _smallPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                    color: Colors.white,
                    size: _iconSize,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        _isLoggedIn ? 'ອອກຈາກລະບົບ' : 'ເຂົ້າສູ່ລະບົບ',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: _subtitleFontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(_basePadding * 1.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF07325D).withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                strokeWidth: _isVerySmallScreen ? 3 : 4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'ກຳລັງໂຫຼດຂ່າວ...',
              style: GoogleFonts.notoSansLao(
                color: Colors.grey[600],
                fontSize: _bodyFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ກະລຸນາລໍຖ້າສັກຄູ່',
              style: GoogleFonts.notoSansLao(
                color: Colors.grey[400],
                fontSize: _subtitleFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsGrid() {
    final displayTopics = _filteredTopics;
    if (displayTopics.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    int itemCount = displayTopics.length;
    if (_isLoadingMore) itemCount += 4;

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(_basePadding),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(
                horizontal: _basePadding,
                vertical: _smallPadding,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF07325D).withOpacity(0.1),
                    Color(0xFF0A4A85).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFF07325D).withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.article_rounded,
                        color: Color(0xFF07325D),
                        size: _iconSize,
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'ພົບ ${displayTopics.length} ຂ່າວ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: _bodyFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedCategoryId != 'all') ...[
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ໝວດ: ${_availableCategories.firstWhere((cat) => cat.id.toString() == _selectedCategoryId, orElse: () => JoinedCategory(id: 0, title: '', icon: null, photo: null, href: '')).title}',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontSize: _captionFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                double childAspectRatio;

                // ปรับปรุงการคำนวณ Grid ให้เหมาะสมกับหน้าจอขนาด 476dp
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4;
                  childAspectRatio = 0.85;
                } else if (constraints.maxWidth > 900) {
                  crossAxisCount = 3;
                  childAspectRatio = 0.8;
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                  childAspectRatio = 0.75;
                } else if (constraints.maxWidth > _largeBreakpoint) {
                  crossAxisCount = 2;
                  childAspectRatio = 0.9; // เพิ่มความสูงเล็กน้อย
                } else if (constraints.maxWidth > _mediumBreakpoint) {
                  crossAxisCount = 2;
                  childAspectRatio = 0.85; // เพิ่มความสูงสำหรับหน้าจอกลาง
                } else if (constraints.maxWidth > _smallBreakpoint) {
                  crossAxisCount = 2;
                  childAspectRatio = 0.8; // เพิ่มความสูงสำหรับหน้าจอเล็ก
                } else if (constraints.maxWidth > _verySmallBreakpoint) {
                  crossAxisCount = 1;
                  childAspectRatio = 1.4; // เพิ่มความสูงสำหรับ single column
                } else {
                  crossAxisCount = 1;
                  childAspectRatio = 1.3;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: _smallPadding,
                    mainAxisSpacing: _smallPadding,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index >= displayTopics.length) {
                      return _buildLoadingCard();
                    }

                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final slideAnimation = Tween<Offset>(
                          begin: Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              (index * 0.1).clamp(0.0, 1.0),
                              ((index * 0.1) + 0.4).clamp(0.0, 1.0),
                              curve: Curves.easeOutBack,
                            ),
                          ),
                        );

                        return SlideTransition(
                          position: slideAnimation,
                          child: FadeTransition(
                            opacity: _animationController,
                            child: _buildModernNewsCard(
                              displayTopics[index],
                              index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNewsCard(Topic topic, int index) {
    final gradients = [
      LinearGradient(colors: [Color(0xFF07325D), Color(0xFF0A4A85)]),
      LinearGradient(colors: [Color(0xFF07325D), Color(0xFF1D5A96)]),
      LinearGradient(colors: [Color(0xFF0A4A85), Color(0xFF07325D)]),
      LinearGradient(colors: [Color(0xFF1D5A96), Color(0xFF07325D)]),
      LinearGradient(
        colors: [Color(0xFF07325D).withOpacity(0.8), Color(0xFF0A4A85)],
      ),
      LinearGradient(colors: [Color(0xFF0A4A85), Color(0xFF1D5A96)]),
    ];

    final cardGradient = gradients[index % gradients.length];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => _onTopicTap(topic),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_basePadding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_basePadding),
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section - ปรับปรุงสัดส่วน
                    Expanded(
                      flex: _isVerySmallScreen ? 5 : 4, // เพิ่มพื้นที่รูปภาพ
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            child:
                                topic.hasImage && topic.photoFile.isNotEmpty
                                    ? Image.network(
                                      topic.photoFile,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: cardGradient,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: cardGradient,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.article_rounded,
                                              color: Colors.white,
                                              size: _iconSize * 1.5,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      decoration: BoxDecoration(
                                        gradient: cardGradient,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.article_rounded,
                                          color: Colors.white,
                                          size: _iconSize * 1.5,
                                        ),
                                      ),
                                    ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),
                                ],
                                stops: [0.0, 0.3, 1.0],
                              ),
                            ),
                          ),

                          // Category tag - ลบออก
                        ],
                      ),
                    ),
                    // Content section - ปรับปรุงพื้นที่เนื้อหา
                    Expanded(
                      flex:
                          _isVerySmallScreen
                              ? 3
                              : 3, // ลดพื้นที่เนื้อหาเล็กน้อย
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.all(_smallPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title - ปรับปรุงให้ไม่ทับกัน
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: Text(
                                  topic.displayTitle,
                                  style: GoogleFonts.notoSansLao(
                                    fontSize: _subtitleFontSize,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey[900],
                                    height: 1.2, // ลด line height
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines:
                                      _isVerySmallScreen ? 2 : 2, // จำกัดบรรทัด
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(height: _smallPadding * 0.5), // ลดระยะห่าง
                            // Bottom section - ปรับขนาดให้เหมาะสม
                            Container(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.visibility_rounded,
                                        size: _iconSize * 0.7,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${topic.visits}',
                                        style: GoogleFonts.notoSansLao(
                                          fontSize: _captionFontSize,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Container(
                                    height:
                                        _isVerySmallScreen
                                            ? 26
                                            : 30, // เพิ่มความสูงปุ่ม
                                    decoration: BoxDecoration(
                                      color: Color(0xFF07325D),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF07325D,
                                          ).withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: () => _onTopicTap(topic),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: _basePadding,
                                            vertical: _smallPadding * 0.6,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'ອ່ານ',
                                            style: GoogleFonts.notoSansLao(
                                              color: Colors.white,
                                              fontSize: _captionFontSize,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_basePadding),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: _isVerySmallScreen ? 5 : 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_basePadding),
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(_smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: _subtitleFontSize,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: _subtitleFontSize,
                    width: double.infinity * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Container(
                        height: _captionFontSize,
                        width: _isVerySmallScreen ? 30 : 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: _isVerySmallScreen ? 22 : 26,
                        width: _isVerySmallScreen ? 40 : 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _selectedCategoryId != 'all';
    final selectedCategoryName =
        isFiltered
            ? _availableCategories
                .firstWhere(
                  (cat) => cat.id.toString() == _selectedCategoryId,
                  orElse:
                      () => JoinedCategory(
                        id: 0,
                        title: '',
                        icon: null,
                        photo: null,
                        href: '',
                      ),
                )
                .title
            : '';

    return Container(
      padding: EdgeInsets.all(_basePadding * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: _logoSize * 1.5,
            height: _logoSize * 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF07325D).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              isFiltered ? Icons.filter_alt_outlined : Icons.article_outlined,
              size: _logoSize * 0.8,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32),
          Text(
            isFiltered
                ? 'ບໍ່ມີຂ່າວໃນໝວດ "$selectedCategoryName"'
                : _searchQuery.isNotEmpty
                ? 'ບໍ່ພົບຂ່າວ'
                : 'ຍັງບໍ່ມີຂ່າວ',
            style: GoogleFonts.notoSansLao(
              fontSize: _titleFontSize,
              fontWeight: FontWeight.w800,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            isFiltered
                ? 'ລອງເລືອກໝວດອື່ນເບິ່ງ'
                : _searchQuery.isNotEmpty
                ? 'ລອງຄົ້ນຫາຄຳອື່ນ'
                : 'ຂ່າວຈະອັບເດດໃນໄວໆນີ້',
            style: GoogleFonts.notoSansLao(
              color: Colors.grey[500],
              fontSize: _bodyFontSize,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (isFiltered || _searchQuery.isNotEmpty) ...[
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF07325D).withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (isFiltered) {
                    setState(() => _selectedCategoryId = 'all');
                  } else {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _loadNews(isRefresh: true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: _basePadding * 1.5,
                    vertical: _smallPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFiltered
                          ? Icons.grid_view_rounded
                          : Icons.refresh_rounded,
                      color: Colors.white,
                      size: _iconSize,
                    ),
                    SizedBox(width: 8),
                    FittedBox(
                      child: Text(
                        isFiltered ? 'ເບິ່ງຂ່າວທັງໝົດ' : 'ລ້າງການຄົ້ນຫາ',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: _bodyFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
