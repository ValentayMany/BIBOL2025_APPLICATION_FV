import 'dart:ui';
import 'package:BIBOL/screens/News/all_news_details.dart';
import 'package:flutter/material.dart';
import 'package:BIBOL/services/news/news_service.dart';
import 'package:BIBOL/models/news/news_response.dart';
import 'package:BIBOL/models/topic/topic_model.dart';
import 'package:BIBOL/models/topic/joined_category_model.dart';
import '../../widgets/custom_bottom_nav.dart';

// Primary color for this screen
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

  // Theme colors - Updated to use 0xFF07325D variations
  final primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
  );

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

    // FAB animation based on scroll
    if (_scrollController.position.pixels > 100) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  Future<void> _loadInitialNews() async {
    setState(() => _isLoading = true);

    try {
      final response = await NewsService.getNews(limit: _itemsPerPage, page: 1);

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

        _animationController.forward();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
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
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, color: Colors.white, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
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
          icon: Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
          label: Text(
            'ກັບຂື້ນ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
          // Modern Header Section
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
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
                child: Column(
                  children: [
                    // Header with drawer button and notifications
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.menu_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _scaffoldKey.currentState?.openDrawer();
                                  },
                                ),
                              ),
                              Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        // TODO: Handle notifications
                                      },
                                    ),
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
                              ),
                            ],
                          ),
                          SizedBox(height: 5),

                          // Logo and title
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
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 20,
                                              offset: Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Image(
                                          image: AssetImage(
                                            'assets/images/LOGO.png',
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'ຂ່າວສານ',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      Text(
                                        'ສະຖາບັນການທະນາຄານ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.9),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 12),

                          // Enhanced search bar
                          Container(
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
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
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
                                      Future.delayed(
                                        Duration(milliseconds: 500),
                                        () {
                                          if (_searchQuery == value) {
                                            _searchNews(value);
                                          }
                                        },
                                      );
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'ຄົ້ນຫາຂ່າວທີ່ສົນໃຈ...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      prefixIcon: Container(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.search_rounded,
                                          color: Color(0xFF07325D),
                                          size: 26,
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
                                                      size: 18,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(
                                                      () => _searchQuery = '',
                                                    );
                                                    _loadNews(isRefresh: true);
                                                  },
                                                ),
                                              )
                                              : null,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Enhanced Category Filter with glassmorphism
          if (_availableCategories.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                            isSelected:
                                _selectedCategoryId == category.id.toString(),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

          // Content
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

  Widget _buildModernDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
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
              // Header
              Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
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
                        Icons.account_circle_rounded,
                        color: Color(0xFF07325D),
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'ສະບາຍດີ!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'ຍິນດີຕ້ອນຮັບ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildDrawerItem(
                        icon: Icons.home_rounded,
                        title: 'ໜ້າຫຼັກ',
                        onTap:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/home',
                            ),
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
                        onTap:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/gallery',
                            ),
                      ),
                      _buildDrawerItem(
                        icon: Icons.info_rounded,
                        title: 'ກ່ຽວກັບ',
                        onTap:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/about',
                            ),
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_rounded,
                        title: 'ໂປຣໄຟລ໌',
                        onTap:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/profile',
                            ),
                      ),
                      SizedBox(height: 20),
                      Divider(color: Colors.white.withOpacity(0.3)),
                      SizedBox(height: 20),
                      _buildDrawerItem(
                        icon: Icons.settings_rounded,
                        title: 'ຕັ້ງຄ່າ',
                        onTap: () {
                          // TODO: Settings
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.help_rounded,
                        title: 'ຊ່ວຍເຫຼືອ',
                        onTap: () {
                          // TODO: Help
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
            ],
          ),
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (isSelected) ...[
                  Spacer(),
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
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              size: 18,
              color: isSelected ? Colors.white : Color(0xFF07325D),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
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
              padding: EdgeInsets.all(30),
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
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'ກຳລັງໂຫຼດຂ່າວ...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ກະລຸນາລໍຖ້າສັກຄູ່',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
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
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Stats row
            Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              child: Row(
                children: [
                  Icon(
                    Icons.article_rounded,
                    color: Color(0xFF07325D),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'ພົບ ${displayTopics.length} ຂ່າວ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Spacer(),
                  if (_selectedCategoryId != 'all') ...[
                    Container(
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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

    return GestureDetector(
      onTap: () => _onTopicTap(topic),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Expanded(
                  flex: 3,
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
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: cardGradient,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: cardGradient,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.article_rounded,
                                          color: Colors.white,
                                          size: 40,
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
                                      size: 40,
                                    ),
                                  ),
                                ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Category tag
                      if (topic.joinedCategories.isNotEmpty)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              topic.joinedCategories.first.title,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      // Date
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDate(topic.date.toString()),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Expanded(
                          child: Text(
                            topic.displayTitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 12),
                        // Bottom section
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${topic.visits}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: cardGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'ອ່ານ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
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
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 14,
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
                        height: 10,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: 24,
                        width: 60,
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
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
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
              size: 50,
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
            style: TextStyle(
              fontSize: 22,
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
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
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
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                    ),
                    SizedBox(width: 8),
                    Text(
                      isFiltered ? 'ເບິ່ງຂ່າວທັງໝົດ' : 'ລ້າງການຄົ້ນຫາ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
