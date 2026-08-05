import 'package:flutter/material.dart';

class FightTab extends StatelessWidget {
  const FightTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. BARRA SUPERIORE (Icona Filtro)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black, size: 28),
              onPressed: () {
                // Logica per aprire la schermata/modal dei filtri
              },
            ),
          ),
        ),

        // 2. CARD DEL PROFILO PRINCIPALE
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0), // Angoli arrotondati della card
              child: Stack(
                children: [
                  // IMMAGINE DI SFONDO DEL PROFILO
                  Positioned.fill(
                    child: Image.asset(
                      'assets/chuck.jpg', // Ricordati di aggiungere la foto negli assets
                      fit: BoxFit.cover,
                    ),
                  ),

                  // GRADIENTE SCURO PER DARE LEGGIBILITÀ AL TESTO
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // BARRE DELLE STORIE (In alto nella card)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        _buildStoryBar(isActive: true),
                        const SizedBox(width: 6),
                        _buildStoryBar(isActive: false),
                        const SizedBox(width: 6),
                        _buildStoryBar(isActive: false),
                        const SizedBox(width: 6),
                        _buildStoryBar(isActive: false),
                      ],
                    ),
                  ),

                  // INFORMAZIONI PROFILO (In basso nella card)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nome, Età e Tasto Info (i)
                        Row(
                          children: [
                            const Text(
                              'Chuck',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '86',
                              style: TextStyle(
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
                                onPressed: () {
                                  // Logica per visualizzare i dettagli completi del profilo
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Bio / Descrizione
                        const Text(
                          'Non sto cercando un "match".\nSto cercando qualcuno che sopravviva al riscaldamento.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tag e Distanza
                        Row(
                          children: [
                            _buildTag('Karate'),
                            const SizedBox(width: 8),
                            _buildTag('MMA'),
                            const SizedBox(width: 8),
                            _buildTag('...'),
                            const Spacer(),
                            // Distanza con icona Pin
                            const Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.black, size: 16),
                                SizedBox(width: 2),
                                Text(
                                  'a 0 metri da te',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. PULSANTI D'AZIONE (Rifiuta / Accetta)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsante Rifiuta (Palmo Rosso)
            _buildActionButton(
              color: Colors.red,
              icon: Icons.front_hand_outlined,
              onTap: () {
                print('Utente Rifiutato');
              },
            ),
            const SizedBox(width: 40),
            // Pulsante Accetta (Pugno Verde)
            _buildActionButton(
              color: Colors.lightGreenAccent.shade400,
              icon: Icons.sports_mma,
              iconColor: Colors.black,
              onTap: () {
                print('Utente Accettato!');
              },
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // Barrette delle Storie (In alto nella card)
  Widget _buildStoryBar({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // Badge/Tag scuri (es. Karate, MMA)
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

  // Pulsanti tondi per lo swipe manuale (Accetta / Rifiuta)
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
              color: color.withOpacity(0.4),
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