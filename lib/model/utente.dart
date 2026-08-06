class Utente {
  final String id;
  final String email;
  final String nome;
  final String cognome;
  final String descrizione;
  final int altezza;
  final int peso;
  final String dataNascita;
  final List<String> arti;
  final List<String> imgs;
  final double? lat;
  final double? lon;

  const Utente({
    required this.id,
    required this.email,
    required this.nome,
    required this.cognome,
    required this.descrizione,
    required this.altezza,
    required this.peso,
    required this.dataNascita,
    this.lat,
    this.lon,
    this.arti = const [],
    this.imgs = const [],
  });
}