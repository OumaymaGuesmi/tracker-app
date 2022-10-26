import 'package:flut_tracker/pages/activity_history.dart';
import 'package:flut_tracker/pages/charts_page.dart';
import 'package:flut_tracker/pages/welcome_form.dart';
import 'package:flut_tracker/widgets/ui_cnst.dart';
import 'package:flutter/material.dart';

import 'helpers/size_helper.dart';

class HomeApp extends StatefulWidget {
  const HomeApp({Key key}) : super(key: key);

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  int _selectedIndex = 0;

  List<Widget> menuList = const [
    WelcomeForm(),
    ChartsPage(),
    ActivityHistory()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeHelper.init(context);
    return Scaffold(
      body: menuList[_selectedIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
            indicatorColor: Colors.red,
            backgroundColor: NewUICnst.paleAgua,
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (value) => _onItemTapped(value),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.info_outline), label: 'Info'),
            NavigationDestination(
              icon: Icon(Icons.bar_chart),
              label: 'Charts',
            ),
            NavigationDestination(
                icon: Icon(Icons.access_time), label: "History")
          ],
        ),
      ),
    );
  }
}
