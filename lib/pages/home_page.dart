// import 'dart:math';

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
  
  // String _welcomeMessage = "";

  // Database locale di frasi carine (poi potremo spostarlo su Firebase)
  // final List<String> _frasiCarine = [
  //   "Oggi ti trovo meravigliosa/o!",
  //   "Ricordati che sei speciale.",
  //   "Non vedo l'ora di vederti.",
  //   "Sei il mio pensiero preferito.",
  //   "Grazie di esserci."
  // ];

  @override
  void initState() {
    super.initState();
    // Eseguiamo dopo che la UI è stata costruita
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostraFraseDelGiorno();
    });
  }

  void _mostraFraseDelGiorno() {
    final List<String> frasi = [
      "Sei il mio notifiche preferito 🔔",
      "Oggi ti amo più di ieri (ma meno di domani) ❤️",
      "Ricordati di sorridere!",
      "Sei la mia persona.", 
      "Non vedo l'ora di abbracciarti."
    ];
    
    // Scegli una frase a caso
    String fraseScelta = frasi[DateTime.now().second % frasi.length]; // Random semplice

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ciao Amore! 👋"),
        content: Text(fraseScelta, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Grazie ❤️"),
          )
        ],
      ),
    );
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
              bool sonoIo = nota['uid'] == FirebaseAuth.instance.currentUser?.uid;

              String orarioFormattato = "";
              if (nota['data'] != null) {
                DateTime data = (nota['data'] as Timestamp).toDate();
                // padLeft(2, '0') serve per trasformare "9:5" in "09:05"
                orarioFormattato = " • ${data.hour}:${data.minute.toString().padLeft(2, '0')}";
              }

              return Align(
                alignment: sonoIo ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75, // Occupa il 75% della larghezza
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    color: sonoIo ? Colors.pink[100] : Colors.white, // Colori diversi
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: sonoIo ? const Radius.circular(12) : Radius.zero,
                        bottomRight: sonoIo ? Radius.zero : const Radius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nota['testo'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "${nota['autore']}$orarioFormattato", // Molto più pulito!
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
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