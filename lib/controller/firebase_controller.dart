// import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseExtras {
  Future<bool> isDuplicateUniqueName(String collection,String row,  String rowData) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(collection)
        .where(row, isEqualTo: rowData)
        .get();
    // SI ESTA VACIO QUIERE DECIR QUE NO SE DUPLICO POR LO TANTO FALSO
    // SI DEVUELVE DATOS QUIERE DECIR QUE SI ESTA DUPLICADO
    return query.docs.isNotEmpty;
  }
}
