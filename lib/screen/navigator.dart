import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:katalog/screen/home/home_page.dart';
import 'package:katalog/screen/user/user_page.dart';
import 'package:katalog/screen/post/post_page.dart';

class NavigatorPage extends StatefulWidget {
  final User user;
  NavigatorPage(this.user);
  @override
  _NavigatorPageState createState() => _NavigatorPageState(user);
}

class _NavigatorPageState extends State<NavigatorPage>
    with SingleTickerProviderStateMixin {
  final User user;
  _NavigatorPageState(this.user);
  TabController controller;

  @override
  void initState() {
    controller = TabController(vsync: this, length: 3);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: TabBarView(controller: controller, children: <Widget>[
              HomePage(),
              PostPage(user: user),
              UserPage(user: user)
            ]),
            bottomNavigationBar: TabBar(
                labelColor: Colors.black,
                controller: controller,
                tabs: <Widget>[
                  Tab(icon: Icon(Icons.home, size: 30), text: "HOME"),
                  Tab(icon: Icon(Icons.add_box, size: 30), text: "POST"),
                  Tab(icon: Icon(Icons.person, size: 30), text: "USER")
                ])));
  }
}
