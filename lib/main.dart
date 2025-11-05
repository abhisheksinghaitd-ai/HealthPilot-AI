import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifestyle_companion/ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  await Hive.initFlutter();
  await Hive.openBox('login');
  await Hive.openBox('stepsBox');
  await Hive.openBox('items');
  await Hive.openBox('habit');
  await Hive.openBox('savehabit');
  await Hive.openBox('waterintake');
  await Hive.openBox('pref');
  await Hive.openBox('sleep');
  await Hive.openBox('steps');
  await Hive.openBox('day');
  await Hive.openBox('appData');
  await Hive.openBox('LiveSteps');
  await Hive.openBox('achievements');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifestyle Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: UiWidget(),);
      
  
}
}