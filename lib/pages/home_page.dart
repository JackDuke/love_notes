import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Riferimento alla collezione nel database
  final CollectionReference notesCollection = FirebaseFirestore.instance.collection('notes');
  final TextEditingController _controller = TextEditingController();
  
  String _welcomeMessage = "";

  // Database locale di frasi carine (poi potremo spostarlo su Firebase)
  final List<String> _frasiCarine = [
    "Oggi ti trovo meravigliosa/o!",
    "Ricordati che sei speciale.",
    "Non vedo l'ora di vederti.",
    "Sei il mio pensiero preferito.",
    "Grazie di esserci."
  ];

  @override
  void initState() {
    super.initState();
    // Logica per scegliere una frase random all'avvio
    _welcomeMessage = _frasiCarine[Random().nextInt(_frasiCarine.length)];
    
    // Mostriamo la frase con un piccolo ritardo o in un dialog (qui uso un SnackBar dopo il build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❤️ $_welcomeMessage"),
          backgroundColor: Colors.pinkAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  String _getNomeUtente() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == "paolo.cecca96@gmail.com") return "Paolo"; // Metti il tuo nome/email vera
    if (user?.email == "laura.tortorici1995@gmail.com") return "Laura"; // Metti il suo nome/email vera
    return "Anonymous";
  }

  // Funzione per aggiungere una nota
  void _addNote() {
    if (_controller.text.isNotEmpty) {
      notesCollection.add({
        'testo': _controller.text,
        'data': Timestamp.now(),
        'autore': _getNomeUtente(), // <--- ORA È DINAMICO!
        'uid': FirebaseAuth.instance.currentUser?.uid, // Salviamo anche l'ID tecnico per sicurezza
      });
      _controller.clear();
      Navigator.of(context).pop();
    }
  }

  // Dialog per scrivere
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cosa vuoi dirmi?"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "Scrivi qui..."),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(onPressed: _addNote, child: const Text("Salva")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note ❤️"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(), // <--- LOGOUT
          ),
        ],
      ),
      body: StreamBuilder(
        // StreamBuilder ascolta il DB in tempo reale
        stream: notesCollection.orderBy('data', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            // Stampiamo l'errore in console per sicurezza
            print("ERRORE FIREBASE: ${snapshot.error}"); 
            // Mostriamolo anche a schermo
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Errore: ${snapshot.error}"),
            ));
          }
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              var nota = data.docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(nota['testo']),
                  // Formattazione data semplice
                  subtitle: Text(nota['data'].toDate().toString().substring(0, 16)), 
                  leading: const Icon(Icons.favorite, color: Colors.redAccent),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}