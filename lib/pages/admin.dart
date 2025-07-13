import 'package:pharmagps/pages/admin/composants.dart';
import 'package:flutter/material.dart';
import 'package:pharmagps/model/localisation.dart';
import 'package:provider/provider.dart';

//creation de la classe principla
final ValueNotifier<int> menu = ValueNotifier(0);

class AdminPage extends StatelessWidget {
  final String admin;
  const AdminPage({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Localisation(),
      child: MapMaker(admin: admin),
    );
  }
}

class MapMaker extends StatefulWidget {
  final String admin;
  const MapMaker({super.key, required this.admin});

  @override
  State<StatefulWidget> createState() {
    return MapMakerState();
  }
}

// creation de la carte
class MapMakerState extends State<MapMaker> {
  final OverlayPortalController controller = OverlayPortalController();
  final OverlayPortalController controllerd = OverlayPortalController();
  final TextEditingController longitude = TextEditingController();
  final TextEditingController latitude = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localisationProvider = context.watch<Localisation>();
    longitude.text = localisationProvider.position.longitude.toString();
    latitude.text = localisationProvider.position.latitude.toString();
    return Scaffold(
      backgroundColor: Colors.white70,

      appBar: buildAppBar(context, widget, localisationProvider),

      body: buildMenu(localisationProvider),

      floatingActionButton: OverlayPortal(
        controller: controller,
        overlayChildBuilder: (context) {
          return Center(
            child: buildAddPharmacyForm(
              latitude,
              longitude,
              TextEditingController(),
              localisationProvider,
              controller,
              context,
            ),
          );
        },
        child: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Colors.blue,
          onPressed: () {
            if (controller.isShowing) {
              controller.hide();
            } else {
              controller.show();
            }
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: AutomaticNotchedShape(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          CircleBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                menu.value = 0;
              },
              icon: Icon(Icons.list, size: 40, color: Colors.white),
            ),
            SizedBox(width: 60),
            IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                menu.value = 1;
              },
              icon: Icon(Icons.map, size: 40, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Contruction de l'appbar
AppBar buildAppBar(
  BuildContext context,
  MapMaker widget,
  Localisation localisationProvider,
) => AppBar(
  title: Text(
    "Session de ${widget.admin}",
    style: TextStyle(color: Colors.black),
  ),
  leading: IconButton(
    style: IconButton.styleFrom(backgroundColor: Colors.red),
    icon: Icon(Icons.logout_sharp, color: Colors.white),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
  actions: [
    IconButton(
      style: IconButton.styleFrom(backgroundColor: Colors.green),
      onPressed: () {
        localisationProvider.ChargerLocalisation();
      },
      icon: const Icon(Icons.refresh, color: Colors.white),
    ),
  ],
);

// fonction pour la navigation entre les pages
ValueListenableBuilder buildMenu(Localisation localisationProvider) =>
    ValueListenableBuilder(
      valueListenable: menu,
      builder: (context, index, _) {
        switch (index) {
          case 0:
            return SingleChildScrollView(
              child: buildPharmacyList(
                localisationProvider.pharmacies,
                context,
                localisationProvider.ids,
                localisationProvider,
              ),
            );
          default:
            return showMap(
              localisationProvider,
              buildMarkers(context, localisationProvider.positions),
            );
        }
      },
    );
