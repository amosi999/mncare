import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final String? imageUrl;
  final String? link;

  const PostDetailScreen({
    Key? key,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.imageUrl,
    this.link,
  }) : super(key: key);

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
              title,
              style: textTheme.titleLarge,
            ),
            SizedBox(height: 8.0),
            Text(
              '$author | ${createdAt.toString().substring(0, 16)}',
              style: textTheme.bodySmall,
            ),
            SizedBox(height: 16.0),
            if (imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Text('이미지를 불러올 수 없습니다.')),
                ),
              ),
            SizedBox(height: 16.0),
            Text(
              content,
              style: textTheme.bodyMedium,
            ),
            if (link != null) ...[
              SizedBox(height: 16.0),
              InkWell(
                child: Text(
                  '관련 링크',
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
                onTap: () async {
                  if (await canLaunch(link!)) {
                    await launch(link!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('링크를 열 수 없습니다.')),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}