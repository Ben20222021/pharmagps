import 'package:flutter/material.dart';
import 'package:pharmagps/constants/styles.dart';
import 'package:pharmagps/pages/login.dart';
import 'package:pharmagps/pages/client.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<StatefulWidget> createState() => Page();
}

class Page extends State<Introduction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back, color: Colors.green),
        title: Text("Bienvenue sur PharmaGps", style: headerTextStyle),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [Icon(Icons.celebration, color: Colors.white)],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              Text("PharmaGPS", style: titleTextStyle),
              Text("Localiser les Pharmacies les plus proches de chez vous"),
              SizedBox(height: 20),
              Image.asset("assets/map.png", scale: 0.5),
              SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Login();
                          },
                        ),
                      );
                    },
                    child: Text(
                      "Je suis un administrateur",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Map();
                          },
                        ),
                      );
                    },
                    child: Text(
                      "Consulter les pharmacies",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
