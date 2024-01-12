// firestore_islemler.dart
import 'dart:async';

// import 'dart:math';
// import 'package:latlong2/latlong.dart' as Ltlng;

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreIslemler {
  final CollectionReference binalar =
      FirebaseFirestore.instance.collection('Binalar');

  Stream<List<Map<String, dynamic>>> binaGetir(String durum) {
    return binalar
        .where('hasarDurumu', isEqualTo: durum)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'documentId': doc.id,
          'binaAdi': doc['binaAdi'] ?? '',
          'hasarDurumu': doc['hasarDurumu'] ?? '',
          'konum': doc['konum'] ?? '',
        };
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> konumGetir() async {
    var snapshots = await binalar.snapshots().first;

    List<Map<String, dynamic>> resultList = snapshots.docs.map((doc) {
      List<double> konumTurDonusumDizi = [];
      List<dynamic> konumDiziString = doc['konum'].split(',');
      for (var element in konumDiziString) {
        konumTurDonusumDizi.add(double.parse(element));
      }
      return {
        'hasarDurumu': doc['hasarDurumu'] ?? '',
        'konum': konumTurDonusumDizi,
      };
    }).toList();

    return resultList;
  }

  Future<void> veriEklemeAdd({
    required String binaAdi,
    required String hasarDurumu,
    required String konum,
  }) async {
    try {
      Map<String, dynamic> _eklenecekUser = {
        'binaAdi': binaAdi,
        'hasarDurumu': hasarDurumu,
        'konum': konum,
      };

      await binalar.add(_eklenecekUser);
      print('Veri başarıyla eklendi.');
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }
}
