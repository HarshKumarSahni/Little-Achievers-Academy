import 'package:flutter/material.dart';
import 'design_course_app_theme.dart';
import 'bottom_bar_view.dart';
import 'home_content.dart';
import 'notes.dart';
import 'graph.dart';
import 'settings.dart';
import 'ai_quiz_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _bottomNavIndex = 0;
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignCourseAppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            // Main Content Area
            _getBody(),
            
            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomBarView(
                tabIconsList: tabIconsList,
                changeIndex: (int index) {
                  setState(() {
                    _bottomNavIndex = index;
                  });
                },
                addClick: () {
                  _handleAddButtonClick();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBody() {
    switch (_bottomNavIndex) {
      case 0:
        return const HomeContent();
      case 1:
        return const Notes();
      case 2:
        return const Graph();
      case 3:
        return const Settings();
      default:
        return const HomeContent();
    }
  }

  void _handleAddButtonClick() {
    // Navigate to AI Quiz page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIQuizPage()),
    );
  }
}