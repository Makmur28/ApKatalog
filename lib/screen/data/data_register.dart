import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:katalog/services/database/dbhelper.dart';
import 'package:katalog/services/tool/custom_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEditDataSatwa extends StatefulWidget {
  final DocumentSnapshot doc;

  const AddEditDataSatwa({Key key, this.doc}) : super(key: key);

  @override
  _AddEditDataSatwaState createState() => _AddEditDataSatwaState();
}

class _AddEditDataSatwaState extends State<AddEditDataSatwa> {
  String _textKategori,
      _textOrdo,
      _textFamili,
      _textGenus,
      _textSpecies,
      _textIUCN;
  bool _boolOrdo = false;
  bool _boolFamili = false;
  bool _boolGenus = false;
  bool _boolSpecies = false;

   String _nameUser, _imgUser, _emailUser;

  TextEditingController _namePublic = TextEditingController();
  TextEditingController _namePrivate = TextEditingController();
  TextEditingController _character = TextEditingController();
  TextEditingController _lifestyle = TextEditingController();
  TextEditingController _spread = TextEditingController();
  TextEditingController _ordo = TextEditingController();
  TextEditingController _famili = TextEditingController();
  TextEditingController _genus = TextEditingController();
  TextEditingController _species = TextEditingController();
  TextEditingController _source = TextEditingController();

  Future<String> getUser() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    return pre.getString("username") ?? "";
  }

  Future<String> getEmail() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    return pre.getString("userEmail") ?? "";
  }

  Future<String> getImage() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    return pre.getString("userImage") ?? "";
  }

  bool _inProsessImage = false;
  File _selectedFile;
  ImagePicker _picker = ImagePicker();
  String _img;

  void getPhoto(ImageSource souce) async {
    this.setState(() {
      _inProsessImage = true;
    });

    PickedFile file = await _picker.getImage(source: souce);
    if (file != null) {
      File image = File(file.path);
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxHeight: 1080,
          maxWidth: 1080,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: "Crop Image",
              toolbarColor: Colors.blue,
              statusBarColor: Colors.blue.shade900,
              backgroundColor: Colors.white));
      setState(() {
        _selectedFile = cropped;
        _inProsessImage = false;
        _img = base64Encode(_selectedFile.readAsBytesSync());
      });
    } else {
      this.setState(() {
        _inProsessImage = false;
      });
    }
  }

  void add() {
    List<String> splitList = _namePublic.text.split(" ");
    List<String> searchList = [];
    for (int i = 0; i < splitList.length; i++) {
      for (int y = 1; y < splitList[i].length + 1; y++) {
        searchList.add(splitList[i].substring(0, y).toLowerCase());
      }
    }
    DatabaseCustom.addData(
        nameUser: _nameUser,
        imgUser: _imgUser,
        email: _emailUser,
        general: _namePublic.text.toLowerCase(),
        public: _namePrivate.text.toLowerCase(),
        character: _character.text.toLowerCase(),
        lifestyle: _lifestyle.text.toLowerCase(),
        img: _img,
        spread: _spread.text.toLowerCase(),
        textKelas: _textKategori.toLowerCase(),
        textOrdo: _textOrdo.toLowerCase(),
        textFamili: _textFamili.toLowerCase(),
        textGenus: _textGenus.toLowerCase(),
        textSpecies: _textSpecies,
        source: _source.text,
        textIUCN: _textIUCN,
        searchList: searchList);
    alertSimple("Data Telah ditambahkan");
  }

  void update() {
    List<String> splitList = _namePublic.text.split(" ");
    List<String> searchList = [];
    for (int i = 0; i < splitList.length; i++) {
      for (int y = 1; y < splitList[i].length + 1; y++) {
        searchList.add(splitList[i].substring(0, y).toLowerCase());
      }
    }

    DatabaseCustom.updatedata(widget.doc.id,
        nameUser: _nameUser,
        imgUser: _imgUser,
        email: _emailUser,
        general: _namePublic.text.toLowerCase(),
        public: _namePrivate.text.toLowerCase(),
        character: _character.text.toLowerCase(),
        lifestyle: _lifestyle.text.toLowerCase(),
        img: _img,
        spread: _spread.text.toLowerCase(),
        textKelas: _textKategori.toLowerCase(),
        textOrdo: _textOrdo.toLowerCase(),
        textFamili: _textFamili.toLowerCase(),
        textGenus: _textGenus.toLowerCase(),
        textSpecies: _textSpecies,
        source: _source.text,
        textIUCN: _textIUCN,
        searchList: searchList);
    alertSimple("Update Data berhasil");
  }

  alertSimple(String title) {
    AlertDialog _warning = AlertDialog(
        content: SizedBox(
            child: ListView(
                shrinkWrap: true,
                primary: false,
                children: [ListTile(title: Text(title))])),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Iya"))
        ]);
    showDialog(
        barrierDismissible: false, context: context, builder: (_) => _warning);
  }

  alerfail(String title) {
    AlertDialog _warning = AlertDialog(
        content: SizedBox(
            child: ListView(
                shrinkWrap: true,
                primary: false,
                children: [ListTile(title: Text(title))])),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Iya"))
        ]);
    showDialog(
        barrierDismissible: false, context: context, builder: (_) => _warning);
  }

  @override
  void initState() {
    getUser().then((value) {
      _nameUser = value;
      setState(() {});
    });
    getImage().then((value) {
      _imgUser = value;
      setState(() {});
    });
    getEmail().then((value) {
      _emailUser = value;
      setState(() {});
    });
    if (widget.doc != null) {
      setState(() {
        _textKategori = widget.doc.data()["Kelas"];
        _namePublic.text = widget.doc.data()["general"];
        _namePrivate.text = widget.doc.data()["public"];
        _character.text = widget.doc.data()["character"];
        _lifestyle.text = widget.doc.data()["lifestyle"];
        _img = widget.doc.data()["img"];
        _spread.text = widget.doc.data()["spread"];
        _textOrdo = widget.doc.data()["Ordo"].toString().toLowerCase();
        _textFamili = widget.doc.data()["Famili"].toString().toLowerCase();
        _textGenus = widget.doc.data()["Genus"].toString().toLowerCase();
        _textSpecies = widget.doc.data()["Species"].toString().toLowerCase();
        _textIUCN = widget.doc.data()["IUCN"].toString().toUpperCase();
        _source.text = widget.doc.data()["source"];
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      if (_namePublic.text != "" ||
                          _namePublic.text != "" ||
                          _namePrivate.text != "" ||
                          _character.text != "" ||
                          _lifestyle.text != "" ||
                          _img != null ||
                          _spread.text != "" ||
                          _textKategori != null ||
                          _textOrdo != null ||
                          _textFamili != null ||
                          _textGenus != null ||
                          _textSpecies != null ||
                          _source.text != "" ||
                          _textIUCN != null) {
                        alertSimple("Yakin keluar dari ini ?");
                      } else {
                        Navigator.pop(context);
                      }
                    }),
                title: Text("Upload data Satwa"),
                actions: [
                  widget.doc == null
                      ? IconButton(
                          icon: Icon(Icons.file_upload),
                          onPressed: () {
                            if (_namePublic.text != "" &&
                                _namePublic.text != "" &&
                                _namePrivate.text != "" &&
                                _character.text != "" &&
                                _lifestyle.text != "" &&
                                _img != null &&
                                _spread.text != "" &&
                                _textKategori != null &&
                                _textOrdo != null &&
                                _textFamili != null &&
                                _textGenus != null &&
                                _textSpecies != null &&
                                _source.text != "" &&
                                _textIUCN != null) {
                              if (widget.doc == null) {
                                add();
                              }
                            } else {
                              alerfail("Silahkan Cek Kembali data");
                            }
                          })
                      : IconButton(
                          icon: Icon(Icons.repeat),
                          onPressed: () {
                            if (_namePublic.text != "" &&
                                _namePublic.text != "" &&
                                _namePrivate.text != "" &&
                                _character.text != "" &&
                                _lifestyle.text != "" &&
                                _img != null &&
                                _spread.text != "" &&
                                _textKategori != null &&
                                _textOrdo != null &&
                                _textFamili != null &&
                                _textGenus != null &&
                                _textSpecies != null &&
                                _source.text != "" &&
                                _textIUCN != null) update();
                          })
                ]),
            body: Container(
                color: Colors.blueGrey[100],
                child: ListView(children: [
                  ListTile(
                      title: Text("Jenis Satwa"),
                      trailing: StreamBuilder<QuerySnapshot>(
                          stream: DatabaseCustom.getDataOneDoc(
                              "Kategori", "aktif", true),
                          builder: (context, snaphot) {
                            if (!snaphot.hasData) {
                              return DropdownButton(items: [], onChanged: null);
                            } else {
                              return DropdownButton(
                                  value: _textKategori,
                                  hint: Text("Pilih"),
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
                          })),
                  buildTextCustom(
                      control: _namePublic,
                      hint: "Nama Umum Satwa",
                      icon: Icons.notes,
                      type: TextInputType.text),
                  buildTextCustom(
                      control: _namePrivate,
                      hint: "Nama Latin Satwa",
                      icon: Icons.notes,
                      type: TextInputType.text),
                  buildTextCustom(
                      control: _character,
                      hint: "Karakteristik Satwa",
                      icon: Icons.notes,
                      type: TextInputType.multiline),
                  buildTextCustom(
                      control: _lifestyle,
                      hint: "Pola Hidup Satwa",
                      icon: Icons.notes,
                      type: TextInputType.multiline),
                  buildTextCustom(
                      control: _spread,
                      hint: "Penyebaran Satwa",
                      icon: Icons.map,
                      type: TextInputType.multiline),
                  Divider(),
                  ListTile(
                      leading: Icon(Icons.image),
                      title: Text("Foto Satwa"),
                      onTap: () {
                        getPhoto(ImageSource.gallery);
                      }),
                  Wrap(children: [
                    Center(
                        child: SizedBox(
                            height: 200,
                            width: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: _selectedFile != null
                                  ? Image.file(_selectedFile, fit: BoxFit.cover)
                                  : _inProsessImage
                                      ? SizedBox()
                                      : _img != null
                                          ? Image.memory(base64Decode(_img))
                                          : Icon(Icons.image, size: 140),
                            )))
                  ]),
                  Divider(),
                  ListTile(
                    title: Text("Klasifikasi Satwa"),
                  ),
                  ListTile(
                      trailing: _boolOrdo
                          ? IconButton(
                              icon: Icon(Icons.save),
                              onPressed: () {
                                if (_ordo.text != "") {
                                  DatabaseCustom.search("Ordo", _ordo.text)
                                      .then((value) {
                                    if (!value.docs.isNotEmpty) {
                                      DatabaseCustom.addDataItem(
                                          'Ordo',
                                          "Kelas",
                                          _textKategori,
                                          _ordo.text.toLowerCase(),
                                          true);
                                      print("Save Ordo");
                                      setState(() => _boolOrdo = false);
                                    }
                                  });
                                } else {
                                  alerfail("Tidak ada Input");
                                  setState(() => _boolOrdo = false);
                                }
                              })
                          : IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() => _boolOrdo = true);
                              }),
                      leading: Text("Ordo"),
                      title: StreamBuilder<QuerySnapshot>(
                          stream: DatabaseCustom.getDataOneDoc(
                              "Ordo", "Kelas", _textKategori),
                          builder: (context, snaphot) {
                            if (!snaphot.hasData) {
                              return DropdownButton(items: [], onChanged: null);
                            } else {
                              return DropdownButton(
                                  value: _textOrdo,
                                  hint: Text("Pilih"),
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
                                      _textOrdo = newvalue;
                                    });
                                  });
                            }
                          })),
                  _boolOrdo
                      ? buildTextCustom(
                          hint: "Ordo",
                          icon: Icons.notes,
                          control: _ordo,
                          type: TextInputType.text)
                      : SizedBox(),
                  ListTile(
                      trailing: _boolFamili
                          ? IconButton(
                              icon: Icon(Icons.save),
                              onPressed: () {
                                if (_famili.text != "") {
                                  DatabaseCustom.search("Famili", _famili.text)
                                      .then((value) {
                                    if (!value.docs.isNotEmpty) {
                                      DatabaseCustom.addDataItem(
                                          "Famili",
                                          'Ordo',
                                          _textOrdo,
                                          _famili.text.toLowerCase(),
                                          true);
                                      print("Save Ordo");
                                      setState(() => _boolFamili = false);
                                    }
                                  });
                                } else {
                                  alerfail("Tidak ada Input");
                                  setState(() => _boolFamili = false);
                                }
                              })
                          : IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() => _boolFamili = true);
                              }),
                      leading: Text("Famili"),
                      title: StreamBuilder<QuerySnapshot>(
                          stream: DatabaseCustom.getDataOneDoc(
                              "Famili", "Ordo", _textOrdo),
                          builder: (context, snaphot) {
                            if (!snaphot.hasData) {
                              return DropdownButton(items: [], onChanged: null);
                            } else {
                              return DropdownButton(
                                  value: _textFamili,
                                  hint: Text("Pilih"),
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
                                      _textFamili = newvalue;
                                    });
                                  });
                            }
                          })),
                  _boolFamili
                      ? buildTextCustom(
                          hint: "Family",
                          icon: Icons.notes,
                          control: _famili,
                          type: TextInputType.text)
                      : SizedBox(),
                  ListTile(
                      trailing: _boolGenus
                          ? IconButton(
                              icon: Icon(Icons.save),
                              onPressed: () {
                                if (_genus.text != "") {
                                  DatabaseCustom.search("Genus", _genus.text)
                                      .then((value) {
                                    if (!value.docs.isNotEmpty) {
                                      DatabaseCustom.addDataItem(
                                          "Genus",
                                          "Famili",
                                          _textFamili,
                                          _genus.text.toLowerCase(),
                                          true);
                                      setState(() => _boolGenus = false);
                                    }
                                  });
                                } else {
                                  alerfail("Tidak ada Input");
                                  setState(() => _boolGenus = false);
                                }
                              })
                          : IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() => _boolGenus = true);
                              }),
                      leading: Text("Genus"),
                      title: StreamBuilder<QuerySnapshot>(
                          stream: DatabaseCustom.getDataOneDoc(
                              "Genus", "Famili", _textFamili),
                          builder: (context, snaphot) {
                            if (!snaphot.hasData) {
                              return DropdownButton(items: [], onChanged: null);
                            } else {
                              return DropdownButton(
                                  value: _textGenus,
                                  hint: Text("Pilih"),
                                  items: snaphot.data.docs
                                      .map((e) => DropdownMenuItem(
                                            child: Text(e
                                                .data()['nama']
                                                .toString()
                                                .toUpperCase()),
                                            value: e.data()['nama'],
                                          ))
                                      .toList(),
                                  onChanged: (newvalue) {
                                    setState(() {
                                      _textGenus = newvalue;
                                    });
                                  });
                            }
                          })),
                  _boolGenus
                      ? buildTextCustom(
                          hint: "Genus",
                          icon: Icons.notes,
                          control: _genus,
                          type: TextInputType.text)
                      : SizedBox(),
                  ListTile(
                      trailing: _boolSpecies
                          ? IconButton(
                              icon: Icon(Icons.save),
                              onPressed: () {
                                DatabaseCustom.search("Species", _species.text)
                                    .then((value) {
                                  if (!value.docs.isNotEmpty) {
                                    DatabaseCustom.addDataItem(
                                        "Species",
                                        "Genus",
                                        _textGenus,
                                        _species.text.toLowerCase(),
                                        true);
                                    setState(() => _boolSpecies = false);
                                  }
                                });
                              })
                          : IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() => _boolSpecies = true);
                              }),
                      leading: Text("Species"),
                      title: StreamBuilder<QuerySnapshot>(
                          stream: DatabaseCustom.getDataOneDoc(
                              "Species", "Genus", _textGenus),
                          builder: (context, snaphot) {
                            if (!snaphot.hasData) {
                              return DropdownButton(items: [], onChanged: null);
                            } else {
                              return DropdownButton(
                                  value: _textSpecies,
                                  hint: Text("Pilih"),
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
                                      _textSpecies = newvalue;
                                    });
                                  });
                            }
                          })),
                  _boolSpecies
                      ? buildTextCustom(
                          hint: "Spesies",
                          icon: Icons.notes,
                          control: _species,
                          type: TextInputType.text)
                      : SizedBox(),
                  ListTile(
                      title: Text("Status Konservasi IUCN"),
                      trailing: StreamBuilder<QuerySnapshot>(
                          stream: DatabaseCustom.getDataOneDoc(
                              "IUCN", "aktif", true),
                          builder: (context, snaphot) {
                            if (!snaphot.hasData) {
                              return DropdownButton(items: [], onChanged: null);
                            } else {
                              return DropdownButton(
                                  value: _textIUCN,
                                  hint: Text("Pilih"),
                                  items: snaphot.data.docs
                                      .map((e) => DropdownMenuItem(
                                          child: Text(e.data()['singkat']),
                                          value: e.data()['singkat']))
                                      .toList(),
                                  onChanged: (newvalue) {
                                    setState(() {
                                      _textIUCN = newvalue;
                                    });
                                  });
                            }
                          })),
                  buildTextCustom(
                      control: _source,
                      hint: "sumber",
                      icon: Icons.book,
                      type: TextInputType.text)
                ]))));
  }

  ListTile buildTextCustom(
      {IconData icon,
      String hint,
      TextEditingController control,
      TextInputType type}) {
    return ListTile(
        leading: Icon(icon, size: 30),
        title: TextField(
          minLines: 1,
          maxLines: 15,
          controller: control,
          keyboardType: type,
          decoration: registerInputDecoration(hintText: hint),
        ),
        onLongPress: () {
          showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(content: SizedBox(child: Text(" $hint"))));
        });
  }
}
