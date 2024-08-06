import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final String? imageUrl;
  final String? link;

  const PostDetailScreen({
    Key? key,
    required this.postId,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.imageUrl,
    this.link,
  }) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 상세'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: textTheme.titleLarge,
            ),
            SizedBox(height: 8.0),
            Text(
              '${widget.author} | ${widget.createdAt.toString().substring(0, 16)}',
              style: textTheme.bodySmall,
            ),
            SizedBox(height: 16.0),
            if (widget.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Text('이미지를 불러올 수 없습니다.')),
                ),
              ),
            SizedBox(height: 16.0),
            Text(
              widget.content,
              style: textTheme.bodyMedium,
            ),
            if (widget.link != null) ...[
              SizedBox(height: 16.0),
              InkWell(
                child: Text(
                  '관련 링크',
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
                onTap: () async {
                  if (await canLaunch(widget.link!)) {
                    await launch(widget.link!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('링크를 열 수 없습니다.')),
                    );
                  }
                },
              ),
            ],
            SizedBox(height: 24.0),
            Text('댓글', style: textTheme.titleMedium),
            SizedBox(height: 8.0),
            _buildCommentList(),
            SizedBox(height: 16.0),
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('community')
          .doc('normal')
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('오류가 발생했습니다');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['author'] ?? '익명'),
              subtitle: Text(data['content']),
              trailing: Text(data['createdAt'] != null
                  ? data['createdAt'].toDate().toString().substring(0, 16)
                  : '날짜 없음'),
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
            decoration: InputDecoration(
              hintText: '댓글을 입력하세요',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8.0),
        ElevatedButton(
          onPressed: _submitComment,
          child: Text('작성'),
        ),
      ],
    );
  }

  void _submitComment() async {
    if (_commentController.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글을 작성하려면 로그인이 필요합니다.')),
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
        'author': username, // 여기서 username 사용
        'content': _commentController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid, // 사용자 ID도 저장
      });

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 작성 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
