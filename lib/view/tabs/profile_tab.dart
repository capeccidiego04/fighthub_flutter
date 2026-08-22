import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controller/controllore_auth.dart';
import '../../controller/controllore_db.dart';
import '../../model/recensione.dart';
import '../../model/utente.dart';
import '../modifica_profilo_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final DatabaseService controllore = DatabaseService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Unici Future che carica contemporaneamente sia l'utente che le sue recensioni
  Future<Map<String, dynamic>>? _profileDataFuture;

  @override
  void initState() {
    super.initState();
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      _profileDataFuture = _caricaDatiProfilo(currentUser.uid);
    }
  }

  void _mostraStatisticheDialog(
      BuildContext context, {
        required double mediaValutazione, // es. 4.2
        required int swipeDownCount,
        required int swipeUpCount,
      }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF121212),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.white12, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titolo
                const Text(
                  'Statistiche',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),

                // Valutazione complessiva
                const Text(
                  'Valutazione complessiva:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // 5 Stelle dinamiche
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < mediaValutazione.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: index < mediaValutazione.round()
                          ? Colors.yellow.shade700
                          : Colors.white38,
                      size: 32,
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Sezione Swipe Down e Swipe Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Swipe down
                    Column(
                      children: [
                        const Text(
                          'Swipe down',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$swipeDownCount',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),

                    // Separatore verticale
                    Container(
                      height: 60,
                      width: 1,
                      color: Colors.white12,
                    ),

                    // Swipe up
                    Column(
                      children: [
                        const Text(
                          'Swipe up:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$swipeUpCount',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tasto Chiudi
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                  child: const Text('Chiudi', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Metodo di supporto per caricare informazioni in parallelo
  Future<Map<String, dynamic>> _caricaDatiProfilo(String uid) async {
    final utente = await controllore.getUtente(uid);

    List<Recensione?> recensioni = [];
    int swipeDown = 0;
    int swipeUp = 0;

    if (utente != null) {
      // Esecuzione in parallelo per ottimizzare i tempi di caricamento
      final risultati = await Future.wait([
        controllore.getRecensioni(utente.id),
        controllore.getSwipeDownRicevuti(utente.id),
        controllore.getSwipeUpRicevuti(utente.id),
      ]);

      recensioni = risultati[0] as List<Recensione?>;
      swipeDown = risultati[1] as int;
      swipeUp = risultati[2] as int;
    }

    return {
      'utente': utente,
      'recensioni': recensioni,
      'swipeDown': swipeDown,
      'swipeUp': swipeUp,
    };
  }

  /// Mostra la galleria full-screen con le lineette indicatrici in alto
  void _apriGalleriaOverlay(BuildContext context, List<String> immagini, int initialIndex) {
    if (immagini.isEmpty) return;

    showDialog(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        final PageController pageController = PageController(initialPage: initialIndex);
        final ValueNotifier<int> currentPage = ValueNotifier<int>(initialIndex);

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 1. PageView per scorrere le foto con supporto allo Zoom
              PageView.builder(
                controller: pageController,
                itemCount: immagini.length,
                onPageChanged: (index) {
                  currentPage.value = index;
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: (details) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      if (details.globalPosition.dx > screenWidth / 2) {
                        if (index < immagini.length - 1) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        }
                      } else {
                        if (index > 0) {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        }
                      }
                    },
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          immagini[index],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 2. Lineette indicatrici in alto
              if (immagini.length > 1)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  child: ValueListenableBuilder<int>(
                    valueListenable: currentPage,
                    builder: (context, currentIndex, child) {
                      return Row(
                        children: List.generate(immagini.length, (index) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: EdgeInsets.only(
                                right: index < immagini.length - 1 ? 6.0 : 0.0,
                              ),
                              decoration: BoxDecoration(
                                color: index == currentIndex
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),

              // 3. Tasto di chiusura (X)
              Positioned(
                top: MediaQuery.of(context).padding.top + (immagini.length > 1 ? 24 : 12),
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Colors.transparent;
    const cardColor = Color(0xFF121212);
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.red),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Errore nel caricamento del profilo',
                  style: TextStyle(color: Colors.redAccent),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!['utente'] == null) {
              return const Center(
                child: Text(
                  'Utente non trovato',
                  style: TextStyle(color: textColor),
                ),
              );
            }

            // Estrazione dati dal FutureBuilder
            final Utente user = snapshot.data!['utente'];
            final List<Recensione?> recensioni = snapshot.data!['recensioni'] ?? [];

            // Rimuoviamo eventuali elementi nulli se la lista accetta Recensione?
            final List<Recensione> recensioniValide = recensioni.whereType<Recensione>().toList();

            final int swipeDownCount = snapshot.data!['swipeDown'] ?? 0;
            final int swipeUpCount = snapshot.data!['swipeUp'] ?? 0;

            final List<String> images = user.imgs;
            final bool hasImage = images.isNotEmpty && images[0].isNotEmpty;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Il tuo profilo:',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 28),
                        tooltip: 'Logout',
                        onPressed: () async {
                          await AuthService().logout();
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/login_screen');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar
                  GestureDetector(
                    onTap: () {
                      if (hasImage) {
                        _apriGalleriaOverlay(context, images, 0);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red,
                          width: 4.0,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.transparent,
                        backgroundImage: hasImage ? NetworkImage(images[0]) : null,
                        child: !hasImage
                            ? const Icon(
                          Icons.person,
                          size: 65,
                          color: Colors.white,
                        )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    '${user.nome} ${user.cognome}, ${controllore.calcolaEta(user.dataNascita)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.bar_chart_rounded,
                        label: 'Statistiche',
                        textColor: textColor,
                        onTap: () {
                          double mediaStelle = 0;
                          if (recensioniValide.isNotEmpty) {
                            double somma = recensioniValide.fold(0, (sum, item) => sum + item.valutazione);
                            mediaStelle = somma / recensioniValide.length;
                          }

                          _mostraStatisticheDialog(
                            context,
                            mediaValutazione: mediaStelle,
                            swipeDownCount: swipeDownCount,
                            swipeUpCount: swipeUpCount,
                          );
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.edit_note_rounded,
                        label: 'Modifica\nprofilo',
                        textColor: textColor,
                        onTap: () async {
                          final haModificato = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModificaProfiloScreen(utente: user),
                            ),
                          );
                          if (haModificato == true) {
                            setState(() {
                              _profileDataFuture = _caricaDatiProfilo(user.id);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recensioni:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Container lista dinamica delle recensioni
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: recensioniValide.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Nessuna recensione presente',
                        style: TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                    )
                        : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recensioniValide.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 24,
                        thickness: 1,
                        color: Colors.white24,
                      ),
                      itemBuilder: (context, index) {
                        return _buildReviewItem(
                          rec: recensioniValide[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red,
                width: 3.0,
              ),
            ),
            child: Icon(
              icon,
              size: 36,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required Recensione rec,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white10,
          backgroundImage:
          rec.foto.isNotEmpty ? NetworkImage(rec.foto) : null,
          child: rec.foto.isEmpty
              ? const Icon(Icons.person_outline, color: Colors.white70)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    rec.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rec.valutazione ? Icons.star : Icons.star_border,
                        size: 18,
                        color: index < rec.valutazione
                            ? Colors.yellow.shade700
                            : Colors.white,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                rec.testo,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}