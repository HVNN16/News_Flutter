import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_app/auth/auth_service.dart';
import 'package:news_app/pages/MediaScreen.dart';
import 'package:news_app/pages/SettingsScreen.dart';
import 'package:news_app/widgets/button.dart';
import 'package:news_app/widgets/textfield.dart';
import 'package:provider/provider.dart';
import 'BottomNavBar.dart';
import 'ExploreScreen.dart';
import 'NewsDetailScreen.dart';
import 'theme_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  int _currentIndex = 0;
  String _selectedLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  void _loadLanguagePreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _selectedLanguage = data?['language'] ?? 'vi';
        });
        final locale = _selectedLanguage == 'vi' ? const Locale('vi', 'VN') : const Locale('en', 'US');
        Intl.defaultLocale = locale.toString();
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    final categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          _selectedLanguage == 'vi' ? "Thêm danh mục mới" : "Add New Category",
          style: const TextStyle(color: Colors.redAccent),
        ),
        content: CustomTextField(
          hint: _selectedLanguage == 'vi' ? "Tên danh mục" : "Category Name",
          label: _selectedLanguage == 'vi' ? "Danh mục" : "Category",
          controller: categoryController,
          prefixIcon: const Icon(Icons.category, color: Colors.redAccent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _selectedLanguage == 'vi' ? "Hủy" : "Cancel",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          CustomButton(
            label: _selectedLanguage == 'vi' ? "Thêm" : "Add",
            onPressed: () async {
              final name = categoryController.text.trim();
              if (name.isNotEmpty) {
                await FirebaseFirestore.instance.collection('categories').add({'name': name});
              }
              Navigator.pop(context);
            },
            color: Colors.redAccent,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final auth = AuthService();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          _selectedLanguage == 'vi' ? "Vui lòng đăng nhập để tiếp tục." : "Please log in to continue.",
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    final List<Widget> screens = [
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                _selectedLanguage == 'vi' ? "Lỗi: ${snapshot.error.toString()}" : "Error: ${snapshot.error.toString()}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }
          final categories = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['name'] ?? (_selectedLanguage == 'vi' ? 'Danh mục không tên' : 'Unnamed Category');
          }).toList();
          if (categories.isEmpty) {
            return Center(
              child: Text(
                _selectedLanguage == 'vi' ? "Không có danh mục nào." : "No categories available.",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          if (_tabController == null || _tabController!.length != categories.length) {
            _tabController?.dispose();
            _tabController = TabController(length: categories.length, vsync: this);
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.hasError) {
                return Center(
                  child: Text(
                    _selectedLanguage == 'vi'
                        ? "Lỗi tải thông tin người dùng: ${userSnapshot.error}"
                        : "Error loading user info: ${userSnapshot.error}",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }
              bool isAdmin = false;
              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                isAdmin = userData?['role'] == 'admin';
              }

              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    _selectedLanguage == 'vi' ? "MyNews" : "MyNews",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  automaticallyImplyLeading: false,
                  actions: [
                    if (isAdmin)
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.redAccent),
                        onPressed: _showAddCategoryDialog,
                      ),
                    // IconButton(
                    //   icon: const Icon(Icons.logout, color: Colors.redAccent),
                    //   onPressed: () async {
                    //     await auth.signOut(context);
                    //   },
                    // ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: categories.map((category) => Tab(text: category)).toList(),
                    labelColor: Colors.redAccent,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.redAccent,
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: categories.map((category) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('news')
                          .where('category', isEqualTo: category)
                          .snapshots(),
                      builder: (context, newsSnapshot) {
                        if (newsSnapshot.hasError) {
                          return Center(
                            child: Text(
                              _selectedLanguage == 'vi'
                                  ? "Lỗi: ${newsSnapshot.error}"
                                  : "Error: ${newsSnapshot.error}",
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          );
                        }
                        if (!newsSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                        }
                        final newsDocs = newsSnapshot.data!.docs;
                        return ListView.builder(
                          itemCount: newsDocs.length,
                          itemBuilder: (context, index) {
                            final news = newsDocs[index].data() as Map<String, dynamic>;
                            news['id'] = newsDocs[index].id;
                            final imageUrl = news['imageUrl']?.toString() ?? '';
                            if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
                              print("URL không hợp lệ: $imageUrl, sử dụng ảnh mặc định");
                            }
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsDetailScreen(news: news),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            news['title'] ?? (_selectedLanguage == 'vi' ? 'Không có tiêu đề' : 'No Title'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${news['source']} • ${news['time'] ?? (_selectedLanguage == 'vi' ? 'Vừa xong' : 'Just Now')}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))
                                            ? imageUrl
                                            : 'https://via.placeholder.com/100',
                                        width: 100,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 100,
                                            height: 70,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      const MediaScreen(),
      const ExploreScreen(),
      const SettingsScreen(),
    ];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}