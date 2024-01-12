import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hasar_konut/deprem_kayit.dart';
import 'package:hasar_konut/firestone_islemler.dart';
import 'package:latlong2/latlong.dart' as Ltlng;

class BinaListeleme extends StatefulWidget {
  const BinaListeleme({super.key});

  @override
  State<BinaListeleme> createState() => _BinaListelemeState();
}

class _BinaListelemeState extends State<BinaListeleme> {
  final FirestoreIslemler _firestoreIslemler = FirestoreIslemler();
  String durum = "";
  List<Marker> markers = [];
  List<Ltlng.LatLng> polygonPoints = [];
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade300,
      appBar: AppBar(
        title: Text("Konut Listeleme"),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        durum = "Ağır Hasarlı";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Buton rengi
                    ),
                    child: Text(
                      "Ağır",
                      style: TextStyle(
                        color: Colors.black, // Metin rengi
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        durum = "Orta Hasarlı";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange, // Buton rengi
                    ),
                    child: Text(
                      "Orta Hasarlı",
                      style: TextStyle(
                        color: Colors.black, // Metin rengi
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        durum = "Hasarsız";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green, // Buton rengi
                    ),
                    child: Text(
                      "Hasarsız",
                      style: TextStyle(
                        color: Colors.black, // Metin rengi
                      ),
                    ),
                  ),
                ),
              ],
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreIslemler.binaGetir(durum),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> binalar = snapshot.data!;
                  return Column(
                    children: binalar
                        .map((bina) => Card(
                              child: ListTile(
                                title: Text(bina['binaAdi']),
                              ),
                            ))
                        .toList(),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.library_add, color: Colors.purple),
            label: 'Ana Sayfa',
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

          if (_currentIndex == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DepremKayit()),
            );
          }
        },
      ),
    );
  }
}
