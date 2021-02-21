import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:katalog/screen/data/data_detail.dart';
import 'package:katalog/screen/home/search_page.dart';
import 'package:katalog/services/database/dbhelper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String search;

  void initiateSearch(String val) {
    setState(() {
      search = val.toLowerCase().trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                leading: Icon(Icons.bento_sharp),
                title: Text("KATALOG SATWA"),
                centerTitle: true,
                actions: [
                  IconButton(
                      icon: Icon(Icons.search, size: 30),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => SearchText()));
                      })
                ]),
            body: StreamBuilder<QuerySnapshot>(
                stream: DatabaseCustom.getData("Satwa")
                    .orderBy("general")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return LinearProgressIndicator();
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: Column(children: [
                          ListTile(
                              leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(
                                      base64Decode(snapshot.data.docs[index]
                                          .data()['imgUser']),
                                      cacheWidth: 35,
                                      cacheHeight: 35,
                                      fit: BoxFit.cover)),
                              title: Text(snapshot.data.docs[index]
                                  .data()['nameUser'])),
                          ListTile(
                              title: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(
                                    base64Decode(snapshot.data.docs[index]
                                        .data()['img']),
                                    cacheWidth:
                                        (MediaQuery.of(context).size.width *
                                                0.9)
                                            .toInt(),
                                    cacheHeight:
                                        (MediaQuery.of(context).size.width *
                                                0.7)
                                            .toInt(),
                                    fit: BoxFit.cover,
                                  )),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => DetailPage(
                                            docs: snapshot.data.docs[index])));
                              }),
                          ListTile(
                              title: Text(
                                  snapshot.data.docs[index]
                                      .data()['general']
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(color: Colors.black)),
                              subtitle: Text(
                                  snapshot.data.docs[index]
                                      .data()['public']
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(color: Colors.black)),
                              trailing: SizedBox(
                                  height: 30,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: Text(snapshot.data.docs[index]
                                          .data()['IUCN']))))
                        ]));
                      });
                })));
  }
}
