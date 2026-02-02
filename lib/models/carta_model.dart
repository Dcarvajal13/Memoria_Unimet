class Carta {
  final int id;
  final String contenido; 
  bool estaVolteada;
  bool encontrada;

  Carta({
    required this.id,
    required this.contenido,
    this.estaVolteada = false,
    this.encontrada = false,
  });
}