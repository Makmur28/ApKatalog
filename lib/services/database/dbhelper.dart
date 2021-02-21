import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseCustom {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
//
  static Future addData({
    String nameUser,
    String imgUser,
    String email,
    String general,
    String public,
    String character,
    String lifestyle,
    String spread,
    String img,
    String textKelas,
    String textOrdo,
    String textFamili,
    String textGenus,
    String textSpecies,
    String textIUCN,
    String source,
    List<String> searchList,
  }) async {
    try {
      CollectionReference database = firestore.collection("Satwa");
      database.add({
        'nameUser': nameUser,
        'imgUser': imgUser,
        'general': general,
        'public': public,
        'character': character,
        'lifestyle': lifestyle,
        'spread': spread,
        'img': img,
        'Kelas': textKelas,
        'Ordo': textOrdo,
        'Famili': textFamili,
        'Genus': textGenus,
        'Species': textSpecies,
        'IUCN': textIUCN,
        'source': source,
        'email': email,
        'search': searchList,
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future updatedata(
    String id, {
    String nameUser,
    String imgUser,
    String email,
    String general,
    String public,
    String character,
    String lifestyle,
    String spread,
    String img,
    String textKelas,
    String textOrdo,
    String textFamili,
    String textGenus,
    String textSpecies,
    String textIUCN,
    String source,
    List<String> searchList,
  }) async {
    try {
      CollectionReference database = firestore.collection("Satwa");
      await database.doc(id).set({
        'nameUser': nameUser,
        'imgUser': imgUser,
        'general': general,
        'public': public,
        'character': character,
        'lifestyle': lifestyle,
        'spread': spread,
        'img': img,
        'Kelas': textKelas,
        'Ordo': textOrdo,
        'Famili': textFamili,
        'Genus': textGenus,
        'Species': textSpecies,
        'IUCN': textIUCN,
        'source': source,
        'email': email,
        'search': searchList,
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//
  static Stream<QuerySnapshot> getDataOneDoc(String table, String where, sub) {
    try {
      Stream snapshot =
          firestore.collection(table).where(where, isEqualTo: sub).snapshots();
      return snapshot;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//
  static Future addDataUser(
      String email, String name, String image, String info) async {
    try {
      CollectionReference database = firestore.collection("User");
      database.add({
        'email': email,
        'username': name,
        'photo': image,
        'keterangan': info,
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//
  static Future updateDataUser(String id,
      {String email, String name, String image, String info}) async {
    try {
      CollectionReference database = firestore.collection("User");
      await database.doc(id).set({
        'email': email,
        'username': name,
        'photo': image,
        'keterangan': info
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//
  static Future addDataItem(String table, String sub, String subInput,
      String title, bool enable) async {
    try {
      CollectionReference database = firestore.collection(table);
      database.add({'$sub': subInput, 'nama': title, 'aktif': enable});
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//
  static CollectionReference getData(String table) {
    try {
      CollectionReference snapshot = firestore.collection(table);
      return snapshot;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//
  static Future updateDataItem(String table, String id,
      {String sub, String subInput, String title, bool enable}) async {
    try {
      CollectionReference database = firestore.collection(table);
      await database
          .doc(id)
          .set({'$sub': subInput, 'nama': title, 'aktif': enable});
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//
  static Future deleteDataItem(String table, String id) async {
    try {
      CollectionReference database = firestore.collection(table);
      await database.doc(id).delete();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<QuerySnapshot> search(String table, String what) {
    return FirebaseFirestore.instance
        .collection(table)
        .where("nama", isEqualTo: what)
        .get();
  }
}
