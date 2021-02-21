import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final DocumentSnapshot docs;

  const DetailPage({Key key, this.docs}) : super(key: key);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: CustomScrollView(slivers: [
      SliverAppBar(
          pinned: true,
          snap: true,
          floating: true,
          expandedHeight: 350,
          flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.docs.data()['public'].toString().toUpperCase(),
              ),
              background: Image.memory(base64Decode(widget.docs.data()['img']),
                  fit: BoxFit.fill))),
      SliverFillRemaining(
          child: ListView(
              padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
              shrinkWrap: true,
              children: [
            buildCustomTitle("Nama Satwa"),
            buildCustomSubTitle("Nama Lokal",
                widget.docs.data()['general'].toString().toUpperCase()),
            buildCustomSubTitle("Nama Internasinal",
                widget.docs.data()['public'].toString().toUpperCase()),
            buildCustomTitle("Deskripsi"),
            buildCustomInfo(widget.docs.data()['character']),
            buildCustomTitle("Pola Hidup"),
            buildCustomInfo(widget.docs.data()['lifestyle']),
            buildCustomTitle("Penyebaran"),
            buildCustomInfo(widget.docs.data()['spread']),
            buildCustomTitle("Klasifikasi Jenis"),
            Center(
                child: Wrap(children: [
              buildCustomItems("Phylum", "Chordata"),
              widget.docs.data()['Kelas'] != "burung"
                  ? buildCustomItems("Kelas", widget.docs.data()['Kelas'])
                  : buildCustomItems("Kelas", 'aves'),
              buildCustomItems("Ordo", widget.docs.data()['Ordo']),
              buildCustomItems("Famili", widget.docs.data()['Famili']),
              buildCustomItems("Genus", widget.docs.data()['Genus']),
              buildCustomItems("Species", widget.docs.data()['Species'])
            ])),
            buildCustomTitle("Sumber Informasi"),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                    leading: Text("Uploader"),
                    title: Text(widget.docs.data()['nameUser']),
                    trailing: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.memory(
                            base64Decode(widget.docs.data()['imgUser']),
                            fit: BoxFit.fill)))),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                    leading: Text("Dari Sumber"),
                    title: Text(widget.docs.data()['source']),
                    trailing: Icon(Icons.book)))
          ]))
    ])));
  }

  TextButton buildCustomItems(String tag, String title) {
    return TextButton(
        child: Text("$tag : ${title.toUpperCase()}"), onPressed: () {});
  }

  ListTile buildCustomInfo(String title) {
    return ListTile(title: Text(title, textAlign: TextAlign.justify));
  }

  ListTile buildCustomSubTitle(String sub, String title) {
    return ListTile(leading: Text(sub), trailing: Text(title));
  }

  AppBar buildCustomTitle(String title) {
    return AppBar(
        leading: SizedBox(),
        title: Text(title, style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.grey[100]);
  }
}
