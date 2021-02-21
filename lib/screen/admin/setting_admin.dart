import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katalog/services/database/dbhelper.dart';
import 'package:katalog/services/tool/custom_decoration.dart';

class AdminCostum extends StatefulWidget {
  final String inAkun;

  const AdminCostum({Key key, this.inAkun}) : super(key: key);
  @override
  _AdminCostumState createState() => _AdminCostumState();
}

class _AdminCostumState extends State<AdminCostum> {
  SizedBox buildLoadDatabase(String table, String subtable) {
    return SizedBox(
        child: StreamBuilder<QuerySnapshot>(
            stream: DatabaseCustom.getData(table).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              return ListView(shrinkWrap: true, children: [
                ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data.docs[index];
                      return ListTile(
                          focusColor: Colors.lightBlue,
                          leading: Icon(Icons.arrow_right),
                          title: Text(doc.data()['nama'],
                              style: TextStyle(
                                  color: doc.data()['aktif']
                                      ? Colors.black
                                      : Colors.redAccent)),
                          trailing: IconButton(
                              color: Colors.blueAccent,
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AddEditData(
                                        doc: doc,
                                        table: table,
                                        subtable: subtable)));
                              }),
                          onLongPress: () {
                            alertWarning(
                                id: doc.id,
                                table: table,
                                title: doc.data()['nama']);
                          });
                    }),
                buildViewCount(snapshot)
              ]);
            }));
  }

  void _listDataCustom(String table, String subtable) {
    AlertDialog _listData = AlertDialog(
        content: ListView(shrinkWrap: true, children: [
      buildLoadDatabase(table, subtable),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddEditData(
                    doc: null,
                    table: table,
                    subtable: subtable,
                  )));
        },
        child: Text("Tambah data"),
      )
    ]));
    showDialog(context: context, builder: (_) => _listData);
  }

  void _snackbar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: Duration(milliseconds: 1000), content: Text(title)));
  }

  bool _listCategory = false;
  bool _listKlasifikas = false;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            key: _key,
            appBar: AppBar(
              title: Text("Settingan Admin"),
            ),
            body: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView(shrinkWrap: true, primary: false, children: [
                  TextButton(
                    onPressed: () {},
                    child: Text("Setting Data Satwa"),
                  ),
                  ListTile(
                      onTap: () {
                        if (!_listCategory)
                          setState(() {
                            _listCategory = true;
                          });
                        else
                          setState(() {
                            _listCategory = false;
                          });
                      },
                      title: Text("Pengaturan Kategori Satwa"),
                      tileColor: Colors.cyanAccent),
                  _listCategory
                      ? buildLoadDatabase("Kategori", "Kingdom")
                      : SizedBox(),
                  _listCategory
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AddEditData(
                                      doc: null,
                                      table: "Kategori",
                                      subtable: "Kingdom")));
                            },
                            child: Text("Tambah data"),
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                      onTap: () {
                        if (!_listKlasifikas)
                          setState(() {
                            _listKlasifikas = true;
                          });
                        else
                          setState(() {
                            _listKlasifikas = false;
                          });
                      },
                      title: Text("Setting Klasifikas Satwa"),
                      tileColor: Colors.green),
                  _listKlasifikas
                      ? Wrap(spacing: 3.0, runSpacing: 0.0, children: [
                          TextButton(
                            onPressed: () {
                              _listDataCustom("Ordo", "Kategori");
                            },
                            child: Text("Setting Data Ordo"),
                          ),
                          TextButton(
                            onPressed: () {
                              _listDataCustom("Famili", "Ordo");
                            },
                            child: Text("Setting Data Family"),
                          ),
                          TextButton(
                            onPressed: () {
                              _listDataCustom("Genus", "Famili");
                            },
                            child: Text("Setting Data Genus"),
                          ),
                          TextButton(
                            onPressed: () {
                              _listDataCustom("Species", "Genus");
                            },
                            child: Text("Setting Data Spesies"),
                          )
                        ])
                      : SizedBox(),
                  TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                  content:
                                      ListView(shrinkWrap: true, children: [
                                StreamBuilder(
                                    stream: DatabaseCustom.getData("Satwa")
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData)
                                        return LinearProgressIndicator();
                                      return Column(children: [
                                        ListView.builder(
                                            shrinkWrap: true,
                                            primary: false,
                                            itemCount:
                                                snapshot.data.docs.length,
                                            itemBuilder: (context, index) {
                                              DocumentSnapshot doc =
                                                  snapshot.data.docs[index];
                                              return ListTile(
                                                  focusColor: Colors.lightBlue,
                                                  leading:
                                                      Icon(Icons.arrow_right),
                                                  title: Text(
                                                      doc.data()['general']),
                                                  trailing: SizedBox(
                                                      height: 30,
                                                      width: 30,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: Image.memory(
                                                              base64Decode(doc
                                                                      .data()[
                                                                  'imgUser'])))),
                                                  onLongPress: () {
                                                    alertWarning(
                                                        table: "Satwa",
                                                        id: doc.id,
                                                        title: doc
                                                            .data()['general']);
                                                  });
                                            }),
                                        buildViewCount(snapshot)
                                      ]);
                                    })
                              ])));
                    },
                    child: Text("List Data Satwa"),
                  ),
                  TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                    content:
                                        ListView(shrinkWrap: true, children: [
                                  StreamBuilder(
                                      stream: DatabaseCustom.getData("Admin")
                                          .where("nama",
                                              isNotEqualTo: widget.inAkun)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData)
                                          return LinearProgressIndicator();
                                        return Column(children: [
                                          ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              itemCount:
                                                  snapshot.data.docs.length,
                                              itemBuilder: (context, index) {
                                                DocumentSnapshot doc =
                                                    snapshot.data.docs[index];
                                                return ListTile(
                                                    focusColor:
                                                        Colors.lightBlue,
                                                    leading:
                                                        Icon(Icons.arrow_right),
                                                    title: Text(
                                                        doc.data()['nama']),
                                                    trailing: IconButton(
                                                      icon: Icon(Icons.edit),
                                                      onPressed: () {},
                                                    ),
                                                    onLongPress: () {
                                                      Navigator.pop(context);
                                                      alertWarning(
                                                          table: "Admin",
                                                          id: doc.id,
                                                          title: doc
                                                              .data()['nama']);
                                                    });
                                              }),
                                          buildViewCount(snapshot),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              addEditAdmin(doc: null);
                                            },
                                            child: Text("Tambah Admin"),
                                          )
                                        ]);
                                      }),
                                ])));
                      },
                      child: Text("Data Admin")),
                  TextButton(
                      onPressed: () {
                        _snackbar("Keluar dari Mode Admin");
                        Navigator.pop(context);
                      },
                      child: Text("Keluar")),
                ]))));
  }

  addEditAdmin({DocumentSnapshot doc}) {
    TextEditingController _teAdmin = TextEditingController();
    TextEditingController _tePasAdmin = TextEditingController();
    TextEditingController _teRePasAdmin = TextEditingController();
    if (doc != null) {
      setState(() {
        _teAdmin = doc.data()["nama"];
        _tePasAdmin = doc.data()["pass"];
      });
    }
    AlertDialog admin = AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 18.0),
      content: ListView(shrinkWrap: true, children: [
        AppBar(
          leading: Icon(Icons.admin_panel_settings),
          title: Text("Register Admin"),
        ),
        buildInputAdmin(
            controller: _teAdmin, hint: "Nama Admin", hidden: false),
        buildInputAdmin(
            controller: _tePasAdmin, hint: "Password Admin", hidden: true),
        buildInputAdmin(
            controller: _teRePasAdmin,
            hint: "Konfirmasi Password Admin",
            hidden: true),
      ]),
      actions: [
        TextButton(
            onPressed: () {
              if (_teAdmin.text != "" &&
                  _tePasAdmin.text != "" &&
                  _teRePasAdmin.text == _tePasAdmin.text) {
                DatabaseCustom.addDataItem(
                    "Admin", "pass", _tePasAdmin.text, _teAdmin.text, true);
                Navigator.pop(context);
              } else {
                _snackbar("Silahkan Cek kembali data");
                Navigator.pop(context);
              }
            },
            child: Text("Tambah")),
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Batal"))
      ],
    );
    showDialog(context: context, builder: (_) => admin);
  }

  Padding buildInputAdmin(
      {TextEditingController controller, String hint, bool hidden}) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
            obscureText: hidden,
            decoration: registerInputDecoration(hintText: hint),
            controller: controller));
  }

  ListTile buildViewCount(AsyncSnapshot snapshot) {
    return ListTile(title: Text("Jumlah data : ${snapshot.data.docs.length}"));
  }

  alertWarning({String id, String title, String table}) {
    AlertDialog _warning = AlertDialog(
      content: Text("Hapus data $title"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("tidak")),
        TextButton(
            onPressed: () {
              print("jadi menghapus $title}");
              DatabaseCustom.deleteDataItem(table, id);

              Navigator.pop(context);
            },
            child: Text("Iya"))
      ],
    );
    showDialog(context: context, builder: (_) => _warning);
  }
}

class AddEditData extends StatefulWidget {
  final DocumentSnapshot doc;
  final String table, subtable;

  const AddEditData({
    Key key,
    @required this.doc,
    @required this.table,
    @required this.subtable,
  }) : super(key: key);
  @override
  _AddEditDataState createState() => _AddEditDataState(
        doc,
        table,
        subtable,
      );
}

class _AddEditDataState extends State<AddEditData> {
  final DocumentSnapshot docs;
  final String subtable, table;

  String _subtitle, _subtable;
  String _itemDrop;
  String _subInput = "pilih";
  bool _checkboxVal = false;

  TextEditingController _name = TextEditingController();

  _AddEditDataState(this.docs, this.table, this.subtable);

  @override
  void initState() {
    if (docs != null) {
      _subtitle = "Edit data ${this.table}";
      _subtable = subtable;
      _itemDrop = docs.data()[subtable].toString().toLowerCase();
      _subtable = subtable;
      _name.text = docs.data()['nama'];
      _checkboxVal = docs.data()['aktif'];
    } else {
      _subtitle = "Add data ${this.table}";
      _subtable = subtable;
      _name.text = "";
      _checkboxVal = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_name.text != "" || _subInput != "Silahkan Pilih") {
                        alerDialogCustom();
                      } else {
                        Navigator.pop(context);
                      }
                    }),
                title: Text(_subtitle),
                centerTitle: true),
            body: ListView(shrinkWrap: true, children: [
              ListTile(
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {},
                  ),
                  leading: Text(
                    "Jenis $subtable",
                    style: TextStyle(fontSize: 17),
                  ),
                  title: StreamBuilder<QuerySnapshot>(
                      stream: DatabaseCustom.getData(subtable).snapshots(),
                      builder: (context, snaphot) {
                        if (!snaphot.hasData) {
                          return DropdownButton(items: [], onChanged: null);
                        } else {
                          return DropdownButton(
                              value: _itemDrop,
                              hint: Text("Silahkan Pilih"),
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
                                  _itemDrop = newvalue;
                                });
                              });
                        }
                      })),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: TextField(
                      controller: _name,
                      decoration: InputDecoration(hintText: "Nama $table"))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text("Bisa Digunakan "),
                Checkbox(
                    value: _checkboxVal,
                    onChanged: (newVal) {
                      setState(() {
                        _checkboxVal = newVal;
                      });
                    })
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                TextButton(
                  onPressed: () {
                    if (_subInput != "" && _name.text != "") {
                      if (docs == null) {
                        DatabaseCustom.addDataItem(table, _subtable, _itemDrop,
                            _name.text, _checkboxVal);
                        Navigator.pop(context);
                      } else {
                        DatabaseCustom.updateDataItem(table, docs.id,
                            sub: _subtable,
                            subInput: _itemDrop.toLowerCase(),
                            title: _name.text,
                            enable: _checkboxVal);
                        Navigator.pop(context);
                      }
                    } else if (_subInput == "Silahkan Pilih" ||
                        _name.text == "") {
                      print("silahkan isi dengan benar");
                    }
                  },
                  child: docs == null ? Text("SIMPAN") : Text("MEMPERBARUI"),
                ),
                TextButton(
                    onPressed: () {
                      if (docs == null) {
                        setState(() {
                          _subInput = "Silahkan Pilih";
                          _name.text = "";
                          _checkboxVal = false;
                        });
                      }
                    },
                    child: Text("HAPUS")),
                TextButton(
                    onPressed: () {
                      if (_name.text != null || _subInput != "Silahkan Pilih") {
                        alerDialogCustom();
                      }
                    },
                    child: Text("BATAL"))
              ])
            ])));
  }

  alerDialogCustom() {
    AlertDialog _warning = AlertDialog(
        content: SizedBox(
            child: ListView(shrinkWrap: true, primary: false, children: [
      ListTile(title: Text("Yakin Keluar ? ")),
      ButtonBar(children: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Tidak")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Iya"))
      ])
    ])));
    showDialog(
        barrierDismissible: false, context: context, builder: (_) => _warning);
  }
}
