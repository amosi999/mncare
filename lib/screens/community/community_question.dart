import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'community_postdetailscreen.dart';
import 'community_postscreen.dart';
import 'post.dart';

class CommunityQuestion extends StatefulWidget {
  const CommunityQuestion({super.key});

  @override
  _CommunityQuestionState createState() => _CommunityQuestionState();
}

class _CommunityQuestionState extends State<CommunityQuestion> {
  late Stream<QuerySnapshot> _postsStream;

  @override
  void initState() {
    super.initState();
    _postsStream = FirebaseFirestore.instance
        .collection('community')
        .doc('question')
        .collection('posts')
        .orderBy('createdDate', descending: true)
        .snapshots();
  }

  void _addNewPost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const CommunityPostScreen(initialBoard: 'question'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
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
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.white,
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                          color: Color.fromARGB(255, 108, 153, 235))
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
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          heroTag: 'addPost3',
          onPressed: _addNewPost,
          backgroundColor: const Color.fromARGB(255, 235, 91, 0),
          shape: const CircleBorder(),
          elevation: 1,
          tooltip: '새 게시물 작성',
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
