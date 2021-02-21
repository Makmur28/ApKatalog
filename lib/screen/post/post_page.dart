import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:katalog/screen/data/data_detail.dart';
import 'package:katalog/screen/data/data_register.dart';
import 'package:katalog/services/database/dbhelper.dart';

class PostPage extends StatefulWidget {
  final User user;
  const PostPage({Key key, this.user}) : super(key: key);
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String _email, _textKategori;
  bool filter = false;
  @override
  void initState() {
    if (!widget.user.isAnonymous) {
      _email = widget.user.email;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.file_copy), onPressed: () {}),
          title: Text("Daftar Upload Anda")),
      body: widget.user.isAnonymous
          ? Center(
              child: Text("Silahkan mendaftar/login dahulu",
                  style: TextStyle(fontSize: 20)))
          : Column(
              children: [
                ListTile(
                    leading: Text(
                      "Filter Kategori Satwa",
                      style: TextStyle(fontSize: 15),
                    ),
                    title: StreamBuilder<QuerySnapshot>(
                        stream: DatabaseCustom.getDataOneDoc(
                            "Kategori", "aktif", true),
                        builder: (context, snaphot) {
                          if (!snaphot.hasData) {
                            return DropdownButton(items: [], onChanged: null);
                          } else {
                            return DropdownButton(
                                value: _textKategori,
                                hint: Text("All"),
                                items: snaphot.data.docs
                                    .map((e) => DropdownMenuItem(
                                        child: Text(e
                                            .data()['nama']
                                            .toString()
                                            .toUpperCase()),
                                        value: e.data()['nama']))
                                    .toList(),
                                onChanged: (newvalue) {
                                  setState(() {
                                    _textKategori = newvalue;
                                  });
                                });
                          }
                        }),
                    trailing: Switch(
                        value: filter,
                        onChanged: (value) {
                          if (_textKategori != null) {
                            setState(() {
                              filter = value;
                            });
                          }
                        })),
                filter
                    ? Expanded(
                        child: buildUserVal(DatabaseCustom.getData("Satwa")
                            .where("email", isEqualTo: _email)
                            .where("Kelas",
                                isEqualTo: _textKategori.toLowerCase())))
                    : Expanded(
                        child: buildUserVal(DatabaseCustom.getData("Satwa")
                            .where("email", isEqualTo: _email)))
              ],
            ),
      floatingActionButton: widget.user.isAnonymous == false
          ? FloatingActionButton(
              onPressed: () {
                if (widget.user.isAnonymous) {
                  print("Silahkan mendaftar/login dahulu");
                } else {
                  print("Anda bisa membuat Post");
                  if (widget.user.emailVerified == true) {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AddEditDataSatwa()));
                  } else {
                    AlertDialog cekemail = AlertDialog(
                        content: Container(
                            height: 50,
                            child: Center(
                                child: Text(
                                    "Silahkan Cek Email untuk verisikasi"))));
                    showDialog(
                        useSafeArea: true,
                        context: context,
                        builder: (context) => cekemail);
                  }
                }
              },
              child: Icon(Icons.upload_file))
          : null,
    );
  }

  StreamBuilder<QuerySnapshot> buildUserVal(datasnapshot) {
    return StreamBuilder<QuerySnapshot>(
        stream: datasnapshot.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Container(
                    height: 50, width: 50, child: CircularProgressIndicator()));
          }
          return ListView.builder(
              padding: EdgeInsets.fromLTRB(6, 12, 14, 0),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return Card(
                    child: ListView(shrinkWrap: true, children: [
                  ListTile(
                      onLongPress: () {
                        AlertDialog _warning = AlertDialog(
                            content: SizedBox(
                                child: ListView(
                                    shrinkWrap: true,
                                    primary: false,
                                    children: [
                                  ListTile(
                                      title: Text(
                                          "Yakin data ${snapshot.data.docs[index].data()['general'].toString().toUpperCase()} harus di hapus ? "))
                                ])),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    DatabaseCustom.deleteDataItem(
                                        "Satwa", snapshot.data.docs[index].id);
                                    Navigator.pop(context);
                                  },
                                  child: Text("Iya")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Tidak"))
                            ]);
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => _warning);
                      },
                      title: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                              base64Decode(
                                  snapshot.data.docs[index].data()['img']),
                              cacheWidth:
                                  (MediaQuery.of(context).size.width * 0.9)
                                      .toInt(),
                              cacheHeight:
                                  (MediaQuery.of(context).size.width * 0.7)
                                      .toInt(),
                              fit: BoxFit.cover)),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetailPage(
                                    docs: snapshot.data.docs[index])));
                      }),
                  ListTile(
                      onLongPress: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => AddEditDataSatwa(
                                doc: snapshot.data.docs[index])));
                      },
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
                              child: Text(
                                  snapshot.data.docs[index].data()['IUCN']))))
                ]));
              });
        });
  }
}
