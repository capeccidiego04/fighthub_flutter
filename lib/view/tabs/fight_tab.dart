import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../controller/controllore_auth.dart';
import '../../controller/controllore_db.dart';
import '../../model/utente.dart';

class FightTab extends StatefulWidget {
  const FightTab({super.key});

  @override
  State<FightTab> createState() => _FightTabState();
}

class _FightTabState extends State<FightTab> {
  final CardSwiperController _swiperController = CardSwiperController();
  final DatabaseService controllore = DatabaseService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  Utente? _utenteCorrente;

  List<Utente> _profiles = [];
  bool _isLoading = true;

  void initState() {
    super.initState();
    // 2. Avvia il caricamento asincrono all'inizializzazione del widget
    _caricaUtenti();
  }

  Future<void> _caricaUtenti() async {
    try {
      final uid = auth.currentUser!.uid;

      final mioProfilo = await controllore.getUtente(uid);
      final utenti = await controllore.getTuttiGliUtenti(uid);

      if (!mounted) return;
      setState(() {
        _utenteCorrente = mioProfilo;
        _profiles = utenti;
        _isLoading = false;
      });
    } catch (e) {
      print('Errore durante il caricamento degli utenti: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      print('Accettato: ${_profiles[previousIndex].nome}');
      controllore.inviaRisposta(from_id: auth.currentUser!.uid, to_id: _profiles[previousIndex].id, tipo: 'LIKE');
    } else if (direction == CardSwiperDirection.left) {
      print('Rifiutato: ${_profiles[previousIndex].nome}');
      controllore.inviaRisposta(from_id: auth.currentUser!.uid, to_id: _profiles[previousIndex].id, tipo: 'PASS');
    }

    if (currentIndex == null) {
      setState(() {
        // pulisci la lista per attivare la schermata "Nessun altro profilo"
        _profiles.clear();
      });
    }

    return true;
  }

  void _showProfileDetails(BuildContext context, Utente profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${profile.nome} ${profile.cognome}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          controllore.calcolaEta(profile.dataNascita),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 24,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.location_on, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          DatabaseService().calcolaDistanza(
                            profile.lat,
                            profile.lon,
                            _utenteCorrente?.lat,
                            _utenteCorrente?.lon,
                          ),
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        profile.imgs.isNotEmpty ? profile.imgs[0] : '',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 250,
                          color: Colors.grey.shade900,
                          child: const Icon(Icons.person, size: 80, color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        profile.descrizione,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sport:',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.arti.map((tag) => _buildDetailTag(tag)).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Peso:  ',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: '${profile.peso.toString()}kg',
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Altezza:  ',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: '${profile.altezza.toString()}cm',
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade600, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_profiles.isEmpty) {
      return const Center(
        child: Text(
          'Nessun utente trovato',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white, size: 28),
              onPressed: () async {
                // Logica per filtri
              },
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CardSwiper(
              controller: _swiperController,
              cardsCount: _profiles.length,
              numberOfCardsDisplayed: _profiles.length < 2 ? _profiles.length : 1,
              onSwipe: _onSwipe,
              padding: EdgeInsets.zero,
              cardBuilder: (context, index, percentX, percentY) {
                if (index < 0 || index >= _profiles.length) {
                  return const SizedBox.shrink();
                }
                final profile = _profiles[index];
                //Passo ValueKey per forzare il reset dello stato ad ogni nuova card
                return _FighterCardWidget(
                  key: ValueKey(profile.id),
                  profile: profile,
                  utenteCorrente: _utenteCorrente!, // <-- AGGIUNGI QUESTA RIGA
                  onInfoTap: () => _showProfileDetails(context, profile),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              color: Colors.red,
              icon: Icons.front_hand_outlined,
              onTap: () {
                _swiperController.swipe(CardSwiperDirection.left);
              },
            ),
            const SizedBox(width: 40),
            _buildActionButton(
              color: Colors.lightGreenAccent.shade400,
              icon: Icons.sports_mma,
              iconColor: Colors.black,
              onTap: () {
                _swiperController.swipe(CardSwiperDirection.right);
              },
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButton({
    required Color color,
    required IconData icon,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 36),
      ),
    );
  }
}

class _FighterCardWidget extends StatefulWidget {
  final Utente profile;
  final Utente utenteCorrente;
  final VoidCallback onInfoTap;


  const _FighterCardWidget({
    super.key,
    required this.profile,
    required this.utenteCorrente,
    required this.onInfoTap,
  });

  @override
  State<_FighterCardWidget> createState() => _FighterCardWidgetState();
}

class _FighterCardWidgetState extends State<_FighterCardWidget> {
  int _currentImageIndex = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void _nextImage() {
    if (widget.profile.imgs.isEmpty) return;
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % widget.profile.imgs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.profile.imgs;
    final hasImages = images.isNotEmpty;
    final user = auth.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    // Protezione per evitare errori se la lista di immagini cambia dinamica o supera i limiti
    if (hasImages && _currentImageIndex >= images.length) {
      _currentImageIndex = 0;
    }

    //clip smussata rettangolare
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: hasImages
                ? Image.network(
              images[_currentImageIndex],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade900,
                child: const Icon(Icons.person, size: 80, color: Colors.white24),
              ),
            )
                : Container(
              color: Colors.grey.shade900,
              child: const Icon(Icons.person, size: 80, color: Colors.white24),
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _nextImage,
            ),
          ),

          if (hasImages && images.length > 1)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: List.generate(images.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < images.length - 1 ? 6.0 : 0.0,
                      ),
                      decoration: BoxDecoration(
                        color: index == _currentImageIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      widget.profile.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DatabaseService().calcolaEta(widget.profile.dataNascita),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.white, size: 26),
                        onPressed: widget.onInfoTap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.profile.descrizione,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 1. I tag delle arti marziali contenuti dentro Wrap
                    Expanded(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: widget.profile.arti
                            .map((tag) => _buildTag(tag))
                            .toList(),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 2. La sezione della posizione (posizione allineata a destra)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          DatabaseService().calcolaDistanza(
                            widget.profile.lat,
                            widget.profile.lon,
                            widget.utenteCorrente.lat,
                            widget.utenteCorrente.lon,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}