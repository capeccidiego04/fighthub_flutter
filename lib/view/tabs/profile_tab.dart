import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controller/controllore_auth.dart';
import '../../controller/controllore_db.dart';
import '../../model/utente.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final DatabaseService controllore = DatabaseService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<Utente?>? _userFuture;

  @override
  void initState() {
    super.initState();
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      _userFuture = controllore.getUtente(currentUser.uid);
    }
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
              // 1. PageView per scorrere le foto con supporto al Zoom
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
                      // Tap a destra per andare avanti, tap a sinistra per andare indietro
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

              // 2. Lineette indicatrici in alto (stile Tinder/Instagram)
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

              // 3. Tasto di chiusura (X) in alto a sinistra
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
    const subTextColor = Colors.white70;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FutureBuilder<Utente?>(
          future: _userFuture,
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

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text(
                  'Utente non trovato',
                  style: TextStyle(color: textColor),
                ),
              );
            }

            final user = snapshot.data!;
            final List<String> images = user.imgs;
            final bool hasImage = images.isNotEmpty && images[0].isNotEmpty;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spinge il testo a sinistra e il pulsante a destra
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:[
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
                            if(mounted){
                              Navigator.pushReplacementNamed(context, '/login_screen');
                            }
                          }
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar cliccabile con bordo rosso
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
                        onTap: () {},
                      ),
                      _buildActionButton(
                        icon: Icons.edit_note_rounded,
                        label: 'Modifica\nprofilo',
                        textColor: textColor,
                        onTap: () {},
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
                    child: Column(
                      children: [
                        _buildReviewItem(
                          avatarUrl: '',
                          name: 'Utente1',
                          rating: 0,
                          comment:
                          'buon combattente, abbiamo avuto una bella sessione di sparring',
                          nameColor: textColor,
                          commentColor: subTextColor,
                          starEmptyColor: textColor,
                        ),
                        const Divider(
                          height: 24,
                          thickness: 1,
                          color: Colors.white24,
                        ),
                        _buildReviewItem(
                          avatarUrl:
                          'https://via.placeholder.com/50/FFFFFF/000000?text=C',
                          name: 'Chuck',
                          rating: 1,
                          comment: 'debole...',
                          nameColor: textColor,
                          commentColor: subTextColor,
                          starEmptyColor: textColor,
                        ),
                      ],
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
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white10,
          backgroundImage:
          avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl.isEmpty
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
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: nameColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        size: 18,
                        color: index < rating
                            ? Colors.yellow.shade700
                            : starEmptyColor,
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
                  color: commentColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}