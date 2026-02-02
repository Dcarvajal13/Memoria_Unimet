import 'package:flutter/material.dart';
import '../models/carta_model.dart'; // Importamos el modelo que acabas de crear

class JuegoMemoria extends StatefulWidget {
  const JuegoMemoria({super.key});

  @override
  State<JuegoMemoria> createState() => _JuegoMemoriaState();
}

class _JuegoMemoriaState extends State<JuegoMemoria> {
  List<Carta> cartas = [];
  
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
                setState(() {
                  // Volteo básico para probar (luego pondremos la lógica completa)
                  cartas[index].estaVolteada = !cartas[index].estaVolteada;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: cartas[index].estaVolteada ? Colors.white : Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                child: Center(
                  child: Text(
                    cartas[index].estaVolteada ? cartas[index].contenido : '',
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