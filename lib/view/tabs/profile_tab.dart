import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definizione dei colori per il tema scuro
    const backgroundColor = Color(0xFF121212); // Grigio quasi nero per lo sfondo principale
    const cardColor = Color(0xFF1E1E1E); // Grigio leggermente più chiaro per i contenitori
    const textColor = Colors.white; // Bianco per il testo principale
    const subTextColor = Colors.white70; // Bianco opaco per il testo secondario

    return Scaffold(
      backgroundColor: backgroundColor, // Imposta lo sfondo scuro
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Titolo principale
              const Text(
                'Il tuo profilo:',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor, // Testo bianco
                ),
              ),
              const SizedBox(height: 20),

              // Avatar con bordo rosso
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red, // Mantiene il bordo rosso
                    width: 4.0,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150/000000/FFFFFF?text=Gino', // Immagine segnaposto scura
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nome ed età
              const Text(
                'Gino, 22',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor, // Testo bianco
                ),
              ),
              const SizedBox(height: 24),

              // Pulsanti azione: Statistiche e Modifica profilo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistiche',
                    textColor: textColor,
                    onTap: () {
                      // Azione pulsante Statistiche
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.edit_note_rounded,
                    label: 'Modifica\nprofilo',
                    textColor: textColor,
                    onTap: () {
                      // Azione pulsante Modifica profilo
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sezione Recensioni
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Recensioni:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor, // Testo bianco
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Contenitore Recensioni
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: cardColor, // Sfondo scuro del contenitore
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Ombra più scura
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Prima recensione
                    _buildReviewItem(
                      avatarUrl: '', // Icona di default
                      name: 'Utente1',
                      rating: 0, // 0 stelle piene
                      comment:
                      'buon combattente, abbiamo avuto una bella sessione di sparring',
                      nameColor: textColor,
                      commentColor: subTextColor,
                      starEmptyColor: textColor, // Stelle vuote bianche
                    ),
                    const Divider(height: 24, thickness: 1, color: Colors.white24), // Divisore scuro

                    // Seconda recensione
                    _buildReviewItem(
                      avatarUrl: 'https://via.placeholder.com/50/FFFFFF/000000?text=C', // Immagine segnaposto chiara
                      name: 'Chuck',
                      rating: 1, // 1 stella piena
                      comment: 'debole...',
                      nameColor: textColor,
                      commentColor: subTextColor,
                      starEmptyColor: textColor, // Stelle vuote bianche
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper per i pulsanti tondi in alto (modificato per il tema scuro)
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
                color: Colors.red, // Mantiene il bordo rosso
                width: 3.0,
              ),
            ),
            child: Icon(
              icon,
              size: 36,
              color: Colors.red, // Mantiene l'icona rossa
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor, // Testo adattato
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper per gli elementi della lista recensioni (modificato per il tema scuro)
  Widget _buildReviewItem({
    required String avatarUrl,
    required String name,
    required int rating,
    required String comment,
    required Color nameColor,
    required Color commentColor,
    required Color starEmptyColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar Recensore (adattato per lo sfondo scuro)
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white10, // Grigio molto scuro
          backgroundImage:
          avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl.isEmpty
              ? const Icon(Icons.person_outline, color: Colors.white70) // Icona chiara
              : null,
        ),
        const SizedBox(width: 12),

        // Dettagli Recensione
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: nameColor, // Nome bianco
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Stelle di valutazione (totale 6)
                  Row(
                    children: List.generate(6, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        size: 18,
                        // Stelle piene gialle, stelle vuote bianche
                        color: index < rating ? Colors.yellow.shade700 : starEmptyColor,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment,
                style: TextStyle(
                  fontSize: 13,
                  color: commentColor, // Commento bianco opaco
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}