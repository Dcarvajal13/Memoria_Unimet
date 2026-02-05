import 'dart:async';
import 'package:flutter/material.dart';
import '../models/carta_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JuegoMemoria extends StatefulWidget {
  const JuegoMemoria({super.key});

  @override
  State<JuegoMemoria> createState() => _JuegoMemoriaState();
}

class _JuegoMemoriaState extends State<JuegoMemoria> {
  // 1. Baraja de cartas
  List<Carta> cartas = [];
  
  // 2. Variables de control
  List<int> cartasVolteadasIndex = []; 
  bool bloqueado = false; 
  int intentos = 0;
  int mejorRecord = 0;

  @override
  void initState() {
    super.initState();
    _cargarRecord();
    _inicializarJuego();
    
  }

  Future<void> _cargarRecord() async {
    print("📢 INTENTANDO CARGAR RÉCORD...");
    final prefs = await SharedPreferences.getInstance();
    int? recordGuardado = prefs.getInt('record');
    print("📢 VALOR ENCONTRADO EN MEMORIA: $recordGuardado");
    if (recordGuardado != null) {
      setState(() {
        mejorRecord = recordGuardado;
      });
    }

    setState(() {
      mejorRecord = prefs.getInt('record') ?? 0;
    });
  }

  Future<void> _actualizarRecord() async {
    final prefs = await SharedPreferences.getInstance();
    if (mejorRecord == 0 || intentos < mejorRecord) {
      print("💾 ¡NUEVO RÉCORD! GUARDANDO EL NUMERO: $intentos");
      await prefs.setInt('record', intentos);
      setState(() {
        mejorRecord = intentos;
      });      
    }else {
      print("❌ No es récord. Hiciste $intentos y el récord es $mejorRecord");
    }
  }


  void _inicializarJuego() {
    List<String> emojis = [
      '🦁', '🦁', '🐶', '🐶', '🐱', '🐱',
      '🐭', '🐭', '🐹', '🐹', '🐰', '🐰',
      '🦊', '🦊', '🐻', '🐻', '🐼', '🐼',
      '🐨', '🐨', '🐯', '🐯', '🦄', '🦄',
      '🐸', '🐸', '🐙', '🐙', '🦋', '🦋',
      '🐢', '🐢', '🐬', '🐬', '🐡', '🐡',
    ];
    
    // Solo tomamos 18 pares (36 cartas)
    emojis.shuffle();
    List<String> itemsJuego = emojis.sublist(0, 36); 
    
    setState(() {

      cartas = List.generate(36, (index) {
      return Carta(id: index, contenido: itemsJuego[index]);
    });
    });
  }

  void _onCartaTap(int index) {
    if (bloqueado || cartas[index].estaVolteada || cartas[index].encontrada) {
      return;
    }

    setState(() {
      cartas[index].estaVolteada = true;
      cartasVolteadasIndex.add(index);
    });

    if (cartasVolteadasIndex.length == 2) {
      bloqueado = true;
        setState(() {
          intentos += 1;
        });
      _verificarPareja();
    }
  }

  void _verificarPareja() {
    int index1 = cartasVolteadasIndex[0];
    int index2 = cartasVolteadasIndex[1];

    if (cartas[index1].contenido == cartas[index2].contenido) {
      setState(() {
        cartas[index1].encontrada = true;
        cartas[index2].encontrada = true;
        bloqueado = false;
        cartasVolteadasIndex.clear();
      });
      _verificarVictoria(); 
    } else {
      Timer(const Duration(milliseconds: 1000), () {
        setState(() {
          cartas[index1].estaVolteada = false;
          cartas[index2].estaVolteada = false;
          bloqueado = false;
          cartasVolteadasIndex.clear();
        });
      });
    }
  }

  void _verificarVictoria() {
    bool ganaste = cartas.every((carta) => carta.encontrada);
    if (ganaste) {
      _actualizarRecord();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("¡Felicidades! 🎉"),
          content: const Text("Has encontrado todas las parejas."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                _reiniciarJuego(); 
              },
              child: const Text("Jugar de nuevo"),
            ),
          ],
        ),
      );
    }
  }

  void _reiniciarJuego() {
    setState(() {
      _inicializarJuego(); 
      bloqueado = false;
      cartasVolteadasIndex.clear();
      intentos = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Memoria UNIMET',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[900], 
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reiniciarJuego,
          ),
        ],
      ),
      // USAMOS UN STACK PARA LAS CAPAS
      body: Stack(
        children: [
          // CAPA 1: EL FONDO (Siempre ocupa toda la pantalla)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  // Usamos tu imagen exacta
                  image: AssetImage('assets/fondomicro.png'),
                  fit: BoxFit.cover, // Estira la imagen para cubrir todo sin deformar
                ),
              ),
            ),
          ),
          
          // CAPA 2: EL JUEGO (Centrado encima del fondo)
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column( // <--- NUEVO: Column para poner texto arriba y cartas abajo
                  mainAxisSize: MainAxisSize.min, // Para que se ajuste al contenido
                  children: [
                    // --- MARCADOR DE INTENTOS Y RECORD 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _infoTag('Intentos: $intentos'),
                        const SizedBox(width: 20),
                        _infoTag('Record: $mejorRecord'),
                      ],
                    ),

                    const SizedBox(height: 20), // Espacio entre texto y cartas

                    // --- GRILLA DE CARTAS ---
                    Flexible( // Flexible es necesario dentro de Column
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 4,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: cartas.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _onCartaTap(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cartas[index].estaVolteada || cartas[index].encontrada
                                    ? Colors.white
                                    : Colors.brown[300], // Un marrón un poco más claro
                                borderRadius: BorderRadius.circular(12), // Bordes más redondos
                                border: Border.all(
                                  color: Colors.brown[900]!, 
                                  width: 2
                                ),
                                // NUEVO: Sombra para dar efecto 3D
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  cartas[index].estaVolteada || cartas[index].encontrada
                                      ? cartas[index].contenido
                                      : '',
                                  style: const TextStyle(fontSize: 34), // Emoji más grande
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTag(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87
        ),
      ),
    );
  }
}