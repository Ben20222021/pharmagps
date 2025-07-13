import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pharmagps/constants/dimension.dart';
import 'package:pharmagps/model/Pharmacie.dart';
import 'package:pharmagps/model/localisation.dart';
import 'package:provider/provider.dart';

// creation de la carte
class Map extends StatefulWidget {
  const Map({super.key});
  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> {
  // varibles globales
  double height = 50;
  Localisation? localisationProvider;
  List<Marker> markers = [];
  List<Polyline> lines = [];
  final MapController _mapController = MapController();
  final TextEditingController _text = TextEditingController();
  List<TextButton> resultatRecherche = [];

  // fonction pour l'obtention du nom(adresse)
  Future<String?> getPlaceNameFromNominatim(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
    );
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'PharmaGps'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'];
      }
    } catch (e) {
      //catch pour ne pas bloquer l"application
    }
    return null;
  }

  // fonction pour obtenir la route
  Future<void> fetchRoute(BuildContext context, arrive) async {
    Pharmacie pharmacie = localisationProvider!.pharmacies.firstWhere((
      pharmacie,
    ) {
      return pharmacie.position == arrive;
    });
    if (lines.isNotEmpty) {
      setState(() {
        lines.clear();
        return;
      });
    }
    final start = [
      localisationProvider!.position.longitude,
      localisationProvider!.position.latitude,
    ]; // lon, lat
    final end = [arrive.longitude, arrive.latitude]; // lon, lat

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${start[0]},${start[1]};${end[0]},${end[1]}?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords =
            data['routes'][0]['geometry']['coordinates'] as List<dynamic>;

        final points = coords
            .map((point) => LatLng(point[1], point[0]))
            .toList();
        final distance = data['routes'][0]['distance'];
        final duration = data['routes'][0]['duration'] / 60;
        String? name = await getPlaceNameFromNominatim(
          arrive.latitude,
          arrive.longitude,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 5),
            content: Column(
              children: [
                Text(pharmacie.name),
                Text(name!),
                Text("Distance : $distance m"),
                Text("Durée de trajet : ${duration.toInt()} minutes"),
              ],
            ),
          ),
        );
        setState(() {
          lines.clear();
          lines.add(
            Polyline(
              points: points,
              color: Colors.blue,
              strokeWidth: 5,
              borderColor: Colors.blue,
              pattern: StrokePattern.dotted(),
            ),
          );
        });
      } else {}
    } catch (e) {
      //catch vide  pour ne pas bloquer l'applica(tion)
    }
  }

  //creation des markers

  List<Marker> buildMarkers(BuildContext context, Localisation localisation) {
    List<Marker> markers = [];
    markers.add(
      Marker(
        point: localisation.position,
        child: Icon(
          Icons.location_on_rounded,
          color: const Color.fromARGB(255, 241, 11, 80),
          size: 20,
        ),
      ),
    );
    for (int i = 0; i < localisation.positions.length; i++) {
      markers.add(
        Marker(
          point: localisation.positions[i],
          child: IconButton(
            onPressed: () {
              fetchRoute(context, localisation.positions[i]);
            },
            icon: Icon(
              Icons.medical_services_rounded,
              color: const Color.fromARGB(255, 60, 138, 9),
              size: 20,
            ),
          ),
        ),
      );
    }
    return markers;
  }

  Future<void> waitPharmacyLoad() async {
    await Future.delayed(Duration(milliseconds: 800));
    if (localisationProvider!.positions.isEmpty) {
      await Future.delayed(Duration(milliseconds: 70));
    }
  }

  @override
  void initState() {
    waitPharmacyLoad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    localisationProvider = context.watch<Localisation>();
    markers = buildMarkers(context, localisationProvider!);

    return Scaffold(
      body: Stack(
        children: [
          // affichage de la carte
          FlutterMap(
            options: MapOptions(
              initialCenter: localisationProvider!.position,
              initialZoom: 13,
              backgroundColor: Colors.black12,
            ),
            mapController: _mapController,
            children: [
              TileLayer(
                // Bring your own tiles
                urlTemplate:
                    'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=Ye6ohyWKi7wwduLyvHOQ',
                userAgentPackageName: 'com.example.pharma_gps',
              ),
              MarkerLayer(markers: markers),
              PolylineLayer(polylines: lines),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {}, // (external)
                  ),
                ],
              ),
            ],
          ),

          //champs de recherche
          Positioned(
            top: 40,
            left: getPhoneWidth(context) * 0.1,
            child: Material(
              child: Container(
                padding: EdgeInsets.all(0),
                width: getPhoneWidth(context) * 0.8,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 5),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            onChanged: (value) {
                              value = value.toLowerCase();
                              List<TextButton> results = [];

                              if (value.isEmpty) {
                                setState(() {
                                  resultatRecherche = [];
                                  height = 50;
                                });
                                return;
                              }
                              List<String> names = [];
                              for (var pharmacie
                                  in localisationProvider!.pharmacies) {
                                if (pharmacie.name.toLowerCase().contains(
                                  value,
                                )) {
                                  if (names.contains(pharmacie.name)) {
                                    continue;
                                  }
                                  names.add(pharmacie.name);
                                  results.add(
                                    TextButton(
                                      onPressed: () async {
                                        _mapController.move(
                                          pharmacie.position,
                                          15,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showMaterialBanner(
                                          MaterialBanner(
                                            content: Text("Recherche terminé"),
                                            actions: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              ),
                                            ],
                                          ),
                                        );
                                        setState(() {
                                          resultatRecherche.clear();
                                          _text.text = "";
                                          height = 50;
                                        });
                                        await Future.delayed(
                                          Duration(milliseconds: 1500),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentMaterialBanner();
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          pharmacie.name,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }

                              setState(() {
                                resultatRecherche = results;
                                height = 50 + results.length * 50;
                              });
                            },

                            controller: _text,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Nom de la pharmacie",
                            ),
                          ),
                        ),
                      ],
                    ),
                    Material(
                      child: Container(
                        width: getPhoneWidth(context) * 0.8,
                        height: resultatRecherche.length * 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(children: resultatRecherche),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(localisationProvider!.position, 16);
        },
        child: Icon(Icons.location_searching_rounded, color: Colors.blue),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom - 1,
                );
              },
              icon: Icon(Icons.zoom_out_map),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                side: BorderSide(color: Colors.white, width: 0),
              ),
              onPressed: () async {
                LatLng plusProche = localisationProvider!.position;
                var distance = 999999999.0;
                for (
                  int i = 0;
                  i < localisationProvider!.positions.length;
                  i++
                ) {
                  if (Geolocator.distanceBetween(
                        localisationProvider!.position.latitude,
                        localisationProvider!.position.longitude,
                        localisationProvider!.positions[i].latitude,
                        localisationProvider!.positions[i].longitude,
                      ) <
                      distance) {
                    distance = Geolocator.distanceBetween(
                      localisationProvider!.position.latitude,
                      localisationProvider!.position.longitude,
                      localisationProvider!.positions[i].latitude,
                      localisationProvider!.positions[i].longitude,
                    );
                    plusProche = localisationProvider!.positions[i];
                  }
                }
                _mapController.move(plusProche, 15);
                fetchRoute(context, plusProche);
              },
              child: Text(
                "Pharmacie la plus proche",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1,
                );
              },
              icon: Icon(Icons.zoom_in_map),
            ),
          ],
        ),
      ),
    );
  }
}
