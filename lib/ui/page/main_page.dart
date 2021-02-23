import 'package:fluintl/fluintl.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_client_flutter/res/strings.dart';
import 'main_left_page.dart';
import 'project_page.dart';
import 'system_page.dart';
import 'home_page.dart';
import 'navigation_page.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPage = 0;
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("玩Android"),
      ),
      body: Column(
        children: <Widget>[
          // https://stackoverflow.com/questions/54905388/incorrect-use-of-parent-data-widget-expanded-widgets-must-be-placed-inside-flex
          Expanded(
            child: PageView(
              children: <Widget>[
                HomePage(),
                NavigationPage(),
                SystemPage(labelId: Ids.titleSystem),
                ProjectPage(),
              ],
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: IntlUtil.getString(context, Ids.titleHome),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: IntlUtil.getString(context, Ids.titleNavigation),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree_outlined),
            label: IntlUtil.getString(context, Ids.titleSystem),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: IntlUtil.getString(context, Ids.titleProject),
          ),
        ],
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _currentPage,
        onTap: (int page) {
          _pageController.animateToPage(
            page,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        },
        type: BottomNavigationBarType.fixed,
      ),
      drawer: Drawer(
        child: MainLeftPage(),
      ),
    );
  }
}
