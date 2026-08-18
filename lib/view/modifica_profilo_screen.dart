import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controller/controllore_db.dart';
import '../../model/utente.dart';

class ModificaProfiloScreen extends StatefulWidget {
  final Utente utente;

  const ModificaProfiloScreen({Key? key, required this.utente}) : super(key: key);

  @override
  State<ModificaProfiloScreen> createState() => _ModificaProfiloScreenState();
}

class _ModificaProfiloScreenState extends State<ModificaProfiloScreen> {
  final DatabaseService controllore = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _pesoController;
  late TextEditingController _descrizioneController;

  final List<String> _martialArts = [
    'Judo',
    'Karate',
    'Boxe',
    'Muay thai',
    'BJJ',
    'MMA',
    'Altro'
  ];

  late Set<String> _selectedArts;
  List<dynamic> _immagini = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pesoController = TextEditingController(
      text: widget.utente.peso > 0 ? widget.utente.peso.toString() : '',
    );
    _descrizioneController = TextEditingController(text: widget.utente.descrizione);
    _selectedArts = Set<String>.from(widget.utente.arti);
    _immagini = List.from(widget.utente.imgs);
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _descrizioneController.dispose();
    super.dispose();
  }

  Future<void> _selezionaImmagine() async {
    if (_immagini.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puoi caricare al massimo 6 foto.')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      setState(() {
        _immagini.add(File(image.path));
      });
    }
  }

  Future<void> _salvaModifiche() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedArts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona almeno un\'arte marziale praticata'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await controllore.salvaModifiche(
        uid: widget.utente.id,
        peso: int.parse(_pesoController.text.trim()),
        descrizione: _descrizioneController.text.trim(),
        artiPraticate: _selectedArts,
        immaginiMix: _immagini,
        fotoOriginali: widget.utente.imgs,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profilo aggiornato con successo!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il salvataggio: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF121212);
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Modifica Profilo', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grid Foto Profilo
              const Text(
                'Le tue Foto (max 6)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: _immagini.length < 6 ? _immagini.length + 1 : 6,
                itemBuilder: (context, index) {
                  if (index == _immagini.length && _immagini.length < 6) {
                    return GestureDetector(
                      onTap: _selezionaImmagine,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
                        ),
                        child: const Icon(Icons.add_a_photo, color: Colors.red, size: 32),
                      ),
                    );
                  }

                  final item = _immagini[index];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: item is File
                                ? FileImage(item) as ImageProvider
                                : NetworkImage(item as String),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _immagini.removeAt(index);
                            });
                          },
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black87,
                            child: Icon(Icons.close, size: 16, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Arti Praticate (FilterChips)
              const Text(
                'Arti Praticate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _martialArts.map((art) {
                  final isSelected = _selectedArts.contains(art);
                  return FilterChip(
                    label: Text(art),
                    selected: isSelected,
                    selectedColor: Colors.red,
                    backgroundColor: cardColor,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.red : Colors.white24,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedArts.add(art);
                        } else {
                          _selectedArts.remove(art);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Campo Peso
              const Text(
                'Peso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pesoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Inserisci il tuo peso';
                  if (int.tryParse(val) == null) return 'Inserisci un numero valido';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Peso (Kg)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.fitness_center, color: Colors.red),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Campo Descrizione
              const Text(
                'Descrizione / Bio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descrizioneController,
                maxLines: 4,
                maxLength: 300,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Racconta qualcosa su di te...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Pulsante Salva Modifiche
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _salvaModifiche,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Salva Modifiche',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}