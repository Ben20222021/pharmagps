import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmagps/constants/dimension.dart';
import 'package:http/http.dart' as http show post;
import 'package:pharmagps/pages/login.dart';

// Interface pour le login
class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<StatefulWidget> createState() => SIgIninState();
}

class SIgIninState extends State<Signin> {
  Future<void> register(
    String username,
    String password,
    BuildContext context,
  ) async {
    final body = {'username': username, 'password': password};
    final url = Uri.parse("http://10.0.2.2:8080/api/auth/register");
    final reponse = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (context.mounted) return;
    if (reponse.statusCode == 200) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text("Compte crée avec succes"),
          actions: [Icon(Icons.check_circle, color: Colors.green)],
        ),
      );
      await Future.delayed(Duration(seconds: 2));
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      Navigator.pop(context);
    } else {
      setState(() {
        usernameError = buildErrorText("Erreur lors de la création du compte");
      });
    }
  }

  Text passwordError = Text("");
  Text usernameError = Text("");
  @override
  Widget build(BuildContext context) {
    TextEditingController nom = TextEditingController();
    TextEditingController motDePasse = TextEditingController();
    TextEditingController confirmationMotDePasse = TextEditingController();
    void connexion() {
      if (nom.text.isEmpty) {
        setState(() {
          passwordError = buildErrorText("");
          usernameError = buildErrorText(
            "Le nom d'utilisateur ne doit pas etre null",
          );
        });
      } else if (motDePasse.text.isEmpty || motDePasse.text.length < 8) {
        setState(() {
          usernameError = buildErrorText("");
          passwordError = buildErrorText(
            "Le mot de passe doit contenir au moins 8 caractères",
          );
        });
      } else if (motDePasse.text != confirmationMotDePasse.text) {
        setState(() {
          usernameError = buildErrorText("");
          passwordError = buildErrorText(
            "Les deux mot de passe sont differents",
          );
        });
      } else {
        register(nom.text, motDePasse.text, context);
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(height: 60),
            Center(child: buildHeader(context)),
            buildForm(
              usernameError,
              passwordError,
              connexion,
              context,
              nom,
              motDePasse,
              confirmationMotDePasse,
            ),
          ],
        ),
      ),
    );
  }
}

//constructionb du formulaire
Container buildForm(
  Text usernameError,
  passwordError,
  void Function() connexion,
  BuildContext context,
  TextEditingController nom,
  TextEditingController motDePasse,
  TextEditingController confirmationMotDePasse,
) => Container(
  width: 350,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(50),
    border: Border.all(style: BorderStyle.solid, color: Colors.white),
  ),
  child: Column(
    children: [
      Text(
        "Inscription",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      buildField(context, "Nom", Icon(Icons.person), nom, false),
      SizedBox(height: 5),
      buildField(context, "Mot de passe", Icon(Icons.lock), motDePasse, true),
      SizedBox(height: 5),
      buildField(
        context,
        "Confirmation de Mot de passe",
        Icon(Icons.lock),
        confirmationMotDePasse,
        true,
      ),
      SizedBox(height: 5),
      buildButton(0, connexion, "Valider"),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Vous avez deja un compte ?"),
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
            child: Text("Se connecter", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      SizedBox(height: 5),
      usernameError,
      passwordError,
    ],
  ),
);
// construction de l'zentete
SafeArea buildHeader(BuildContext context) {
  return SafeArea(
    child: Container(
      width: getPhoneWidth(context) * 0.6,

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(style: BorderStyle.solid, color: Colors.white),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle_outlined, size: 50),
          Text(
            "Bienvenue",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}

SafeArea buildField(
  BuildContext context,
  String hint,
  Icon icon,
  TextEditingController controller,
  bool estMotdePasse,
) {
  return SafeArea(
    child: Container(
      width: getPhoneWidth(context) * 0.7,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: BoxBorder.all(
          color: Colors.black,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: TextField(
        obscureText: estMotdePasse,
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          icon: icon,
        ),
      ),
    ),
  );
}

// Construction de button générique
TextButton buildButton(int mode, void Function() onPressed, String contenue) {
  return TextButton(
    onPressed: onPressed,
    style: mode == 0
        ? TextButton.styleFrom(
            backgroundColor: Colors.green,
            fixedSize: Size(150, 20),
          )
        : TextButton.styleFrom(
            backgroundColor: Colors.blue,
            fixedSize: Size(150, 20),
          ),
    child: Text(
      contenue,
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// Contruction des widgets text personnalisé pour les erruers de saisies
Text buildErrorText(String error) {
  return Text(error, style: TextStyle(color: Colors.red));
}
