import 'dart:io';

import 'package:flutter/material.dart';
import '../controller/controllore_db.dart';
import 'home_screen.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<File> _immaginiSelezionate = [];
  final ImagePicker _picker = ImagePicker();

  // Controllers per i campi di testo
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _altezzaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();



  DateTime? _selectedDate;
  final Set<String> _selectedArts = {};

  final List<String> _martialArts = [
    'Judo',
    'Karate',
    'Boxe',
    'Muay thai',
    'BJJ',
    'MMA',
    'Altro'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    _cognomeController.dispose();
    _descrizioneController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _selezionaFoto() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _immaginiSelezionate.addAll(
            pickedFiles.map((xFile) => File(xFile.path)).toList(),
          );
        });
      }
    } catch (e) {
      debugPrint('Errore selezione foto: $e');
    }
  }

  Future<void> registra() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try{
      final DatabaseService db = DatabaseService();

      await db.registraUtente(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          nome: _nomeController.text,
          cognome: _cognomeController.text,
          artiPraticate: _selectedArts,
          dataNascita: _selectedDate,
          altezzaCm: int.tryParse(_altezzaController.text),
          pesoKg: int.tryParse(_pesoController.text),
          descrizione: _descrizioneController.text,
          fotoProfilo: _immaginiSelezionate);

      if(!mounted) return;
      Navigator.of(context).pop();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      print("Errore durante la registrazione: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _previousPage();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Sfondo con i lottatori (visibile sotto i dialog grigi)
            Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/bottom_fighters.png', // Assicurati sia presente nei tuoi asset
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // PageView con le 5 Schermate di Registrazione
            SafeArea(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disabilita lo swipe manuale
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildStep1EmailPassword(),
                  _buildStep2DatiPersonali(),
                  _buildStep3ArtiMarziali(),
                  _buildStep4UploadFoto(),
                  _buildStep5TerminiBenvenuto(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: EMAIL & PASSWORD ---
  Widget _buildStep1EmailPassword() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 160, fit: BoxFit.contain),
            const SizedBox(height: 20),
            _buildCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Email'),
                  const SizedBox(height: 6),
                  _buildTextField(_emailController, 'email'),
                  const SizedBox(height: 16),
                  _buildLabel('Scegli password'),
                  const SizedBox(height: 6),
                  _buildTextField(_passwordController, 'password', isPassword: true),
                  const SizedBox(height: 24),
                  _buildButton('Avanti', Colors.white, Colors.black, _nextPage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// --- STEP 2: DATI PERSONALI ---
  Widget _buildStep2DatiPersonali() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _buildCardContainer(
          backgroundColor: const Color(0xFFC4C4C4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nome', color: Colors.black87),
              const SizedBox(height: 6),
              _buildTextField(_nomeController, '', fillColor: const Color(0xFFE0E0E0), textColor: Colors.black),
              const SizedBox(height: 12),
              _buildLabel('Cognome', color: Colors.black87),
              const SizedBox(height: 6),
              _buildTextField(_cognomeController, '', fillColor: const Color(0xFFE0E0E0), textColor: Colors.black),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('Data di nascita', color: Colors.black87),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1940),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_selectedDate == null
                        ? 'Value'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  )
                ],
              ),
              const SizedBox(height: 12),
              // --- NUOVI CAMPI: ALTEZZA E PESO ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Altezza (cm)', color: Colors.black87),
                        const SizedBox(height: 6),
                        _buildTextField(
                          _altezzaController,
                          'es. 175',
                          fillColor: const Color(0xFFE0E0E0),
                          textColor: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Peso (kg)', color: Colors.black87),
                        const SizedBox(height: 6),
                        _buildTextField(
                          _pesoController,
                          'es. 70',
                          fillColor: const Color(0xFFE0E0E0),
                          textColor: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLabel('Descrizione profilo', color: Colors.black87),
              const SizedBox(height: 6),
              _buildTextField(_descrizioneController, '', fillColor: const Color(0xFFE0E0E0), textColor: Colors.black, maxLines: 3),
              const SizedBox(height: 20),
              _buildButton('Submit', const Color(0xFF2C2C2E), Colors.white, _nextPage),
              const SizedBox(height: 16),
              _buildProgressBar(1),
            ],
          ),
        ),
      ),
    );
  }
// --- STEP 3: SELEZIONE ARTI MARZIALI (MULTIPLA + TASTO AVANTI) ---
  Widget _buildStep3ArtiMarziali() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _buildCardContainer(
          backgroundColor: const Color(0xFFC4C4C4),
          child: Column(
            children: [
              const Text(
                'Che arti marziali pratichi?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Lista opzioni selezionabili (scelta multipla)
              ..._martialArts.map((art) {
                final isSelected = _selectedArts.contains(art);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFB0B0B0),
                        foregroundColor:
                        isSelected ? Colors.white : Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            _selectedArts.remove(art); // Deseleziona
                          } else {
                            _selectedArts.add(art); // Seleziona
                          }
                        });
                      },
                      child: Text(
                        art,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Pulsante Avanti manuale
              _buildButton(
                'Avanti',
                const Color(0xFF2C2C2E),
                Colors.white,
                    () {
                  if (_selectedArts.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Seleziona almeno un\'arte marziale'),
                      ),
                    );
                    return;
                  }
                  _nextPage();
                },
              ),

              const SizedBox(height: 12),
              _buildProgressBar(2),
            ],
          ),
        ),
      ),
    );
  }

  // --- STEP 4: CARICAMENTO FOTO ---
  Widget _buildStep4UploadFoto() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _buildCardContainer(
          backgroundColor: const Color(0xFFC4C4C4),
          child: Column(
            children: [
              const Text(
                'Inserisci le tue foto:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _selezionaFoto,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _immaginiSelezionate.isEmpty ? Icons.upload_outlined : Icons.check_circle_outline,
                        size: 48,
                        color: _immaginiSelezionate.isEmpty ? Colors.black87 : Colors.green[800],
                      ),
                      if (_immaginiSelezionate.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${_immaginiSelezionate.length} foto selezionate',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Clicca per aggiungerne altre',
                          style: TextStyle(color: Colors.black54, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildButton('Continua', const Color(0xFF2C2C2E), Colors.white, () {
                if (_immaginiSelezionate.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleziona almeno una foto per proseguire!')),
                  );
                  return;
                }
                _nextPage();
              }),
              const SizedBox(height: 16),
              _buildProgressBar(3),
            ],
          ),
        ),
      ),
    );
  }

  // --- STEP 5: BENVENUTO / TERMINI E CONDIZIONI ---
  Widget _buildStep5TerminiBenvenuto() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            _buildCardContainer(
              backgroundColor: const Color(0xFFC4C4C4),
              child: Column(
                children: [
                  const Text(
                    'Benvenuto!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fight Hub è una piattaforma dedicata esclusivamente alla condivisione di contenuti, informazioni e intrattenimento legati al mondo dei combattimenti.\n\n'
                        'Non organizziamo, promuoviamo né gestiamo incontri o attività fisiche tra utenti. Qualsiasi interazione, incontro o attività svolta al di fuori dell’app avviene sotto la totale responsabilità degli utenti coinvolti.\n\n'
                        'Fight Hub declina ogni responsabilità per eventuali danni fisici, legali o di qualsiasi altra natura derivanti da combattimenti, incontri o comportamenti degli utenti.\n\n'
                        'Utilizzando l’app, accetti questi termini e riconosci di agire sempre sotto la tua piena responsabilità.',
                    style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar(4),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 48,
              child: _buildButton(
                'Accetta',
                const Color(0xFF2C2C2E),
                Colors.white,
                    () {
                  // Finalizza la registrazione e passa alla HomeScreen
                  registra();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER PER GLI ELEMENTI REUTILIZZABILI ---

  Widget _buildCardContainer({required Widget child, Color backgroundColor = const Color(0xFF1C1C1E)}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: child,
    );
  }

  Widget _buildLabel(String text, {Color color = Colors.grey}) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint, {
        bool isPassword = false,
        Color fillColor = const Color(0xFF2C2C2E),
        Color textColor = Colors.white,
        int maxLines = 1,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      maxLines: maxLines,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color bg, Color fg, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Barra di avanzamento rossa in basso a ciascuna card
  Widget _buildProgressBar(int step) {
    // step va da 1 a 4
    double progress = step / 4;
    return Container(
      height: 4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}