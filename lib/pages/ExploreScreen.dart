import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_app/auth/auth_service.dart';
import 'dart:developer' as developer;

import 'SourceNewsScreen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      developer.log("Người dùng chưa đăng nhập");
      return Scaffold(
        appBar: AppBar(
          title: const Text("Khám phá"),
        ),
        body: const Center(child: Text("Vui lòng đăng nhập để tiếp tục")),
      );
    }

    developer.log("UID người dùng: ${user.uid}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Khám phá"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: authService.getUserRole(user.uid),
        builder: (context, roleSnapshot) {
          if (roleSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (roleSnapshot.hasError) {
            developer.log("Lỗi lấy vai trò: ${roleSnapshot.error}");
            return Center(child: Text("Lỗi: ${roleSnapshot.error}"));
          }
          bool isAdmin = roleSnapshot.data == 'admin';
          if (!isAdmin) {
            developer.log("Người dùng không phải admin: ${roleSnapshot.data}");
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Bạn không có quyền admin để thêm kênh báo hoặc bài báo.",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                Expanded(child: _buildSourcesList()),
              ],
            );
          }
          developer.log("Người dùng là admin");
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showAddSourceDialog(context),
                      child: const Text("Thêm kênh báo"),
                    ),
                    ElevatedButton(
                      onPressed: () => _showAddNewsDialog(context),
                      child: const Text("Thêm bài báo"),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildSourcesList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSourcesList() {
    developer.log("Bắt đầu đọc dữ liệu từ collection 'source'");
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('source').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          developer.log("Lỗi đọc dữ liệu từ 'source': ${snapshot.error}");
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          developer.log("Không có dữ liệu trong 'source'");
          return const Center(child: Text("Không có kênh báo nào!"));
        }
        final sources = snapshot.data!.docs;
        developer.log("Đọc thành công: ${sources.length} kênh báo");
        return ListView.builder(
          itemCount: sources.length,
          itemBuilder: (context, index) {
            final source = sources[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: source['logoUrl'] != null
                    ? NetworkImage(source['logoUrl'])
                    : null,
                child: source['logoUrl'] == null
                    ? const Icon(Icons.newspaper)
                    : null,
              ),
              title: Text(
                source['name'] ?? 'Không có tên',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.greenAccent // Màu tiêu đề khi giao diện tối
                      : Colors.green,      // Màu tiêu đề khi giao diện sáng
                ),
              ),

              subtitle: Text(
                source['description'] ?? '',
                style: const TextStyle(
                  color: Color(0xFF4A4A4A), // Màu xám đậm, dễ đọc trên cả nền sáng và tối
                ),
              ),

              trailing: const Icon(
                Icons.star_border,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SourceNewsScreen(
                      sourceName: source['name'],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddSourceDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController urlController = TextEditingController();
    final TextEditingController logoUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thêm kênh báo"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Tên kênh báo"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Mô tả"),
                ),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: "URL"),
                ),
                TextField(
                  controller: logoUrlController,
                  decoration: const InputDecoration(labelText: "URL Logo"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String description = descriptionController.text.trim();
                String url = urlController.text.trim();
                String logoUrl = logoUrlController.text.trim();

                if (name.isNotEmpty && description.isNotEmpty && url.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance.collection('source').add({
                      'name': name,
                      'description': description,
                      'url': url,
                      'logoUrl': logoUrl.isNotEmpty ? logoUrl : null,
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Thêm kênh báo thành công!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi: $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
                  );
                }
              },
              child: const Text("Thêm"),
            ),
          ],
        );
      },
    );
  }

  void _showAddNewsDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    String? selectedSource;
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('source').get(),
          builder: (context, sourceSnapshot) {
            if (sourceSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (sourceSnapshot.hasError || !sourceSnapshot.hasData) {
              return AlertDialog(
                title: const Text("Lỗi"),
                content: Text("Không thể tải danh sách nguồn: ${sourceSnapshot.error}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Đóng"),
                  ),
                ],
              );
            }

            List<DropdownMenuItem<String>> sourceItems = sourceSnapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] as String? ?? 'Không tên';
              return DropdownMenuItem<String>(
                value: name,
                child: Text(name),
              );
            }).toList();

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('categories').get(),
              builder: (context, categorySnapshot) {
                if (categorySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (categorySnapshot.hasError || !categorySnapshot.hasData) {
                  return AlertDialog(
                    title: const Text("Lỗi"),
                    content: Text("Không thể tải danh sách danh mục: ${categorySnapshot.error}"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Đóng"),
                      ),
                    ],
                  );
                }

                List<DropdownMenuItem<String>> categoryItems = categorySnapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] as String? ?? 'Không tên';
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList();

                return AlertDialog(
                  title: const Text("Thêm bài báo"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: "Tiêu đề"),
                        ),
                        DropdownButtonFormField<String>(
                          items: categoryItems,
                          value: selectedCategory,
                          decoration: const InputDecoration(labelText: "Danh mục"),
                          onChanged: (value) {
                            selectedCategory = value;
                          },
                        ),
                        TextField(
                          controller: contentController,
                          decoration: const InputDecoration(labelText: "Nội dung"),
                          maxLines: 3,
                        ),
                        TextField(
                          controller: imageUrlController,
                          decoration: const InputDecoration(labelText: "URL Hình ảnh"),
                        ),
                        DropdownButtonFormField<String>(
                          items: sourceItems,
                          value: selectedSource,
                          decoration: const InputDecoration(labelText: "Nguồn"),
                          onChanged: (value) {
                            selectedSource = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Hủy"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String title = titleController.text.trim();
                        String content = contentController.text.trim();
                        String imageUrl = imageUrlController.text.trim();

                        if (title.isNotEmpty &&
                            content.isNotEmpty &&
                            selectedCategory != null &&
                            selectedSource != null) {
                          try {
                            await FirebaseFirestore.instance.collection('news').add({
                              'title': title,
                              'category': selectedCategory,
                              'content': content,
                              'imageUrl': imageUrl.isNotEmpty ? imageUrl : null,
                              'source': selectedSource,
                              'time': FieldValue.serverTimestamp(),
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Thêm bài báo thành công!")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Lỗi: $e")),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
                          );
                        }
                      },
                      child: const Text("Thêm"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}