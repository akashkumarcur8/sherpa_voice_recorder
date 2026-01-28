import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/storage/sharedPrefHelper.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String activeTab = 'badge';
  String username="";
  String email="";
  String emp_name ="";
  String storeName="";
  String designation="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var fetchedUsername = await SharedPrefHelper.getpref("username");
    var fetchEmail = await SharedPrefHelper.getpref("email");
    var fetchempname = await SharedPrefHelper.getpref("emp_name");
    var fetchstorename = await SharedPrefHelper.getpref("store_name");
    var fetchdesignation = await SharedPrefHelper.getpref("designation");




    setState(() {
     username = fetchedUsername;
      email = fetchEmail;
      emp_name = fetchempname;
      storeName = fetchstorename;
      designation = fetchdesignation;

    });
  }



  void handleTabClick(String tab) {
    if (tab == 'leaderboard') {
      Get.toNamed(Routes.leaderboard);
    } else {
      setState(() {
        activeTab = tab;
      });
    }
  }

  Widget renderBadgeView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildBadgeItem(Icons.access_time, const Color(0xFF5EDEC3), const Color(0xFFC9F2E9)),
          _buildBadgeItem(Icons.bar_chart, const Color(0xFFFFC93D), const Color(0xFFFFF9C2)),
          _buildBadgeItem(Icons.public, const Color(0xFF6BB8FF), const Color(0xFFD6F0FF)),
          _buildBadgeItem(Icons.emoji_events, const Color(0xFFFF6B84), const Color(0xFFFFD6DD)),
          _buildBadgeItem(Icons.extension, const Color(0xFF6A5AE0), const Color(0xFFC4D0FB)),
          _buildBadgeItem(Icons.lock, const Color(0xFF7B7676), const Color(0xFFEBEBEB)),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 32,
      ),
    );
  }

  Widget renderStatisticsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          // Congratulations Message
          const Column(
            children: [
              Text(
                "You've handled a total of",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9D9D9D),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "24 calls this month!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Circular Progress
          const SizedBox(
            width: 128,
            height: 128,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 128,
                  height: 128,
                  child: CircularProgressIndicator(
                    value: 27 / 30,
                    strokeWidth: 8,
                    backgroundColor: Color(0xFFEBEBEB),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF565ADD)),
                  ),
                ),
                Text(
                  "27",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFEBEBEB)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.phone, color: Color(0xFF5EDEC3), size: 24),
                        SizedBox(height: 8),
                        Text(
                          "6",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Successful calls",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9D9D9D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF565ADD), Color(0xFF6A5AE0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.phone_disabled, color: Colors.white, size: 24),
                            SizedBox(height: 8),
                            Text(
                              "21",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Unsuccessful calls",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B84),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              "8",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // make the AppBar itself transparent so your gradient shows through
        backgroundColor: Colors.transparent,
        elevation: 0,

        // your other AppBar settings
        iconTheme: const IconThemeData(color: Colors.white),

        // here’s the magic:
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF565ADD),
                Color(0xFF6A5AE0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),


      body: Column(
        children: [

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with background
                  Container(
                    height: 192,
                    decoration: const BoxDecoration(
                      // color: Color(0xFF565ADD),
                      gradient: LinearGradient(
                        colors: [Color(0xFF565ADD), Color(0xFF6A5AE0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    // child: Stack(
                    //   children: [
                    //     Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.black.withOpacity(0.2),
                    //       ),
                    //     ),
                    //     Positioned(
                    //       top: 0,
                    //       right: 16,
                    //       child: IconButton(
                    //         icon: Icon(Icons.camera_alt, color: Colors.white),
                    //         onPressed: () {},
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),

                  // Profile Avatar
                  Transform.translate(
                    offset: const Offset(0, -48),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFDFDF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF7B7676),
                        size: 40,
                      ),
                    ),
                  ),

                  // User Info
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Column(
                      children: [
                        Text(
                          emp_name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF565ADD),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              storeName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF565ADD),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Stats Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF565ADD), Color(0xFF6A5AE0)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Icon(Icons.star, color: Colors.white, size: 24),
                                  SizedBox(height: 4),
                                  Text(
                                    "POINTS",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    "256",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Icon(Icons.public, color: Colors.white, size: 24),
                                  SizedBox(height: 4),
                                  Text(
                                    "TOTAL RANK",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    "#143",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Icon(Icons.bar_chart, color: Colors.white, size: 24),
                                  SizedBox(height: 4),
                                  Text(
                                    "STOREWISE RANK",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    "#5",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Navigation Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTab("Badge", "badge"),
                      const SizedBox(width: 32),
                      // _buildTab("Statistics", "statistics"),
                      // SizedBox(width: 32),
                      _buildTab("Leaderboard", "leaderboard"),
                    ],
                  ),

                  // Tab Content
                  if (activeTab == 'badge') renderBadgeView(),
                  if (activeTab == 'statistics') renderStatisticsView(),

                  // User Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28,vertical: 32),
                    child: Align(
                      alignment: Alignment.centerLeft, // Explicitly aligning to the left
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Keep this for the left alignment of the text
                        children: [
                          _buildUserDetail("Name", emp_name),
                          const SizedBox(height: 8,),

                          const Divider(
                            color: Color(0XFFEBEBEB), // Line color
                            thickness: 0.2, // Thin line
                            indent: 0, // Left indentation
                            endIndent: 0, // Right indentation
                          ),
                          const SizedBox(height: 16),
                          _buildUserDetail("Email", email),
                          const SizedBox(height: 8,),

                          const Divider(
                            color: Color(0XFFEBEBEB), // Line color
                            thickness: 0.2, // Thin line
                            indent: 0, // Left indentation
                            endIndent: 0, // Right indentation
                          ),
                          const SizedBox(height: 16),
                          _buildUserDetail("Company Name", storeName),
                          const SizedBox(height: 8,),

                          const Divider(
                            color: Color(0XFFEBEBEB), // Line color
                            thickness: 0.2, // Thin line
                            indent: 0, // Left indentation
                            endIndent: 0, // Right indentation
                          ),
                          const SizedBox(height: 16),
                          _buildUserDetail("Position", designation),
                          const SizedBox(height: 8,),
                          const Divider(
                            color: Color(0XFFEBEBEB), // Line color
                            thickness: 0.2, // Thin line
                            indent: 0, // Left indentation
                            endIndent: 0, // Right indentation
                          ),
                        ],
                      ),
                    ),
                  ),


                  // Sign Out Button

                   Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: SizedBox(
                        
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async{
                            await SharedPrefHelper.setIsloginValue(false);
                            Get.offAll(Routes.login);                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFEBEBEB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),


                            ),
                            backgroundColor: const Color(0XFFF6F6F6)

                          ),
                          child: const Text(
                            "Sign Out",
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w600,
                              fontSize: 18
                            ),
                          ),
                        ),
                      ),
                    ),


                  const SizedBox(height: 80), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: Container(
      //   height: 80,
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     border: Border(top: BorderSide(color: Color(0xFFEBEBEB))),
      //   ),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       _buildBottomNavItem(Icons.home, "Home", false),
      //       _buildBottomNavItem(Icons.trending_up, "Analytics", false),
      //       Container(
      //         width: 56,
      //         height: 56,
      //         decoration: BoxDecoration(
      //           gradient: LinearGradient(
      //             colors: [Color(0xFF565ADD), Color(0xFF6A5AE0)],
      //             begin: Alignment.centerLeft,
      //             end: Alignment.centerRight,
      //           ),
      //           shape: BoxShape.circle,
      //         ),
      //         child: Icon(Icons.mic, color: Colors.white, size: 24),
      //       ),
      //       _buildBottomNavItem(Icons.history, "History", false),
      //       _buildBottomNavItem(Icons.person, "Profile", true),
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildTab(String title, String tabKey) {
    bool isActive = activeTab == tabKey;
    return GestureDetector(
      onTap: () => handleTabClick(tabKey),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF565ADD) : const Color(0xFF9D9D9D),
            ),
          ),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 20,
              height: 2,
              color: const Color(0xFF565ADD),
            ),
        ],
      ),
    );
  }

  Widget _buildUserDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF565ADD),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

}
