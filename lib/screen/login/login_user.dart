import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:katalog/screen/admin/setting_admin.dart';
import 'package:katalog/screen/login/register_user.dart';
import 'package:katalog/services/auth/auth.dart';
import 'package:katalog/services/database/dbhelper.dart';
import 'package:katalog/services/tool/custom_decoration.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  TextEditingController _teEmail = TextEditingController();
  TextEditingController _tePass = TextEditingController();

  int warning = 0;

  String validatePassword(String value) {
    if (value.length < 6)
      return 'isi Password';
    else
      return null;
  }

  String validatEmail(String value) {
    if (!EmailValidator.validate(value))
      return 'Isi Email';
    else
      return null;
  }

  _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _snackbar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: Duration(milliseconds: 500), content: Text(title)));
  }

  warningLoginMassage(String warning) {
    AlertDialog errorLogin = AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 24),
        content: ListView(shrinkWrap: true, children: [
          AppBar(
              leading: SizedBox(),
              title: Text("Pemberitahuan"),
              centerTitle: true),
          Container(
              padding: EdgeInsets.all(18), child: Center(child: Text(warning)))
        ]));
    showDialog(context: context, builder: (context) => errorLogin);
  }

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Login"),
              centerTitle: true,
            ),
            key: _key,
            body: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: ListView(shrinkWrap: true, children: [
                      buildTextInputCustomOne(
                          hint: "Email",
                          icon: Icons.email,
                          control: _teEmail,
                          type: TextInputType.emailAddress,
                          val: validatEmail,
                          hidden: false),
                      buildTextInputCustomOne(
                          hint: "password",
                          icon: Icons.lock,
                          control: _tePass,
                          type: TextInputType.visiblePassword,
                          val: validatePassword,
                          hidden: true),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          child: Text("Masuk Sekarang"),
                          onPressed: () async {
                            if (_teEmail.text != "" && _tePass.text != "") {
                              try {
                                await _auth
                                    .signInWithEmailAndPassword(
                                        email: _teEmail.text,
                                        password: _tePass.text)
                                    .then((value) => warningLoginMassage(
                                        "Selamat datang ${_teEmail.text}"));
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  warningLoginMassage(
                                      "Tidak terdapat User dengan Email tersebut");
                                } else if (e.code == 'wrong-password') {
                                  warningLoginMassage(
                                      "Silahkan Cek Email atau Password");
                                }
                              }
                            } else {
                              warningLoginMassage(
                                  "Silahkan isi Email dan Password");
                            }
                          }),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Belum Mempunyai Akun"),
                            ElevatedButton(
                                child: Text("Register"),
                                onPressed: () =>
                                    _pushPage(context, RegisterUser()))
                          ])
                    ]))),
            bottomNavigationBar: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                      child: Text("Masuk sebagai Anonim"),
                      onPressed: () {
                        AuthCustom.signInAnonymous();
                        _snackbar("Login Sebagai Anonim");
                      }),
                  ElevatedButton(
                      child: Text("Admin"),
                      onPressed: () {
                        TextEditingController _teAdmin =
                            TextEditingController();
                        TextEditingController _tePasAdmin =
                            TextEditingController();
                        AlertDialog adminLogin = AlertDialog(
                            contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 18.0),
                            content: ListView(shrinkWrap: true, children: [
                              AppBar(
                                leading: Icon(Icons.admin_panel_settings),
                                title: Text("Login Admin"),
                              ),
                              buildInputAdmin(
                                  controller: _teAdmin,
                                  hint: "Nama Admin",
                                  hidden: false),
                              buildInputAdmin(
                                  controller: _tePasAdmin,
                                  hint: "Password Admin",
                                  hidden: true),
                            ]),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    if (_teAdmin.text != "" &&
                                        _tePasAdmin.text != "") {
                                      print("nama Admin ${_teAdmin.text}");
                                      DatabaseCustom.getData("Admin")
                                          .where('nama',
                                              isEqualTo: _teAdmin.text)
                                          .where('pass',
                                              isEqualTo: _tePasAdmin.text)
                                          .get()
                                          .then((value) {
                                        if (value.docs.isNotEmpty) {
                                          _snackbar(
                                              "Login Sebagai ${_teAdmin.text}");
                                          Navigator.of(context).pop();
                                          print(
                                              "objexk admin ${_teAdmin.text}");
                                          _pushPage(
                                              context,
                                              AdminCostum(
                                                  inAkun: _teAdmin.text));
                                        } else {
                                          _snackbar("nama atau pass salah");
                                          Navigator.of(context).pop();
                                        }
                                      });
                                    } else {
                                      _snackbar("nama atau pass salah");
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text("Masuk"))
                            ]);
                        showDialog(
                            context: context, builder: (_) => adminLogin);
                      })
                ])));
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
          child: Icon(icon, size: 30),
        ),
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
