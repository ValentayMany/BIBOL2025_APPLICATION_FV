// pages/news_list_page.dart - Modern Redesign
// ignore_for_file: unused_field

import 'dart:ui';
import 'package:BIBOL/screens/news/all_news_details.dart';
import 'package:BIBOL/widgets/common/custom_bottom_nav.dart';
import 'package:BIBOL/widgets/news_widget/news_category_filter_widget.dart';
import 'package:BIBOL/widgets/news_widget/news_empty_state_widget.dart';
import 'package:BIBOL/widgets/news_widget/news_list_card_widget.dart';
import 'package:BIBOL/widgets/news_widget/news_loading_card_widget.dart';
import 'package:BIBOL/widgets/news_widget/news_search_header_widget.dart';
import 'package:BIBOL/widgets/shared/modern_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:BIBOL/services/news/news_service.dart';
import 'package:BIBOL/models/news/news_response.dart';
import 'package:BIBOL/models/topic/topic_model.dart';
import 'package:BIBOL/models/topic/joined_category_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:BIBOL/services/token/token_service.dart';
import 'package:BIBOL/widgets/common/pull_to_refresh_widget.dart';

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

  // Responsive dimensions
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  double get _basePadding {
    if (_screenWidth < 320) return 8.0;
    if (_screenWidth < 360) return 12.0;
    if (_screenWidth < 400) return 16.0;
    if (_screenWidth < 480) return 18.0;
    if (_screenWidth < 600) return 20.0;
    return 24.0;
  }

  double get _bodyFontSize {
    if (_screenWidth < 320) return 11.0;
    if (_screenWidth < 360) return 12.0;
    if (_screenWidth < 400) return 13.0;
    if (_screenWidth < 480) return 14.0;
    return 15.0;
  }

  double get _iconSize {
    if (_screenWidth < 320) return 16.0;
    if (_screenWidth < 360) return 18.0;
    if (_screenWidth < 400) return 20.0;
    if (_screenWidth < 480) return 22.0;
    return 24.0;
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

  Future<void> _searchNews(String query) async {
    if (query.trim().isEmpty) {
      _loadNews(isRefresh: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await NewsService.getNews(limit: 100, page: 1);

      if (response.success) {
        final allTopics = <Topic>[];
        for (final newsModel in response.data) {
          allTopics.addAll(newsModel.topics);
        }

        final searchQuery = query.toLowerCase();
        final searchResults =
            allTopics.where((topic) {
              final titleMatch = topic.title.toLowerCase().contains(
                searchQuery,
              );
              final detailsMatch = topic.details.toLowerCase().contains(
                searchQuery,
              );
              return titleMatch || detailsMatch;
            }).toList();

        setState(() {
          _allTopics = searchResults;
          _isLoading = false;
          _hasMoreData = false;
          _selectedCategoryId = 'all';
          _updateAvailableCategories();
        });

        if (searchResults.isEmpty) {
          _showMessage('ບໍ່ພົບຂ່າວທີ່ຄົ້ນຫາ');
        }
      } else {
        setState(() => _isLoading = false);
        _showMessage('ບໍ່ສາມາດໂຫຼດຂ່າວໄດ້');
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
              padding: EdgeInsets.all(_basePadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: _iconSize,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.notoSansLao(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: _bodyFontSize,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(_basePadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);

    final routes = ['/home', '/news', '/gallery', '/about', '/profile'];
    if (index != 1) Navigator.pushReplacementNamed(context, routes[index]);
  }

  Future<void> _handleRefresh() async {
    try {
      // Reset state
      setState(() {
        _isLoading = true;
        _allTopics.clear();
        _filteredTopics.clear();
        _currentPage = 1;
      });

      // Fetch fresh data
      await _loadNews(isRefresh: true);
      
    } catch (e) {
      print('❌ Refresh error: $e');
      // Error will be shown by the pull-to-refresh widget
    }
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
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red.shade600,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'ອອກຈາກລະບົບສຳເລັດ',
                                style: GoogleFonts.notoSansLao(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.all(_basePadding),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ອອກຈາກລະບົບ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _handleLogin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFF8FAFF),
      drawer: ModernDrawerWidget(
        isLoggedIn: _isLoggedIn,
        userInfo: _userInfo,
        screenWidth: _screenWidth,
        screenHeight: _screenHeight,
        onLogoutPressed: _handleLogout,
        onLoginPressed: _handleLogin,
        currentRoute: '/news',
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimationController,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF07325D).withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
              );
            },
            backgroundColor: Color(0xFF07325D),
            icon: Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
              size: _iconSize,
            ),
            label: Text(
              'ກັບຂື້ນ',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: _bodyFontSize,
              ),
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      body: NewsPullToRefreshWidget(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: NewsSearchHeaderWidget(
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              onNotificationPressed: () {},
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() => _searchQuery = value);
                Future.delayed(Duration(milliseconds: 500), () {
                  if (_searchQuery == value) {
                    _searchNews(value);
                  }
                });
              },
              searchQuery: _searchQuery,
              hasNotification: true,
            ),
          ),
          if (_availableCategories.isNotEmpty)
            SliverToBoxAdapter(
              child: NewsCategoryFilterWidget(
                categories: _availableCategories,
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (categoryId) {
                  setState(() {
                    _selectedCategoryId = categoryId;
                  });
                },
              ),
            ),
          // Modern Stats Card
          if (!_isLoading && _allTopics.isNotEmpty)
            SliverToBoxAdapter(child: _buildModernStatsCard()),
          _isLoading && _allTopics.isEmpty
              ? SliverFillRemaining(child: _buildLoadingState())
              : _buildNewsGrid(),
        ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildModernStatsCard() {
    final displayTopics = _filteredTopics;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _basePadding,
        vertical: _basePadding * 0.5,
      ),
      padding: EdgeInsets.all(_basePadding * 0.9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(20),
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
            padding: EdgeInsets.all(_basePadding * 0.7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.newspaper_rounded,
              color: Colors.white,
              size: _iconSize * 1.2,
            ),
          ),
          SizedBox(width: _basePadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ຂ່າວທັງໝົດ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: _bodyFontSize * 0.85,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${displayTopics.length}',
                  style: GoogleFonts.notoSansLao(
                    fontSize: _bodyFontSize * 1.8,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF07325D),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedCategoryId != 'all')
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: _basePadding * 0.8,
                vertical: _basePadding * 0.4,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF07325D).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_alt_rounded,
                    color: Colors.white,
                    size: _iconSize * 0.7,
                  ),
                  SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _screenWidth * 0.2),
                    child: Text(
                      _availableCategories
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
                          .title,
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white,
                        fontSize: _bodyFontSize * 0.7,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
        ],
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
              padding: EdgeInsets.all(_basePadding * 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF07325D).withOpacity(0.3),
                    blurRadius: 25,
                    offset: Offset(0, 12),
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
              style: GoogleFonts.notoSansLao(
                color: Color(0xFF07325D),
                fontSize: _bodyFontSize * 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ກະລຸນາລໍຖ້າສັກຄູ່',
              style: GoogleFonts.notoSansLao(
                color: Colors.grey[500],
                fontSize: _bodyFontSize * 0.95,
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
      return SliverFillRemaining(
        child: NewsEmptyStateWidget(
          isFiltered: _selectedCategoryId != 'all',
          selectedCategoryName:
              _availableCategories
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
                  .title,
          searchQuery: _searchQuery,
          onClearFilter: () {
            if (_selectedCategoryId != 'all') {
              setState(() => _selectedCategoryId = 'all');
            } else {
              _searchController.clear();
              setState(() => _searchQuery = '');
              _loadNews(isRefresh: true);
            }
          },
          onRefresh: () {
            _searchController.clear();
            setState(() => _searchQuery = '');
            _loadNews(isRefresh: true);
          },
        ),
      );
    }

    int itemCount = displayTopics.length;
    if (_isLoadingMore) itemCount += 4;

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          _basePadding,
          _basePadding * 0.5,
          _basePadding,
          _basePadding,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount;
            double childAspectRatio;

            // Grid calculations
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 4;
              childAspectRatio = 0.85;
            } else if (constraints.maxWidth > 900) {
              crossAxisCount = 3;
              childAspectRatio = 0.8;
            } else if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
              childAspectRatio = 0.75;
            } else if (constraints.maxWidth > 480) {
              crossAxisCount = 2;
              childAspectRatio = 0.9;
            } else if (constraints.maxWidth > 400) {
              crossAxisCount = 2;
              childAspectRatio = 0.85;
            } else if (constraints.maxWidth > 360) {
              crossAxisCount = 2;
              childAspectRatio = 0.8;
            } else if (constraints.maxWidth > 320) {
              crossAxisCount = 1;
              childAspectRatio = 1.4;
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
                crossAxisSpacing: _basePadding * 0.8,
                mainAxisSpacing: _basePadding,
              ),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index >= displayTopics.length) {
                  return NewsLoadingCardWidget();
                }

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 30)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: NewsListCardWidget(
                          topic: displayTopics[index],
                          index: index,
                          onTap: () => _onTopicTap(displayTopics[index]),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
