// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'NewsDetailScreen.dart';
//
// class SourceNewsScreen extends StatelessWidget {
//   final String sourceName;
//
//   const SourceNewsScreen({super.key, required this.sourceName});
//
//   void _showEditDialog(BuildContext context, String docId, Map<String, dynamic> news) {
//     final titleController = TextEditingController(text: news['title']);
//     final imageUrlController = TextEditingController(text: news['imageUrl']);
//     final contentController = TextEditingController(text: news['content']);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Chỉnh sửa bài báo"),
//           content: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tiêu đề")),
//                 TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: "Ảnh URL")),
//                 TextField(controller: contentController, decoration: const InputDecoration(labelText: "Nội dung")),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
//             ElevatedButton(
//               onPressed: () async {
//                 await FirebaseFirestore.instance.collection('news').doc(docId).update({
//                   'title': titleController.text,
//                   'imageUrl': imageUrlController.text,
//                   'content': contentController.text,
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text("Lưu"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _confirmDelete(BuildContext context, String docId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Xác nhận xóa"),
//         content: const Text("Bạn có chắc muốn xóa bài viết này không?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
//           ElevatedButton(
//             onPressed: () async {
//               await FirebaseFirestore.instance.collection('news').doc(docId).delete();
//               Navigator.pop(context);
//             },
//             child: const Text("Xóa"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(sourceName),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('news')
//             .where('source', isEqualTo: sourceName)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return const Center(child: Text("Đã có lỗi xảy ra!"));
//           }
//           final newsDocs = snapshot.data!.docs;
//           return ListView.builder(
//             itemCount: newsDocs.length,
//             itemBuilder: (context, index) {
//               final news = newsDocs[index].data() as Map<String, dynamic>;
//               final docId = newsDocs[index].id;
//
//               return InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => NewsDetailScreen(news: news),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               news['title'] ?? 'Không có tiêu đề',
//                               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               "${news['source']} • ${news['time'] ?? 'Vừa xong'}",
//                               style: const TextStyle(fontSize: 12, color: Colors.grey),
//                             ),
//                             Row(
//                               children: [
//                                 TextButton(
//                                   onPressed: () => _showEditDialog(context, docId, news),
//                                   child: const Text("Sửa", style: TextStyle(color: Colors.blue)),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => _confirmDelete(context, docId),
//                                   child: const Text("Xóa", style: TextStyle(color: Colors.red)),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8.0),
//                         child: Image.network(
//                           news['imageUrl'] ?? 'https://via.placeholder.com/100',
//                           width: 100,
//                           height: 70,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               width: 100,
//                               height: 70,
//                               color: Colors.grey[300],
//                               child: const Icon(Icons.broken_image),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'NewsDetailScreen.dart';

class SourceNewsScreen extends StatelessWidget {
  final String sourceName;
  final String? userRole; // Thêm quyền người dùng

  const SourceNewsScreen({
    super.key,
    required this.sourceName,
    required this.userRole,
  });

  bool get isAdmin => userRole == 'admin';

  void _showEditDialog(BuildContext context, String docId, Map<String, dynamic> news) {
    final titleController = TextEditingController(text: news['title']);
    final imageUrlController = TextEditingController(text: news['imageUrl']);
    final contentController = TextEditingController(text: news['content']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chỉnh sửa bài báo"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tiêu đề")),
                TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: "Ảnh URL")),
                TextField(controller: contentController, decoration: const InputDecoration(labelText: "Nội dung")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('news').doc(docId).update({
                  'title': titleController.text,
                  'imageUrl': imageUrlController.text,
                  'content': contentController.text,
                });
                Navigator.pop(context);
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa bài viết này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('news').doc(docId).delete();
              Navigator.pop(context);
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sourceName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('news')
            .where('source', isEqualTo: sourceName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Đã có lỗi xảy ra!"));
          }
          final newsDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: newsDocs.length,
            itemBuilder: (context, index) {
              final news = newsDocs[index].data() as Map<String, dynamic>;
              final docId = newsDocs[index].id;

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
                              news['title'] ?? 'Không có tiêu đề',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${news['source']} • ${news['time'] ?? 'Vừa xong'}",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            if (isAdmin)
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => _showEditDialog(context, docId, news),
                                    child: const Text("Sửa", style: TextStyle(color: Colors.blue)),
                                  ),
                                  TextButton(
                                    onPressed: () => _confirmDelete(context, docId),
                                    child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          news['imageUrl'] ?? 'https://via.placeholder.com/100',
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
      ),
    );
  }
}
