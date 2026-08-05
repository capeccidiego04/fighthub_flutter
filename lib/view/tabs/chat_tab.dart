import 'package:flutter/material.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo della Sezione
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Text(
            'I tuoi Match & Chat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        // Sezione "Nuovi Match" Orizzontale
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Nuovi Fight Match',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.redAccent,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 10}'),
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(height: 32, indent: 20, endIndent: 20),

        // Sezione Conversazioni
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Messaggi',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: ListView.separated(
            itemCount: 4,
            separatorBuilder: (context, index) => const Divider(indent: 80, endIndent: 20),
            itemBuilder: (context, index) {
              final nomi = ['Mike Tyson', 'Habib', 'Conor', 'Ronda'];
              final messaggi = [
                'Ci vediamo in palestra alle 18?',
                'Ottimo sparring oggi!',
                'Accetti la sfida?',
                'Quando facciamo un altro round?'
              ];

              return ListTile(
                leading: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 1}'),
                ),
                title: Text(
                  nomi[index],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                subtitle: Text(
                  messaggi[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Text(
                  '12:30',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  // Apri la conversazione specifica
                },
              );
            },
          ),
        ),
      ],
    );
  }
}