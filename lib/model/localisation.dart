// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pharmagps/model/Pharmacie.dart';

// class pour obtenir la localisation et les pharmacies
class Localisation extends ChangeNotifier {
  LatLng _position = LatLng(9.6412, -13.5784);
  LatLng get position => _position;
  final List<LatLng> _positions = [];
  List<LatLng> get positions => _positions;
  final List<int> _ids = [];
  List<int> get ids => _ids;
  List<Pharmacie> pharmacies = [];
  StreamSubscription<Position>? streamSubscription;
  Localisation() {
    ChargerLocalisation();
  }
  // ignore: non_constant_identifier_names
  Future<void> ChargerLocalisation() async {
    bool? serviceLocalisation = await Geolocator.isLocationServiceEnabled();
    if (serviceLocalisation == false) {
      return;
    }
    LocationPermission? permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    streamSubscription =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          nouvellePosition(LatLng(position.latitude, position.longitude));
        });
    await loadPharmacy();
    notifyListeners();
  }

  void nouvellePosition(LatLng latlng) {
    _position = latlng;
  }

  Future<void> loadPharmacy() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/pharmacies/get');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        _positions.clear();
        pharmacies.clear();
        ids.clear();
        for (var pharmacy in jsonList) {
          final lat = (pharmacy['latitude'] as num).toDouble();
          final lon = (pharmacy['longitude'] as num).toDouble();
          final id = pharmacy['id'] as int;
          _positions.add(LatLng(lat, lon));
          Pharmacie pharma = Pharmacie();
          pharma.position = LatLng(lat, lon);
          pharma.name = pharmacy['name'];
          print(pharmacy);
          pharmacies.add(pharma);
          _ids.add(id);
        }
      } else {}
    } catch (e) {
      //
    }
    notifyListeners();
  }

  Future<void> ajouterPharmacie(LatLng ltng, String nom) async {
    final url = Uri.parse(
      "http://10.0.2.2:8080/api/pharmacies/post?longitude=${ltng.longitude}&latitude=${ltng.latitude}&name=$nom",
    );
    final reponse = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (reponse.statusCode == 200) {
      loadPharmacy();
    }
  }

  Future<void> supprimerPharmacie(int id) async {
    final url = Uri.parse("http://10.0.2.2:8080/api/pharmacies/del?id=$id");
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      int index = ids.indexOf(id);
      if (index != -1) {
        positions.removeAt(index);
        ids.removeAt(index);
        pharmacies.removeAt(index);
        notifyListeners();
      }
    }
  }
}
