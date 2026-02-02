import 'package:flutter/material.dart';
import 'screens/juego_memoria.dart'; // Conectamos con la pantalla

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Juego Memoria',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const JuegoMemoria(),
    );
  }
}