import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Future<void> openUrl(String url,
      {bool forceWebView = false, bool enableJavaScript = false}) async {
    if (await canLaunch(url)) {
      await launch(url,
          forceWebView: forceWebView, enableJavaScript: enableJavaScript);
    }
  }

  Future<void> sendEmail(String email) async {
    await launch("mailto:$email");
  }

  void aboutMe() {
    AlertDialog me = AlertDialog(
        content: ListView(shrinkWrap: true, children: [
      ListTile(title: Text("Pengembang")),
      ListTile(leading: Text("Nama : "), title: Text("Muhammad Adam Makmur")),
      ListTile(
          leading: Text("Email : "),
          title: Text("Silahkan di tap"),
          onTap: () async {
            await sendEmail('makmur1.setiad@gmail.com');
          })
    ]));
    showDialog(context: context, builder: (context) => me);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(title: Text("Hal - hal lain"), centerTitle: true),
            body: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                    title: Text("Tentang TNGGP"),
                    onTap: () async {
                      await openUrl("https://www.gedepangrango.org",
                          forceWebView: true, enableJavaScript: false);
                    }),
                ListTile(
                    title: Text("Tentang Pengembang"),
                    onTap: () {
                      aboutMe();
                    })
              ],
            )));
  }
}
