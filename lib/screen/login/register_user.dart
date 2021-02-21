import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:katalog/services/auth/auth.dart';
import 'package:katalog/services/database/dbhelper.dart';
import 'package:katalog/services/tool/custom_decoration.dart';

class RegisterUser extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  TextEditingController _teEmail = TextEditingController();
  TextEditingController _tePass = TextEditingController();
  TextEditingController _teRePass = TextEditingController();

  String valPassword(String value) {
    if (value.length < 6)
      return 'masukan password lebih dari 5 digit';
    else
      return null;
  }

  String valRePassword(String value) {
    if (value != _tePass.text)
      return 'Password Tidak Sama';
    else
      return null;
  }

  String valEmail(String value) {
    if (!EmailValidator.validate(value))
      return 'Masukan Email';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              leading: Icon(Icons.app_registration),
              title: Text("Pendaftaran"),
            ),
            body: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView(children: [
                      buildTextInputCustomOne(
                          hint: "Email",
                          icon: Icons.email,
                          control: _teEmail,
                          type: TextInputType.emailAddress,
                          val: valEmail,
                          hidden: false),
                      buildTextInputCustomOne(
                          hint: "password",
                          icon: Icons.lock,
                          control: _tePass,
                          type: TextInputType.name,
                          val: valPassword,
                          hidden: true),
                      buildTextInputCustomOne(
                          hint: "konfirmasi password",
                          icon: Icons.lock,
                          control: _teRePass,
                          type: TextInputType.name,
                          val: valRePassword,
                          hidden: true),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          child: Text("Daftar Sekarang"),
                          onPressed: () async {
                            if (valPassword(_tePass.text) == null &&
                                valEmail(_teEmail.text) == null &&
                                _tePass.text == _teRePass.text) {
                              AuthCustom.signUp(_teEmail.text, _tePass.text)
                                  .then((value) {
                                print("Test value isi yang apa $value");
                                if (value != null) {
                                  DatabaseCustom.addDataUser(
                                      _teEmail.text, "", "", "");
                                  Navigator.of(context).pop();
                                } else {
                                  AlertDialog warning = AlertDialog(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 24),
                                      content:
                                          ListView(shrinkWrap: true, children: [
                                        AppBar(
                                            leading: SizedBox(),
                                            title: Text("Pemberitahuan"),
                                            centerTitle: true),
                                        Container(
                                            padding: EdgeInsets.all(18),
                                            child: Center(
                                                child: Text(
                                                    "Email salah atau telah digunakan")))
                                      ]));
                                  showDialog(
                                      context: context,
                                      builder: (_) => warning);
                                }
                              });

                              //Navigator.of(context).pop();
                            } else {
                              //SnackBar(content: null);
                              print("same thing error");
                            }
                          })
                    ])))));
  }

  Stack buildTextInputCustomOne(
      {IconData icon,
      String hint,
      TextEditingController control,
      TextInputType type,
      Function val,
      bool hidden}) {
    return Stack(children: [
      Row(children: [
        Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 8.0),
            child: Icon(icon, size: 30))
      ]),
      Row(children: [
        SizedBox(width: 50),
        Expanded(
            child: TextFormField(
                obscureText: hidden,
                controller: control,
                validator: val,
                keyboardType: type,
                decoration: registerInputDecoration(hintText: hint)))
      ])
    ]);
  }
}
