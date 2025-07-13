// FOnction pour obtenir l'adresse
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> getPlaceNameFromNominatim(double lat, double lon) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
  );
  try {
    final response = await http.get(
      url,
      headers: {
        'User-Agent':
            'YourAppNameHere', // Nominatim requires a user-agent header
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['display_name']; // full address string
    }
  } catch (e) {
    //catch pour ne pas bloquer l"application betement
  }
  return null;
}
