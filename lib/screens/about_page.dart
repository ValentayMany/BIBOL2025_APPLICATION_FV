import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';

class AboutPage extends StatefulWidget {
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _currentIndex = 3;

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/news');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/gallery');
        break;
      case 3:
        // stay
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'ກ່ຽວກັບສະຖາບັນການທະນາຄານ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [Container(margin: EdgeInsets.all(8))],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with logo and title
            Container(
              width: double.infinity,
              color: Color(0xFF07325D),
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.yellow, width: 2),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/LOGO.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Title
                  Text(
                    'ປະຫວັດຄວາມເປັນມາຂອງ\nສະຖາບັນການທະນາຄານ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/image52.png', // You'll need to add this image
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.account_balance,
                                    size: 60,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Section I - Background
                  _buildSection(
                    'I. ຄວາມເປັນມາ',
                    'ສະຖາບັນການທະນາຄານ ໄດ້ຮັບການ​ສ້າງ​ຕັ້ງຂຶ້ນ​ໃນ​ວັນ​ທີ 05 ມັງ​ກອນ ປີ1979, ເຊິ່ງຕັ້ງ​ຢູ່ບ້ານ​ຕານ​ມີ​ໄຊ, ເມືອງ​ໄຊ​ທາ​ນີ, ​ນະ​ຄອນຫລວງ​ວຽງ​ຈັນ, ຕັ້ງ​ຢູ່​ຫ່າງ​ໄກ​ຈາກ​ທະ​ນາ​ຄານ​ແຫ່ງ ສ​ປ​ປ ລາວ ປະ​ມານ 10 ກິ​ໂລ​ແມັດ, ນໍາ​ໃຊ້​ເປັນ​ສະ​ຖານ​ທີ່​​ກໍ່​ສ້າງວິ​ຊາ​ການ​ທະ​ນາ​ຄານ, ບຳ​ລຸງ​ຍົກ​ລະ​ດັບ​ວິ​ຊາ​ສະ​ເພາະໃຫ້ພະ​ນັກ​ງານ​ທະ​ນາ​ຄານ ແລະ ບໍລິການ ເປີດກວ້າງແກ່ສັງຄົມ ເຊິ່ງມີການຂະຫຍາຍຕົວຢ່າງຕໍ່ເນື່ອງດັ່ງລາຍລະອຽດ ຕໍ່ໄປນີ້:',
                  ),
                  SizedBox(height: 20),
                  // Section II - Functions and Roles
                  _buildSection(
                    'II. ຄະນະຮັບຜິດຊອບ ສທຄ ແຕ່ລະໄລຍະ',
                    'ຄະນະຮັບຜິດຊອບຂອງສະຖາບັນການທະນາຄານໄດ້ມີການ ປັບບຸງ, ຊັບຊ້ອນ, ປ່ຽນແທນ ໃຫ້ແທດເໝາະກັບສະພາບຄວາມເປັນຈິງໃນແຕ່ລະໄລຍະ, ເຊີ່ງເຫັນໄດ້ວ່ານັບຕັ້ງແຕ່ມື້ສ້າງ ຕັ້ງມາຮອດປະຈຸບັນໄດ້ມີການຊັບປ່ຽນຄະນະຮັບຜິດຊອບຂອງໂຮງຮຽນມີທັງໝົດ 12 ຄັ້ງ ລາຍລະດຽດແຕ່ລະໄລຍະມີດັ່ງລຸ່ມນີ້:',
                  ),
                  SizedBox(height: 20),
                  // Historical periodsເ
                  _buildHistoricalPeriod('ໄລ​ຍະ​ປີ 1979 –​ 1980', [
                    'ທ່ານ​ ມະ​ຫາ​ປານ​ ເຄນ​ສະ​ບັບ  ຜູ້ອຳ​ນວຍ​ການ​ໂຮງ​ຮຽນ',
                    'ທ່ານ ໄຟ​ດາ ໄພ​ເພັງ​ຢົວ         ​ຮອງ​ອຳ​ນວຍ​ການໂຮງ​ຮຽນ',
                    'ທ່ານ ບຸນ​ທີ ວິ​ມຸງ​ຄຸນ           ​ຄະ​ນະ​ອໍານວຍ​ການ',
                  ]),
                  _buildHistoricalPeriod('ໄລຍະປີ 1981 - 1985', [
                    'ທ່ານ ໄລຍາ ໂພທະລາວົງ, ປີ້ອງລະບວນການຂອງຄະຣຸ',
                    'ທ່ານ ບູນທີ ວັງປາ, ຮອງບໍລິການກວດການຂອງຄະຣຸ',
                    'ທ່ານຍິງ ລາວິໄລ ເປັນຍິງບໍລິການກວດການຂອງຄະຣຸ ( ຊື່ແລກຈາກ ສພ ແລວ​ວົງ​ແຮມ )',
                    'ທ່ານ ວັງແສງ',
                    'ທ່ານ ບາງ ສິນໄຊ',
                  ]),
                  _buildHistoricalPeriod(
                    'ໄລຍະປີ 1986 - 1987 ປີ້ອງຄານຄອນນຳວັດການບຳນາດຄະນະ(ປີ້ອງລະບວງ)',
                    ['ທ່ານ ບູນທີ ວັງປາ ເປັນຍິງບໍລິການກວດການຂອງຄະຣຸ'],
                  ),
                  _buildHistoricalPeriod('ໄລຍະປີ 1987 - 1988', [
                    'ທ່ານ ວິລໄລ ແກ້ວບົວສີ, ປີ້ອງລະບວນການຂອງຄະຣຸ',
                    'ທ່ານ ບູນທີ ວັງປາ, ຮອງບໍລິການກວດການຂອງຄະຣຸ',
                  ]),
                  _buildHistoricalPeriod('ໄລຍະປີ 1987 - 1988', [
                    'ທ່ານ ວິລໄລ ແກ້ວບົວສີ, ປີ້ອງລະບວນການຂອງຄະຣຸ',
                    'ທ່ານ ບູນທີ ວັງປາ, ຮອງບໍລິການກວດການຂອງຄະຣຸ',
                  ]),
                ],
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

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF07325D),
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildHistoricalPeriod(String period, List<String> leaders) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Color(0xFF07325D),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              period,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 8),
          ...leaders
              .map(
                (leader) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          color: Color(0xFF07325D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          leader,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}