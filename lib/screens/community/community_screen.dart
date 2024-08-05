import 'package:flutter/material.dart';
import 'community_normal.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: '일반'),
              Tab(text: '자랑'),
              Tab(text: '질문'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                CommunityNormal(),
                Center(child: Text('자랑 게시판')),
                Center(child: Text('질문 게시판')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}