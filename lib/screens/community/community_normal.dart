import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_postscreen.dart';
import 'community_postdetailscreen.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final String? imageUrl;
  final String? link;
  final String userId; // userId 추가

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.imageUrl,
    this.link,
    required this.userId, // userId 추가
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
      link: data['link'],
      userId: data['authorId'] ?? '', // authorId를 userId로 사용
    );
  }
}

class CommunityNormal extends StatefulWidget {
  @override
  _CommunityNormalState createState() => _CommunityNormalState();
}

class _CommunityNormalState extends State<CommunityNormal> {
  late Stream<QuerySnapshot> _postsStream;

  @override
  void initState() {
    super.initState();
    _postsStream = FirebaseFirestore.instance
        .collection('community')
        .doc('normal')
        .collection('posts')
        .orderBy('createdDate', descending: true)
        .snapshots();
  }

  void _addNewPost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommunityPostScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _postsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<Post> posts = snapshot.data!.docs
              .map((doc) => Post.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(posts[index].title),
                subtitle: Text(
                    '${posts[index].author} | ${posts[index].createdAt.toString().substring(0, 16)}'),
                leading: posts[index].imageUrl != null
                    ? Image.network(posts[index].imageUrl!,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(
                        postId: posts[index].id,
                        title: posts[index].title,
                        content: posts[index].content,
                        author: posts[index].author,
                        createdAt: posts[index].createdAt,
                        imageUrl: posts[index].imageUrl,
                        link: posts[index].link,
                        userId: posts[index].userId, // userId 추가
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addPost',
        onPressed: _addNewPost,
        child: Icon(Icons.add),
        tooltip: '새 게시물 작성',
      ),
    );
  }
}
