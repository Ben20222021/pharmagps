import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http show post;
import 'package:pharmagps/constants/dimension.dart';
import 'package:pharmagps/pages/admin.dart';
import 'package:pharmagps/pages/introduction.dart';
import 'package:pharmagps/pages/signin.dart';

// Interface pour le login
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  Future<void> login(
    String username,
    String password,
    BuildContext context,
  ) async {
    final Map<String, dynamic> body = {
      'username': username,
      'password': password,
    };
    final url = Uri.parse("http://10.0.2.2:8080/api/auth/login");
    try {
      final reponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (!mounted) return;
      if (reponse.statusCode == 200) {
        setState(() {
          usernameError = buildErrorText("");
          passwordError = buildErrorText("");
        });
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) {
              return AdminPage(admin: username);
            },
          ),
        );
      } else {
        setState(() {
          usernameError = buildErrorText(
            "Nom d'utilisateur ou mot de passe incorrect",
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text("Le serveur n'est pas disponible"),
          actions: [Icon(Icons.error_outline_rounded, color: Colors.red)],
        ),
      );
      await Future.delayed(Duration(seconds: 2));
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    }
  }

  Text passwordError = Text("");
  Text usernameError = Text("");
  @override
  Widget build(BuildContext context) {
    TextEditingController nom = TextEditingController();
    TextEditingController motDePasse = TextEditingController();
    void connexion() {
      if (nom.text.isEmpty) {
        setState(() {
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
      } else {
        usernameError = buildErrorText("");
        passwordError = buildErrorText("");
        login(nom.text, motDePasse.text, context);
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE), // un gris clair alternatif
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(height: 100),
            Center(child: buildHeader(context)),
            buildForm(
              usernameError,
              passwordError,
              connexion,
              context,
              nom,
              motDePasse,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Introduction();
              },
            ),
          );
        },
        child: Icon(Icons.home, color: Colors.blue),
      ),
    );
  }
}

// construction de l'entete
Container buildForm(
  Text usernameError,
  passwordError,
  void Function() connexion,
  BuildContext context,
  TextEditingController nom,
  TextEditingController motDePasse,
) => Container(
  height: 460,
  width: 350,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(50),
    border: Border.all(style: BorderStyle.solid, color: Colors.white),
  ),
  child: Column(
    children: [
      Text(
        "Connexion",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      buildField(context, "Nom", Icon(Icons.person), nom, false),
      SizedBox(height: 5),
      buildField(context, "Mot de passe", Icon(Icons.lock), motDePasse, true),
      SizedBox(height: 5),
      buildButton(0, connexion, "Connexion"),
      SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Pas de compte ?"),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Signin();
                  },
                ),
              );
            },
            child: Text(
              "Créer un compte",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      usernameError,
      passwordError,
    ],
  ),
);
// construction de l'entete
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
          Icon(Icons.account_circle_outlined, size: 60),
          Text(
            "Bon retour",
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
