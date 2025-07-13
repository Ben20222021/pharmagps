import 'package:flutter/material.dart';
import 'package:pharmagps/model/names.dart';
import 'package:pharmagps/pages/introduction.dart';
import 'package:provider/provider.dart';
import 'package:pharmagps/model/localisation.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Localisation()..ChargerLocalisation(),
        ),
        ChangeNotifierProvider(create: (_) => Names()),
        ChangeNotifierProvider(create: (_) => Localisation()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Introduction(),
      debugShowCheckedModeBanner: false,
    );
  }
}
