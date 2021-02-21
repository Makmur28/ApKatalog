import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:katalog/screen/login/login_user.dart';
import 'package:provider/provider.dart';
import 'package:katalog/screen/navigator.dart';

class Wapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User firebaseUser = Provider.of<User>(context);
    return (firebaseUser == null) ? LoginPage() : NavigatorPage(firebaseUser);
  }
}
