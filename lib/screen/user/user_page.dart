import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:katalog/screen/about/about.dart';

import 'package:katalog/services/auth/auth.dart';
import 'package:katalog/services/database/dbhelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  final User user;

  const UserPage({Key key, this.user}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState(user);
}

class _UserPageState extends State<UserPage> {
  final User user;
  _UserPageState(this.user);
  alergUserMassage(String warning) {
    AlertDialog errorLogin = AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 24),
      content: ListView(
        shrinkWrap: true,
        primary: false,
        children: [
          AppBar(
              backgroundColor: Colors.yellowAccent,
              leading: Icon(
                Icons.warning,
                color: Colors.redAccent,
              ),
              title: Text(
                "Penjelasan",
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true),
          Container(
              padding: EdgeInsets.all(18), child: Center(child: Text(warning))),
        ],
      ),
    );
    showDialog(context: context, builder: (context) => errorLogin);
  }

  bool _inProsessImage = false;
  File _selectedFile;
  ImagePicker _picker = ImagePicker();

  getImage(ImageSource souce) async {
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
          maxHeight: 500,
          maxWidth: 500,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: "Crop Image",
              toolbarColor: Colors.blue,
              statusBarColor: Colors.blue.shade900,
              backgroundColor: Colors.white));
      setState(() {
        _selectedFile = cropped;
        _inProsessImage = false;
      });
    } else {
      this.setState(() {
        _inProsessImage = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void saveReferan({String name, String img, String email}) async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    pre.setString("username", name);
    pre.setString("userImage", img);
    pre.setString("userEmail", email);
    print("referan Save");
  }

  bool enable = false;
  Image _image;
  TextEditingController _editUser = TextEditingController();
  TextEditingController _editinfo = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
            title: Text("Pengaturan Penguna"),
            centerTitle: true,
            actions: [
              !user.isAnonymous
                  ? IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        if (user.emailVerified) {
                          if (!enable) {
                            setState(() {
                              enable = true;
                            });
                          } else {
                            setState(() {
                              enable = false;
                            });
                          }
                        } else {
                          alergUserMassage(
                              "Silahkan cek email untuk verifikasi");
                        }
                      })
                  : Icon(Icons.announcement)
            ]),
        body: Container(
            child: !user.isAnonymous
                ? user.emailVerified
                    ? StreamBuilder<QuerySnapshot>(
                        stream: DatabaseCustom.getData("User")
                            .where("email", isEqualTo: user.email)
                            .snapshots(),
                        builder: (context, snapshot) {
                          print(user.email);
                          if (snapshot.hasData) {
                            return ListView.builder(
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  if (snapshot.data.docs[index]
                                          .data()['photo'] !=
                                      "") {
                                    _image = Image.memory(base64Decode(snapshot
                                        .data.docs[index]
                                        .data()['photo']));
                                    _editUser.text = snapshot.data.docs[index]
                                        .data()['username'];
                                    _editinfo.text = snapshot.data.docs[index]
                                        .data()['keterangan'];
                                    saveReferan(
                                        name: _editUser.text,
                                        img: snapshot.data.docs[index]
                                            .data()['photo'],
                                        email: user.email);
                                  }
                                  return ListView(shrinkWrap: true, children: [
                                    ListTile(
                                        title: Text("Photo Profile"),
                                        trailing: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                child: _selectedFile != null
                                                    ? Image.file(_selectedFile,
                                                        fit: BoxFit.cover)
                                                    : _inProsessImage
                                                        ? LinearProgressIndicator()
                                                        : _image)),
                                        onTap: () {
                                          if (enable == true) {
                                            getImage(ImageSource.gallery);
                                          }
                                        }),
                                    ListTile(
                                      leading: Icon(Icons.person),
                                      title: TextField(
                                        decoration: InputDecoration(
                                            enabled: enable,
                                            hintText: "Username"),
                                        controller: _editUser,
                                      ),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.email),
                                      title: Text(snapshot.data.docs[index]
                                          .data()['email']),
                                      trailing: user.emailVerified
                                          ? IconButton(
                                              icon: Icon(Icons.check,
                                                  color: Colors.blue),
                                              onPressed: null)
                                          : IconButton(
                                              icon: Icon(Icons.warning,
                                                  color: Colors.red),
                                              onPressed: null),
                                      onLongPress: () {
                                        if (user.emailVerified == true) {
                                          alergUserMassage(
                                              "Email sudah terverifikasi");
                                        } else {
                                          alergUserMassage(
                                              "Silahkan cek email untuk verifikasi");
                                        }
                                      },
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.notes),
                                        title: Text("Keterangan Diri")),
                                    ListTile(
                                        title: TextField(
                                            decoration: InputDecoration(
                                                enabled: enable,
                                                hintMaxLines: 5),
                                            minLines: 1,
                                            maxLines: 4,
                                            controller: _editinfo)),
                                    enable
                                        ? Wrap(
                                            alignment:
                                                WrapAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    if (_editinfo.text != "" ||
                                                        _editUser.text != "" ||
                                                        _selectedFile != null) {
                                                      DatabaseCustom.updateDataUser(
                                                          snapshot.data
                                                              .docs[index].id,
                                                          email: user.email,
                                                          name: _editUser.text,
                                                          info: _editinfo.text,
                                                          image: base64Encode(
                                                              _selectedFile
                                                                  .readAsBytesSync()));
                                                    }
                                                    enable = false;
                                                  },
                                                  child: Text("Simpan")),
                                              TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _editUser.text = snapshot
                                                          .data.docs[index]
                                                          .data()['username'];
                                                      _editinfo.text = snapshot
                                                          .data.docs[index]
                                                          .data()['keterangan'];
                                                      _selectedFile = null;
                                                      enable = false;
                                                    });
                                                    print("batal");
                                                  },
                                                  child: Text("Batal"))
                                            ],
                                          )
                                        : SizedBox(),
                                    Divider(),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AboutPage()));
                                        },
                                        child: Text("About")),
                                    ElevatedButton(
                                        onPressed: () {
                                          AuthCustom.signOut();
                                        },
                                        child: Text("SignOut"))
                                  ]);
                                });
                          }
                          return LinearProgressIndicator();
                        })
                    : StreamBuilder<QuerySnapshot>(
                        stream: DatabaseCustom.getData("User")
                            .where("email", isEqualTo: user.email)
                            .snapshots(),
                        builder: (context, snapshot) {
                          print(user.email);
                          if (snapshot.hasData) {
                            return ListView.builder(
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  if (snapshot.data.docs[index]
                                          .data()['photo'] !=
                                      "") {
                                    _image = Image.memory(base64Decode(snapshot
                                        .data.docs[index]
                                        .data()['photo']));
                                    _editUser.text = snapshot.data.docs[index]
                                        .data()['username'];
                                    _editinfo.text = snapshot.data.docs[index]
                                        .data()['keterangan'];
                                    saveReferan(
                                        name: _editUser.text,
                                        img: snapshot.data.docs[index]
                                            .data()['photo'],
                                        email: user.email);
                                  }
                                  return ListView(shrinkWrap: true, children: [
                                    ListTile(
                                        title: Text("Photo Profile"),
                                        trailing: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: _selectedFile != null
                                                ? Image.file(_selectedFile,
                                                    fit: BoxFit.cover)
                                                : _inProsessImage
                                                    ? LinearProgressIndicator()
                                                    : _image),
                                        onTap: () {
                                          if (enable == true) {
                                            getImage(ImageSource.gallery);
                                          }
                                        }),
                                    ListTile(
                                        leading: Icon(Icons.person),
                                        title: TextField(
                                            decoration: InputDecoration(
                                                enabled: enable,
                                                hintText: "Username"),
                                            controller: _editUser)),
                                    ListTile(
                                        leading: Icon(Icons.email),
                                        title: Text(snapshot.data.docs[index]
                                            .data()['email']),
                                        trailing: user.emailVerified
                                            ? IconButton(
                                                icon: Icon(Icons.check,
                                                    color: Colors.blue),
                                                onPressed: null)
                                            : IconButton(
                                                icon: Icon(Icons.warning,
                                                    color: Colors.red),
                                                onPressed: null),
                                        onLongPress: () {
                                          if (user.emailVerified == true) {
                                            alergUserMassage(
                                                "Email sudah terverifikasi");
                                          } else {
                                            alergUserMassage(
                                                "Silahkan cek email untuk verifikasi");
                                          }
                                        }),
                                    ListTile(
                                        leading: Icon(Icons.notes),
                                        title: Text("Keterangan Diri")),
                                    ListTile(
                                        title: TextField(
                                            decoration: InputDecoration(
                                                enabled: enable,
                                                hintMaxLines: 5),
                                            minLines: 1,
                                            maxLines: 4,
                                            controller: _editinfo)),
                                    enable
                                        ? Wrap(children: [
                                            TextButton(
                                                onPressed: () {
                                                  if (_editinfo.text != "" ||
                                                      _editUser.text != "" ||
                                                      _selectedFile != null) {
                                                    DatabaseCustom.updateDataUser(
                                                        snapshot.data
                                                            .docs[index].id,
                                                        email: user.email,
                                                        name: _editUser.text,
                                                        info: _editinfo.text,
                                                        image: base64Encode(
                                                            _selectedFile
                                                                .readAsBytesSync()));
                                                  }
                                                  enable = false;
                                                },
                                                child: Text("Simpan")),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _editUser.text = snapshot
                                                      .data.docs[index]
                                                      .data()['username'];
                                                  _editinfo.text = snapshot
                                                      .data.docs[index]
                                                      .data()['keterangan'];
                                                  _selectedFile = null;
                                                  enable = false;
                                                });
                                                print("batal");
                                              },
                                              child: Text("Batal"),
                                            )
                                          ])
                                        : SizedBox(),
                                    Divider(),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AboutPage()));
                                        },
                                        child: Text("About")),
                                    ElevatedButton(
                                        onPressed: () {
                                          AuthCustom.signOut();
                                        },
                                        child: Text("SignOut"))
                                  ]);
                                });
                          }
                          return LinearProgressIndicator();
                        })
                : buildListViewReferensi(context)));
  }

  ListView buildListViewReferensi(BuildContext context) {
    return ListView(shrinkWrap: true, children: [
      ListTile(leading: Icon(Icons.person), title: Text("Anonim")),
      Divider(),
      ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AboutPage()));
          },
          child: Text("About")),
      ElevatedButton(
          onPressed: () {
            AuthCustom.signOut();
          },
          child: Text("SignOut"))
    ]);
  }
}
