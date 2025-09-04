import 'package:auth_flutter_api/services/basic_infor.dart';
import 'package:auth_flutter_api/widgets/custom_bottom_nav.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late PageController _pageController;
  Timer? _carouselTimer;
  int _carouselIndex = 0;
  final List<String> _carouselItems = [
    'assets/images/image52.png',
    'assets/images/LOGO.png',
    'assets/images/image52.png',
    'assets/images/LOGO.png',
  ];

  @override
  //Auto carousel Images
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _carouselTimer = Timer.periodic(Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;
      final next = (_carouselIndex + 1) % _carouselItems.length;
      _pageController.animateToPage(
        next,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  //Logout
  void logout(BuildContext context) async {
    final res = await AuthService.logout();
    print(res["message"]);
    Navigator.pushReplacementNamed(context, "/login");
  }

  // Handle bottom navigation tap
  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/news');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/gallery');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/about');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // allow the white content to extend to the bottom so there's no blue strip
    final availableHeight =
        media.size.height - media.padding.top - kToolbarHeight;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF07325D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () {
            // Handle menu button press
          },
        ),

        centerTitle: true,
        title: Text(
          'ສະຖາບັນການທະນາຄານ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            child: IconButton(
              icon: Icon(
                Icons.power_settings_new,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                logout(context);
              },
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Color(0xFF07325D),
              child: Column(
                children: [
                  // Carousel
                  Container(
                    margin: EdgeInsets.all(16),
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: _carouselItems.length,
                            onPageChanged: (i) {
                              setState(() {
                                _carouselIndex = i;
                              });
                            },
                            itemBuilder: (context, i) {
                              return Image.asset(
                                _carouselItems[i],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_carouselItems.length, (
                                i,
                              ) {
                                final active = i == _carouselIndex;
                                return Container(
                                  width: active ? 10 : 8,
                                  height: active ? 10 : 8,
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        active ? Colors.white : Colors.white54,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),

            // Content Section
            Container(
              constraints: BoxConstraints(minHeight: availableHeight),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        'ຫຼັກສູດການສຶກສາ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Description Cards (full width)
                    Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: InforService.getNewsById(
                              4,
                            ), // 👈 ดึงจาก API
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                ); // กำลังโหลด
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text("Error: ${snapshot.error}"),
                                );
                              } else if (!snapshot.hasData) {
                                return Center(child: Text("No data"));
                              }

                              final news = snapshot.data!;
                              return Container(
                                height: 130,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    news["content"], // 👈 ใช้ content จาก API
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(width: 10),
                        Expanded(
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: InforService.getNewsById(
                              5,
                            ), // 👈 ดึงจาก API
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                ); // กำลังโหลด
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text("Error: ${snapshot.error}"),
                                );
                              } else if (!snapshot.hasData) {
                                return Center(child: Text("No data"));
                              }

                              final news = snapshot.data!;
                              return Container(
                                height: 130,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    news["content"], // 👈 ใช้ content จาก API
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: InforService.getNewsById(
                              6,
                            ), // 👈 ดึงจาก API
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                ); // กำลังโหลด
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text("Error: ${snapshot.error}"),
                                );
                              } else if (!snapshot.hasData) {
                                return Center(child: Text("No data"));
                              }

                              final news = snapshot.data!;
                              return Container(
                                height: 130,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    news["content"], // 👈 ใช้ content จาก API
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                      ],
                    ),

                    SizedBox(height: 20),

                    // News Section
                    Center(
                      child: Text(
                        'ຂ່າວຫຼ້າສຸດ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // News Cards -> 3-column grid like NewsPage
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFEAEAEA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/news');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF07325D),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  minimumSize: Size(64, 28),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'ອ່ານເພີ່ມເຕີມ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
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
}