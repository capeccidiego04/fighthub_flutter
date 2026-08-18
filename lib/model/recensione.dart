class Recensione {
  final String recensitoUid;
  final String recensoreUid;
  final String testo;
  final int valutazione;
  final String nome;
  final String foto;

  const Recensione({
    required this.recensitoUid,
    required this.recensoreUid,
    required this.testo,
    required this.valutazione,
    required this.nome,
    required this.foto,
  });
}