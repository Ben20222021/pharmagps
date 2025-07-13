import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pharmagps/constants/dimension.dart';
import 'package:pharmagps/model/Pharmacie.dart';
import 'package:pharmagps/model/localisation.dart';

//fonction pour afficher la carte
FlutterMap showMap(
  Localisation localisationProvider,
  List<Marker> markers,
) => FlutterMap(
  options: MapOptions(
    initialCenter: localisationProvider.position,
    initialZoom: 13,
    backgroundColor: Colors.black12,
  ),
  children: [
    TileLayer(
      urlTemplate:
          'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=Ye6ohyWKi7wwduLyvHOQ', // For demonstration only
      userAgentPackageName: 'com.example.app', // Add your app identifier
    ),
    MarkerLayer(markers: markers),
    RichAttributionWidget(
      attributions: [
        TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
      ],
    ),
  ],
);

// function pour creer les markers
List<Marker> buildMarkers(BuildContext ctx, List<LatLng> positions) {
  List<Marker> markers = [];
  for (var element in positions) {
    markers.add(
      Marker(
        point: element,
        child: IconButton(
          onPressed: () {
            showLocationDescription(ctx, element);
          },
          icon: Icon(Icons.location_on, color: Colors.green),
        ),
      ),
    );
  }
  return markers;
}

void showLocationDescription(BuildContext context, LatLng latLng) async {
  String description = "Chargement...";
  try {
    description = await fetchLocationDescription(latLng);
  } catch (e) {
    description = "Erreur: $e";
  }

  showDialog(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Description du lieu"),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Fermer"),
        ),
      ],
    ),
  );
}

// fonction pour afficher la description
Future<String> fetchLocationDescription(LatLng latLng) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}&zoom=18&addressdetails=1',
  );

  try {
    final response = await http.get(
      url,
      headers: {'User-Agent': 'FlutterApp - tonemail@example.com'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'] ?? "Aucune description trouvée";
    } else if (response.statusCode == 404) {
      return "Lieu non trouvé";
    } else {
      return "Erreur lors de la récupération de la description";
    }
  } catch (e) {
    return "Erreur lors de la récupération de la description";
  }
}

// formulaire d'ajout de pharmacies a partir de leur latitude et longitude
Container buildAddPharmacyForm(
  TextEditingController latitude,
  TextEditingController longitude,
  TextEditingController nom,
  Localisation localisation,
  OverlayPortalController controller,
  BuildContext context,
) => Container(
  width: getPhoneWidth(context),
  height: getPhoneHeight(context),
  decoration: BoxDecoration(color: const Color.fromARGB(100, 0, 0, 0)),
  child: Center(
    child: Container(
      height: 400,
      width: 300,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 28, 61, 88),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Positioned(
            child: IconButton(
              onPressed: () {
                controller.hide();
              },
              icon: Icon(Icons.close, color: Colors.red, weight: 60, size: 30),
            ),
          ),
          Positioned(
            top: 10,
            left: 45,
            child: Text(
              "Ajouter une pharmacie",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: 60),
                decorate(buildTextField(nom, "Nom", false)),
                SizedBox(height: 5),
                decorate(buildTextField(latitude, "Latitude", true)),
                SizedBox(height: 5),
                decorate(buildTextField(longitude, "Longitude", true)),
                SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    double? latit = double.tryParse(latitude.text);
                    double? longi = double.tryParse(longitude.text);
                    if (latit == null || longi == null) {
                      return;
                    }
                    localisation.ajouterPharmacie(
                      LatLng(latit, longi),
                      nom.text,
                    );
                    nom.text = "";
                    latitude.text = "";
                    longitude.text = "";
                    controller.hide();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 16, 102, 45),
                  ),
                  child: Text("Ajouter", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);

Container decorate(TextField field) => Container(
  color: Colors.white,
  height: 80,
  width: 160,
  child: Center(child: field),
);

TextField buildTextField(TextEditingController con, String text, bool isNum) =>
    TextField(
      controller: con,
      decoration: InputDecoration(hintText: text, border: InputBorder.none),
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      textAlign: TextAlign.center,
    );

//contruire la liste des pharmacy a partir de leur localisation
Column buildPharmacyList(
  List<Pharmacie> lists,
  BuildContext context,
  List<int> ids,
  Localisation localisation,
) => Column(
  children: [
    SizedBox(height: 4),
    Text(
      "Liste des Pharmacies",
      style: TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(
      height: MediaQuery.of(context).size.height - 200,
      width: 600,
      child: ListView.separated(
        padding: EdgeInsets.all(10),
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemCount: lists.length,
        itemBuilder: (context, index) {
          return buildPharmacyView(
            lists[index],
            localisation,
            ids[index],
            context,
          );
        },
      ),
    ),
  ],
);

//construction du conteneur de pharmacy
Widget buildPharmacyView(
  Pharmacie pharma,
  Localisation localisation,
  int id,
  BuildContext context,
) {
  String nom = pharma.name.isEmpty ? "Inconnue" : pharma.name;
  LatLng ltg = pharma.position;
  return SizedBox(
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 2),
          Text(
            // ignore: unnecessary_null_comparison
            nom,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox.fromSize(size: Size(2, 2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Long:"),
              Text(ltg.longitude.toString()),
              Text(",  Lat:"),
              Text(ltg.latitude.toString()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      fetchLocationDescription(ltg).then((onValue) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("Adresse "),
                              content: Text(onValue),
                            );
                          },
                        );
                      });
                    },
                    icon: Icon(Icons.info, color: Colors.blue),
                  ),
                  Text("Info"),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      localisation.supprimerPharmacie(id);
                    },
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                  Text("Supprimer"),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Future<String?> getLocationNameFromLatLng(LatLng latLng) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latLng.latitude}&lon=${latLng.longitude}&zoom=18&addressdetails=1',
  );

  try {
    final response = await http.get(
      url,
      headers: {'User-Agent': 'FlutterApp (your_email@example.com)'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'] ?? 'Unknown location';
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
