import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_postscreen.dart';
import 'community_postdetailscreen.dart';
import 'post.dart';

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
      builder: (context) => CommunityPostScreen(initialBoard: 'normal'),
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
            return const Center(child: Text('오류가 발생했습니다'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Post> posts = snapshot.data!.docs
              .map((doc) => Post.fromFirestore(doc))
              .toList();

          return ListView.builder(
            // Changed from ListView.separated to ListView.builder
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(
                    vertical: 4, horizontal: 8), // Adjusted margin
                child: ListTile(
                  title: Text(
                    posts[index].title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${posts[index].author} | ${posts[index].createdAt.toString().substring(0, 16)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  leading: posts[index].imageUrl != null
                      ? const Icon(Icons.image,
                          color: Color.fromARGB(255, 108, 153, 235)) // 아이콘으로 변경
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
                          userId: posts[index].userId,
                        ),
                      ),
                    );
                  },
                ),
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
        backgroundColor: const Color.fromARGB(255, 235, 91, 0),
      ),
    );
  }
}
