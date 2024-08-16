import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final String? imageUrl;
  final String userId; // 게시물 작성자의 userId 추가

  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.imageUrl,
    required this.userId, // userId 추가
  });

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '게시물 상세',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (currentUser != null && currentUser.uid == widget.userId)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deletePost,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              '${widget.author} | ${widget.createdAt.toString().substring(0, 16)}',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16.0),
            if (widget.imageUrl != null)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Text('이미지를 불러올 수 없습니다.')),
                ),
              ),
            const SizedBox(height: 16.0),
            Text(
              widget.content,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24.0),
            Divider(thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('댓글',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16.0),
                  _buildCommentInput(),
                  const SizedBox(height: 16.0),
                  _buildCommentList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('community')
          .doc('normal')
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('오류가 발생했습니다');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['author'] ?? '익명'),
              subtitle: Text(data['content']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data['createdAt'] != null
                      ? data['createdAt'].toDate().toString().substring(0, 16)
                      : '날짜 없음'),
                  if (data['userId'] == FirebaseAuth.instance.currentUser?.uid)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteComment(document.id),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: '댓글을 입력하세요',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 235, 91, 0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
          ),
          onPressed: _submitComment,
          child: const Text(
            '작성',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _submitComment() async {
    if (_commentController.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 작성하려면 로그인이 필요합니다.')),
      );
      return;
    }

    try {
      // 사용자 문서에서 username 가져오기
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final username = userDoc.data()?['username'] ?? '익명';

      await FirebaseFirestore.instance
          .collection('community')
          .doc('normal')
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'author': username,
        'content': _commentController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid, // 사용자 ID 저장
      });

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 작성 중 오류가 발생했습니다: $e')),
      );
    }
  }

  void _deletePost() async {
    // 삭제 확인 다이얼로그 표시
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('게시물 삭제'),
              content: const Text('이 게시물을 정말 삭제하시겠습니까? 관련된 모든 데이터가 삭제됩니다.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('삭제'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmDelete) {
      try {
        // 게시물 문서 참조
        final postRef = FirebaseFirestore.instance
            .collection('community')
            .doc('normal')
            .collection('posts')
            .doc(widget.postId);

        // 게시물 데이터 가져오기
        final postSnapshot = await postRef.get();
        final postData = postSnapshot.data();

        // 이미지 URL이 있다면 Storage에서 삭제
        if (postData != null && postData['imageUrl'] != null) {
          final imageUrl = postData['imageUrl'] as String;
          if (imageUrl.isNotEmpty) {
            // Storage 참조 생성
            final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);

            // Storage에서 이미지 삭제
            await storageRef.delete();
          }
        }

        // Firestore에서 게시물 삭제
        await postRef.delete();

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물과 관련 데이터가 삭제되었습니다.')),
        );

        // 이전 화면으로 돌아가기
        Navigator.of(context).pop();
      } catch (e) {
        // 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시물 삭제 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('community')
          .doc('normal')
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글이 삭제되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
