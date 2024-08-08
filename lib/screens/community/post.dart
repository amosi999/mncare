import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final String? imageUrl;
  final String userId;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.imageUrl,
    required this.userId,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? '익명',
      createdAt: (data['createdDate'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      userId: data['authorId'] ?? '',
    );
  }
}