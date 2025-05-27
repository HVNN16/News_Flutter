import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'VideoPlayerScreen.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  Future<String?> _generateThumbnail(String videoUrl) async {
    try {
      if (videoUrl.isEmpty) {
        return null;
      }
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        imageFormat: ImageFormat.PNG,
        maxHeight: 100,
        quality: 75,
      );
      return thumbnailPath;
    } catch (e) {
      print("Error creating thumbnail: $e");
      return null;
    }
  }

  void _showAddVideoDialog(List<String> sourceOptions) {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final videoUrlController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedSource = sourceOptions.isNotEmpty ? sourceOptions[0] : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm video mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            DropdownButtonFormField<String>(
              value: selectedSource,
              hint: const Text("Chọn nguồn"),
              items: sourceOptions.map((source) {
                return DropdownMenuItem<String>(
                  value: source,
                  child: Text(source),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSource = value;
                });
              },
              decoration: const InputDecoration(labelText: "Nguồn"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Mô tả"),
              maxLines: 3,
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: "Thời gian"),
            ),
            TextField(
              controller: videoUrlController,
              decoration: const InputDecoration(labelText: "URL video"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final source = selectedSource ?? '';
              final description = descriptionController.text.trim();
              final time = timeController.text.trim();
              final videoUrl = videoUrlController.text.trim();
              if (title.isNotEmpty && videoUrl.isNotEmpty) {
                await FirebaseFirestore.instance.collection('media').add({
                  'title': title,
                  'source': source,
                  'description': description,
                  'time': time,
                  'videoUrl': videoUrl,
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  void _showEditVideoDialog(DocumentSnapshot doc, List<String> sourceOptions) {
    final media = doc.data() as Map<String, dynamic>;
    final titleController = TextEditingController(text: media['title'] ?? '');
    final timeController = TextEditingController(text: media['time'] ?? '');
    final videoUrlController = TextEditingController(text: media['videoUrl'] ?? '');
    final descriptionController = TextEditingController(text: media['description'] ?? '');
    String? selectedSource = media['source']?.toString() ?? (sourceOptions.isNotEmpty ? sourceOptions[0] : null);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sửa video"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            DropdownButtonFormField<String>(
              value: selectedSource,
              hint: const Text("Chọn nguồn"),
              items: sourceOptions.map((source) {
                return DropdownMenuItem<String>(
                  value: source,
                  child: Text(source),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSource = value;
                });
              },
              decoration: const InputDecoration(labelText: "Nguồn"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Mô tả"),
              maxLines: 3,
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: "Thời gian"),
            ),
            TextField(
              controller: videoUrlController,
              decoration: const InputDecoration(labelText: "URL video"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final source = selectedSource ?? '';
              final description = descriptionController.text.trim();
              final time = timeController.text.trim();
              final videoUrl = videoUrlController.text.trim();
              if (title.isNotEmpty && videoUrl.isNotEmpty) {
                await doc.reference.update({
                  'title': title,
                  'source': source,
                  'description': description,
                  'time': time,
                  'videoUrl': videoUrl,
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _deleteVideo(DocumentSnapshot doc) async {
    await doc.reference.delete();
  }

  Future<List<String>> _fetchSourceOptions() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('source').get();
      return querySnapshot.docs.map((doc) => doc['name']?.toString() ?? '').where((name) => name.isNotEmpty).toList();
    } catch (e) {
      print("Error fetching sources: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool isAdmin = false;

    if (user != null) {
      return FutureBuilder<List<String>>(
        future: _fetchSourceOptions(),
        builder: (context, sourceSnapshot) {
          if (sourceSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final sourceOptions = sourceSnapshot.data ?? [];

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                isAdmin = userData?['role'] == 'admin';
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('media').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final mediaDocs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 80.0),
                    itemCount: mediaDocs.length + (isAdmin ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isAdmin && index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () => _showAddVideoDialog(sourceOptions),
                            child: const Text("Thêm video"),
                          ),
                        );
                      }

                      final docIndex = isAdmin ? index - 1 : index;
                      final media = mediaDocs[docIndex].data() as Map<String, dynamic>;
                      media['id'] = mediaDocs[docIndex].id;
                      final videoUrl = media['videoUrl']?.toString() ?? '';
                      final title = media['title'] ?? 'No title';
                      final source = media['source'] ?? '';
                      final description = media['description'] ?? '';
                      final time = media['time'] ?? 'Just now';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                videoUrl: videoUrl,
                                title: title,
                                source: source,
                                time: time,
                                description: description,
                              ),
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
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "$source • $time",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: FutureBuilder<String?>(
                                  future: _generateThumbnail(videoUrl),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        width: 100,
                                        height: 70,
                                        color: Colors.grey[300],
                                        child: const Center(child: CircularProgressIndicator()),
                                      );
                                    }
                                    if (snapshot.hasError || snapshot.data == null) {
                                      return Container(
                                        width: 100,
                                        height: 70,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.videocam),
                                      );
                                    }
                                    return Image.file(
                                      File(snapshot.data!),
                                      width: 100,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 70,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.videocam),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              if (isAdmin)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showEditVideoDialog(mediaDocs[docIndex], sourceOptions),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteVideo(mediaDocs[docIndex]);
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    } else {
      return const Center(child: Text("Vui lòng đăng nhập để tiếp tục."));
    }
  }
}