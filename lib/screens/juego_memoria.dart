import 'dart:async';
import 'package:flutter/material.dart';
import '../models/carta_model.dart'; // Importamos el modelo que acabas de crear

class JuegoMemoria extends StatefulWidget {
  const JuegoMemoria({super.key});

  @override
  State<JuegoMemoria> createState() => _JuegoMemoriaState();
}

class _JuegoMemoriaState extends State<JuegoMemoria> {
  List<Carta> cartas = [];
  List<int> cartasVolteadasIndex = [];
  bool bloqueado = false;
  
  @override
  void initState() {
    super.initState();
    _inicializarJuego();
  }

  void _inicializarJuego() {
    // Banco de imágenes (puedes tener más de 18, no importa)
    List<String> bancoDeItems = [
      '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', 
      '🐻', '🐼', '🐨', '🐯', '🦁', '🐮',
      '🐷', '🐸', '🐵', '🐔', '🐧', '🐦',
      '🦄', '🐙', '🦋' // Aunque sobren, el código de abajo lo arregla
    ];
    
    // VALIDACIÓN IMPORTANTE: 
    // Tomamos exactamente los primeros 18 items para llenar los 36 espacios (18 * 2)
    List<String> itemsJuego = bancoDeItems.take(18).toList(); 
    
    // Creamos las parejas
    List<String> tablero = [...itemsJuego, ...itemsJuego];
    
    // Mezclamos
    tablero.shuffle();

    // Generamos las cartas
    cartas = List.generate(36, (index) {
      return Carta(id: index, contenido: tablero[index]);
    });
  }
  void _onCartaTap(int index) {
    // PROTECCIÓN: Si está bloqueado, ya está volteada o ya se encontró, no hacemos nada
    if (bloqueado || cartas[index].estaVolteada || cartas[index].encontrada) {
      return;
    }

    setState(() {
      cartas[index].estaVolteada = true;
      cartasVolteadasIndex.add(index);
    });

    // Si ya volteamos 2 cartas, verificamos si son iguales
    if (cartasVolteadasIndex.length == 2) {
      bloqueado = true; // Bloqueamos la pantalla para que no toquen una 3ra carta
      _verificarPareja();
    }
  }

  void _verificarPareja() {
    int index1 = cartasVolteadasIndex[0];
    int index2 = cartasVolteadasIndex[1];

    if (cartas[index1].contenido == cartas[index2].contenido) {
      // ¡MATCH! Son iguales 🎉
      setState(() {
        cartas[index1].encontrada = true;
        cartas[index2].encontrada = true;
        
        // Reseteamos para el siguiente turno
        bloqueado = false;
        cartasVolteadasIndex.clear();
      });
    } else {
      // FALLO: No son iguales ❌
      // Esperamos 1 segundo (1000 ms) para que el usuario vea qué cartas eran
      Timer(const Duration(milliseconds: 1000), () {
        setState(() {
          cartas[index1].estaVolteada = false;
          cartas[index2].estaVolteada = false;
          
          // Reseteamos
          bloqueado = false;
          cartasVolteadasIndex.clear();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memoria UNIMET'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6, // 6 columnas obligatorias
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: cartas.length,
          itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // SOLO deja esta línea. Borra el setState que tenías abajo.
              _onCartaTap(index); 
            },
            child: Container(
              decoration: BoxDecoration(
                // CORRECCIÓN: Agregamos "|| cartas[index].encontrada" para que las parejas se queden visibles
                color: cartas[index].estaVolteada || cartas[index].encontrada 
                    ? Colors.white 
                    : Colors.blue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              child: Center(
                // CORRECCIÓN: Lo mismo aquí para mostrar el emoji si ya la encontraste
                child: Text(
                  cartas[index].estaVolteada || cartas[index].encontrada 
                      ? cartas[index].contenido 
                      : '', // Si está tapada, no muestra nada
                  style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}