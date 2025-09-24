import 'package:flutter/material.dart';
import 'package:BIBOL/services/news/news_service.dart';
import 'package:BIBOL/models/news/news_response.dart';
import 'package:BIBOL/models/topic/topic_model.dart';
import 'package:BIBOL/models/topic/joined_category_model.dart';
import '../../widgets/custom_bottom_nav.dart';

class NewsListPage extends StatefulWidget {
  final String? categoryId;
  final String? categoryTitle;

  const NewsListPage({Key? key, this.categoryId, this.categoryTitle})
    : super(key: key);

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  NewsResponse? _newsResponse;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  // Category management
  List<Topic> _allTopics = [];
  List<JoinedCategory> _availableCategories = [];
  String _selectedCategoryId = 'all';
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
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
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreNews();
    }
  }

  // โหลดข่าวเริ่มต้น
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

  // อัปเดตหมวดหมู่ที่มี - ป้องกันหมวดซ้ำโดยใช้ title เป็น key
  void _updateAvailableCategories() {
    final Map<String, JoinedCategory> uniqueCategories =
        {}; // ใช้ title เป็น key

    // เก็บหมวดหมู่ที่ไม่ซ้ำตาม title
    for (final topic in _allTopics) {
      if (topic.joinedCategories.isNotEmpty) {
        for (final category in topic.joinedCategories) {
          // ใช้ title เป็น key เพื่อป้องกันหมวดที่ชื่อเดียวกัน
          uniqueCategories[category.title] = category;
        }
      }
    }

    setState(() {
      _availableCategories =
          uniqueCategories.values.toList()
            ..sort((a, b) => a.title.compareTo(b.title));
    });

    // Debug: แสดงจำนวนข่าวในแต่ละหมวด
    print('=== หมวดหมู่และจำนวนข่าว (ไม่ซ้ำตาม title) ===');
    print('ทั้งหมด: ${_allTopics.length} ข่าว');

    for (final category in _availableCategories) {
      final count = _getCategoryCountByTitle(category.title);
      print('${category.title}: $count ข่าว');
    }
    print('=============================');
  }

  // นับจำนวนข่าวในแต่ละหมวดหมู่โดยใช้ title
  int _getCategoryCountByTitle(String categoryTitle) {
    return _allTopics.where((topic) {
      return topic.joinedCategories.any((cat) => cat.title == categoryTitle);
    }).length;
  }

  // ได้รับ topics ที่ถูกกรองตามหมวดหมู่ที่เลือก - ใช้ title แทน id
  List<Topic> get _filteredTopics {
    if (_selectedCategoryId == 'all') {
      return _allTopics;
    }

    // หาหมวดหมู่ที่เลือกจาก id
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

    // กรองข่าวที่มีหมวดหมู่ตรงกัน
    return _allTopics.where((topic) {
      return topic.joinedCategories.any(
        (cat) => cat.title == selectedCategory.title,
      );
    }).toList();
  }

  // นับจำนวนข่าวในแต่ละหมวดหมู่ - แก้ปัญหาการนับซ้ำ
  int _getCategoryCount(String categoryId) {
    if (categoryId == 'all') return _allTopics.length;

    final catId = int.tryParse(categoryId);
    if (catId == null) return 0;

    // นับเฉพาะข่าวที่หมวดแรกตรงกับที่เราต้องการ
    return _allTopics.where((topic) {
      return topic.joinedCategories.isNotEmpty &&
          topic.joinedCategories.first.id == catId;
    }).length;
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
        limit: 50, // เพิ่มจำนวนข่าวที่ค้นหา
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
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      MaterialPageRoute(builder: (context) => TopicDetailPage(topic: topic)),
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
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.categoryTitle ?? 'ຂ່າວສານທັງໝົດ',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        centerTitle: true,
        shadowColor: Colors.black12,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.blue[600],
                  size: 20,
                ),
              ),
              onPressed: () => _loadNews(isRefresh: true),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNews(isRefresh: true),
        color: Colors.blue[600],
        child: Column(
          children: [
            // Search Section
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey[50]!, Colors.grey[100]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                  decoration: InputDecoration(
                    hintText: 'ຄົ້ນຫາຂ່າວ...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Container(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.blue[600],
                        size: 22,
                      ),
                    ),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.clear_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _loadNews(isRefresh: true);
                              },
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ),

            // Category Filter Section
            if (_availableCategories.isNotEmpty) _buildCategoryList(),

            // Content
            Expanded(
              child:
                  _isLoading && _allTopics.isEmpty
                      ? _buildLoadingState()
                      : _buildNewsList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[50]!, Colors.blue[100]!],
              ),
              border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'ໝວດໝູ່',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),

          // ปุ่ม "ທັງໝົດ" - ไม่มีตัวเลข
          _buildCategoryListItem(
            id: 'all',
            title: 'ທັງໝົດ',
            count: null, // ลบตัวเลขออก
            isSelected: _selectedCategoryId == 'all',
            isAllCategory: true,
          ),

          // รายการหมวดหมู่
          ..._availableCategories.map((category) {
            return _buildCategoryListItem(
              id: category.id.toString(),
              title: category.title,
              count: _getCategoryCountByTitle(category.title),
              isSelected: _selectedCategoryId == category.id.toString(),
              isAllCategory: false,
            );
          }).toList(),

          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[200]!, Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryListItem({
    required String id,
    required String title,
    int? count, // เปลี่ยนเป็น optional
    required bool isSelected,
    required bool isAllCategory,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            isSelected
                ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.blue, Colors.blue],
                )
                : null,
        color: isSelected ? null : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategoryId = id;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isSelected ? Colors.blue[600]! : Colors.transparent,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                // Icon for category
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.blue[600]
                            : isAllCategory
                            ? Colors.grey[400]
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isAllCategory ? Icons.apps_rounded : Icons.bookmark_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.blue[800] : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),

                // แสดงจำนวนเฉพาะเมื่อมีค่า count และไม่ใช่หมวด "ທັງໝົດ"
                if (count != null && !isAllCategory)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected
                              ? LinearGradient(
                                colors: [Colors.blue[600]!, Colors.blue[500]!],
                              )
                              : LinearGradient(
                                colors: [Colors.grey[300]!, Colors.grey[400]!],
                              ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isSelected ? Colors.blue : Colors.grey)
                              .withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue[600],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'ກຳລັງໂຫຼດຂ່າວ...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    final displayTopics = _filteredTopics;

    if (displayTopics.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(20),
      itemCount: displayTopics.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= displayTopics.length) {
          return _buildLoadingMoreIndicator();
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
                  (index * 0.05).clamp(0.0, 1.0),
                  ((index * 0.05) + 0.3).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: _animationController,
                child: _buildNewsCard(displayTopics[index], index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNewsCard(Topic topic, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onTopicTap(topic),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              if (topic.hasImage && topic.photoFile.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Image.network(
                          topic.photoFile,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[200]!,
                                    Colors.grey[300]!,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue[600],
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              '❌ Image error for ${topic.photoFile}: $error',
                            );
                            return Container(
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[200]!,
                                    Colors.grey[300]!,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'ບໍ່ສາມາດໂຫຼດຮູບພາບໄດ້',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
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
                      ],
                    ),
                  ),
                ),

              // Content Section
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories - แสดงเฉพาะหมวดแรก
                    if (topic.joinedCategories.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[500]!, Colors.blue[600]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_offer_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              topic.joinedCategories.first.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                    ],

                    // Title
                    Text(
                      topic.displayTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    if (topic.details.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        topic.displayDetails,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    SizedBox(height: 16),

                    // Footer
                    Row(
                      children: [
                        // Date
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatDate(topic.date.toString()),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 8),

                        // Views count
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Spacer(),

                        // Read More Arrow
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[500]!, Colors.blue[600]!],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ອ່ານຕໍ່',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.blue[600],
          ),
        ),
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

    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[100]!, Colors.grey[200]!],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isFiltered ? Icons.filter_alt_outlined : Icons.article_outlined,
                size: 50,
                color: Colors.grey[400],
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              isFiltered
                  ? 'ລອງເລືອກໝວດອື່ນເບິ່ງ'
                  : _searchQuery.isNotEmpty
                  ? 'ລອງຄົ້ນຫາຄຳອື່ນ'
                  : 'ຂ່າວຈະອັບເດດໃນໄວໆນີ້',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            if (isFiltered || _searchQuery.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[500]!, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
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
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isFiltered ? 'ເບິ່ງຂ່າວທັງໝົດ' : 'ລ້າງການຄົ້ນຫາ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TopicDetailPage extends StatefulWidget {
  final Topic topic;

  const TopicDetailPage({Key? key, required this.topic}) : super(key: key);

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'ລາຍລະອຽດຂ່າວ',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.grey[600],
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[500]!, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.share_rounded, color: Colors.white, size: 18),
              ),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Image
            if (widget.topic.hasImage && widget.topic.photoFile.isNotEmpty)
              Container(
                width: double.infinity,
                height: 280,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.topic.photoFile,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[200]!, Colors.grey[300]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.blue[600],
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[200]!, Colors.grey[300]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 12),
                              Text(
                                'ບໍ່ສາມາດໂຫຼດຮູບພາບໄດ້',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  if (widget.topic.joinedCategories.isNotEmpty) ...[
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children:
                          widget.topic.joinedCategories.map((category) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue[500]!,
                                    Colors.blue[600]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_offer_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    category.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Title
                  Text(
                    widget.topic.displayTitle,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[800],
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Metadata
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[50]!, Colors.grey[100]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: Colors.blue[600],
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          _formatDate(widget.topic.date.toString()),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.visibility_rounded,
                            size: 18,
                            color: Colors.green[600],
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '${widget.topic.visits} ຄົນເບິ່ງ',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Content
                  if (widget.topic.details.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      child: _buildHtmlContent(widget.topic.details),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[50]!, Colors.grey[100]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'ບໍ່ມີເນື້ອຫາລາຍລະອຽດ',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'ຂ່າວນີ້ອາດຈະມີແຕ່ຫົວຂໍ້ ຫຼື ເນື້ອຫາຍັງບໍ່ໄດ້ເພີ່ມ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Author info
                  if (widget.topic.user != null) ...[
                    SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[50]!, Colors.blue[100]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ເຂົ້າຮຽນໂດຍ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  widget.topic.user!.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Additional images
            if (widget.topic.details.contains('<img'))
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.photo_library_rounded,
                            color: Colors.purple[600],
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'ຮູບພາບເພີ່ມເຕີມ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildAdditionalImages(widget.topic.details),
                  ],
                ),
              ),

            SizedBox(height: 20),
          ],
        ),
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

  Widget _buildHtmlContent(String htmlContent) {
    final cleanText =
        htmlContent
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&nbsp;', ' ')
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        cleanText.isNotEmpty ? cleanText : 'ບໍ່ມີເນື້ອຫາ',
        style: TextStyle(
          fontSize: 17,
          color: Colors.grey[700],
          height: 1.7,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildAdditionalImages(String htmlContent) {
    final imgRegex = RegExp(
      r'<img[^>]+src="([^"]*)"[^>]*>',
      caseSensitive: false,
    );
    final matches = imgRegex.allMatches(htmlContent);

    if (matches.isEmpty) {
      return SizedBox.shrink();
    }

    final imageUrls = matches.map((match) => match.group(1)!).toList();

    return Column(
      children:
          imageUrls.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;

            return Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ຮູບທີ່ ${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[200]!, Colors.grey[300]!],
                              ),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.purple[600],
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[200]!, Colors.grey[300]!],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'ບໍ່ສາມາດໂຫຼດຮູບພາບໄດ້',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
