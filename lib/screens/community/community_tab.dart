import 'package:flutter/material.dart';
import 'community_normal.dart';
import 'community_brag.dart';
import 'community_question.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommunityTabBar(
      tabs: const [
        Tab(text: '일반'),
        Tab(text: '자랑'),
        Tab(text: '질문'),
      ],
      tabViews: [
            CommunityNormal(),
            CommunityBrag(),
            CommunityQuestion(),
      ],
    );
  }
}

class CommunityTabBar extends StatefulWidget {
  final List<Widget> tabs;
  final List<Widget> tabViews;

  const CommunityTabBar({
    Key? key,
    required this.tabs,
    required this.tabViews,
  }) : super(key: key);

  @override
  _CommunityTabBarState createState() => _CommunityTabBarState();
}

class _CommunityTabBarState extends State<CommunityTabBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: widget.tabs,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabViews,
          ),
        ),
      ],
    );
  }
}