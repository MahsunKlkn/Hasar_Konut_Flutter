import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hasar_konut/bina_listele.dart';
import 'package:hasar_konut/firestone_islemler.dart';
import 'package:latlong2/latlong.dart' as Ltlng;

class DepremKayit extends StatefulWidget {
  const DepremKayit({Key? key}) : super(key: key);

  @override
  State<DepremKayit> createState() => _DepremKayitState();
}

class _DepremKayitState extends State<DepremKayit> {
  FirestoreIslemler firestoreIslemler = FirestoreIslemler();

  List<Polygon> poligonlar = [];
  List<Ltlng.LatLng> polygonPoints = [];
  List<String> hasarDurum = ['Ağır Hasarlı', 'Orta Hasarlı', 'Hasarsız'];
  String dropdownValue = 'Ağır Hasarlı';
  TextEditingController binaAdiController = TextEditingController();
  int _currentIndex = 0;
  double binaGenislik = 0.005;
  double binaYukseklik = 0.01;

  @override
  void initState() {
    super.initState();
    _fetchPolygons();
  }

  Future<void> _fetchPolygons() async {
    List<Polygon> polygons = await polygonlarrrr();
    setState(() {
      poligonlar = polygons;
    });
  }

  @override
  Widget build(BuildContext context) {
    double ekranYukseklik = MediaQuery.of(context).size.height;
    double ekranGenislik = MediaQuery.of(context).size.width;
    double haritaYukseklik = ekranYukseklik / 2;

    return Scaffold(
      backgroundColor: Colors.blue.shade300,
      appBar: AppBar(
        title: Center(
          child: Text(
            'Deprem Konut Kontrol',
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: haritaYukseklik,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: FlutterMap(
                    options: MapOptions(
                      center: Ltlng.LatLng(38.329788, 38.447503),
                      zoom: 9.2,
                      onTap: haritadaTiklama,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      PolygonLayer(
                        polygons: poligonlar +
                            [
                              Polygon(
                                points: polygonPoints,
                                color: Colors.blue,
                                isFilled: true,
                              ),
                            ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: ekranGenislik / 2,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: binaAdiController,
                    decoration: InputDecoration(
                      labelText: 'Bina Adı',
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: hasarDurum.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: Text('Hasar Durumu Seçiniz'),
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24.0,
                    isExpanded: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: ekranGenislik / 3,
              child: ElevatedButton(
                onPressed: () {
                  if (polygonPoints.isNotEmpty &&
                      dropdownValue.isNotEmpty &&
                      binaAdiController.text.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Hayır"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              firestoreIslemler.veriEklemeAdd(
                                binaAdi: binaAdiController.text,
                                hasarDurumu: dropdownValue,
                                konum: formatLatLngList(polygonPoints),
                              );
                              print('Bina Adı: ${binaAdiController.text}');
                              print('Seçilen Hasar Durumu: $dropdownValue');
                              print('Polygon Points: $polygonPoints');
                              setState(() {
                                _fetchPolygons();
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text("Evet"),
                          ),
                        ],
                        title: const Text("Kaydetme İşlemi"),
                        contentPadding: const EdgeInsets.all(20.0),
                        content: const Text(
                          "Kaydetmek istediğinize emin misiniz?",
                        ),
                      ),
                    );
                  } else {
                    print(
                      'Lütfen haritaya tıklayın, hasar durumu ve bina adını girin',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text("Kaydet", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.library_add, color: Colors.purple),
            label: 'Hasar Kayıt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.purple),
            label: 'Hasar Gözlem',
          ),
        ],
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.purple,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (_currentIndex == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BinaListeleme()),
            );
          }
        },
      ),
    );
  }

  void haritadaTiklama(TapPosition tapPosition, Ltlng.LatLng tiklananNokta) {
    setState(() {
      double yarimGenislik = 0.000099;
      double yarimYukseklik = 0.000099;

      Ltlng.LatLng solUst = Ltlng.LatLng(
        tiklananNokta.latitude + yarimYukseklik,
        tiklananNokta.longitude - yarimGenislik,
      );
      Ltlng.LatLng sagUst = Ltlng.LatLng(
        tiklananNokta.latitude + yarimYukseklik,
        tiklananNokta.longitude + yarimGenislik,
      );
      Ltlng.LatLng solAlt = Ltlng.LatLng(
        tiklananNokta.latitude - yarimYukseklik,
        tiklananNokta.longitude - yarimGenislik,
      );
      Ltlng.LatLng sagAlt = Ltlng.LatLng(
        tiklananNokta.latitude - yarimYukseklik,
        tiklananNokta.longitude + yarimGenislik,
      );

      polygonPoints = [solUst, sagUst, sagAlt, solAlt];
    });

    print('Sol Üst: ${parseLatLng(polygonPoints[0])}');
    print('Sağ Üst: ${parseLatLng(polygonPoints[1])}');
    print('Sağ Alt: ${parseLatLng(polygonPoints[2])}');
    print('Sol Alt: ${parseLatLng(polygonPoints[3])}');
  }

  String parseLatLng(Ltlng.LatLng latLng) {
    return '${latLng.latitude},${latLng.longitude}';
  }

  String formatLatLngList(List<Ltlng.LatLng> points) {
    List<String> formattedPoints = [];
    for (Ltlng.LatLng point in points) {
      formattedPoints.add('${point.latitude},${point.longitude}');
    }
    return formattedPoints.join(',');
  }

  Future<List<Polygon>> polygonlarrrr() async {
    List<Map<String, dynamic>> result = await firestoreIslemler.konumGetir();
    List<Polygon> bosDizi = [];
    if (result.isNotEmpty) {
      for (int i = 0; i < result.length; i++) {
        Map<String, dynamic> values = result[i];

        String hasarDurumu = values['hasarDurumu'];
        List<dynamic> coordinatesList = values['konum'];
        bosDizi.add(Polygon(
          points: [
            Ltlng.LatLng(coordinatesList[0], coordinatesList[1]),
            Ltlng.LatLng(coordinatesList[2], coordinatesList[3]),
            Ltlng.LatLng(coordinatesList[4], coordinatesList[5]),
            Ltlng.LatLng(coordinatesList[6], coordinatesList[7]),
          ],
          color: renkBelirle(hasarDurumu),
          isFilled: true,
        ));
      }
      return bosDizi;
    } else {
      return bosDizi;
    }
  }

  Color renkBelirle(String durum) {
    if (durum == "Ağır Hasarlı") {
      return Colors.redAccent;
    } else if (durum == "Orta Hasarlı") {
      return Colors.amberAccent;
    } else if (durum == "Hasarsız") {
      return Colors.greenAccent;
    } else {
      return Colors.brown;
    }
  }
}
