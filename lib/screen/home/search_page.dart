import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:katalog/screen/data/data_detail.dart';
import 'package:katalog/services/database/dbhelper.dart';

class SearchText extends StatefulWidget {
  @override
  _SearchTextState createState() => _SearchTextState();
}

class _SearchTextState extends State<SearchText> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.grey,
                title: TextField(
                    onChanged: (val) {
                      initiateSearch(val);
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 25.0),
                        hintText: 'Search by name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0))))),
            body: StreamBuilder<QuerySnapshot>(
                stream: search != "" && search != null
                    ? DatabaseCustom.getData("Satwa")
                        .where("search", arrayContains: search)
                        .snapshots()
                    : DatabaseCustom.getData("Satwa").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return LinearProgressIndicator();
                    default:
                      return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) => Card(
                                  child: Column(children: [
                                ListTile(
                                    title: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.memory(
                                            base64Decode(snapshot
                                                .data.docs[index]
                                                .data()['img']),
                                            cacheWidth: (MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9)
                                                .toInt(),
                                            cacheHeight: (MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7)
                                                .toInt(),
                                            fit: BoxFit.cover)),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => DetailPage(
                                                  docs: snapshot
                                                      .data.docs[index])));
                                    }),
                                ListTile(
                                    title: Text(
                                        snapshot.data.docs[index]
                                            .data()['general']
                                            .toString()
                                            .toUpperCase(),
                                        style: TextStyle(color: Colors.black)),
                                    trailing: SizedBox(
                                        height: 30,
                                        child: CircleAvatar(
                                            backgroundColor: Colors.green,
                                            child: Text(snapshot
                                                .data.docs[index]
                                                .data()['IUCN']))))
                              ])));
                  }
                })));
  }

  void initiateSearch(String val) {
    setState(() {
      search = val.toLowerCase().trim();
    });
  }
}
