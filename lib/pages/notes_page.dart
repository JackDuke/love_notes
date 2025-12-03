import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // MVP: identico su entrambi i telefoni (poi lo rendiamo “invito”)
  static const coupleId = 'paolo-e-laura';

  static const _quotes = [
    'Sei il mio pensiero felice 💛',
    'Grazie perché ci sei, sempre.',
    'Oggi è un buon giorno per un abbraccio in più 🤗',
    'Noi due: la mia cosa preferita.',
  ];

  late final String quote = _quotes[Random().nextInt(_quotes.length)];

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> _notesStream() {
    return _db
        .collection('notes')
        .where('coupleId', isEqualTo: coupleId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _addNote() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuova nota'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 1,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Scrivi qualcosa da dirle/dirti...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salva')),
        ],
      ),
    );

    final text = controller.text.trim();
    if (ok == true && text.isNotEmpty) {
      final uid = _auth.currentUser!.uid;
      await _db.collection('notes').add({
        'coupleId': coupleId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
        'isDone': false,
      });
    }
    controller.dispose();
  }

  Future<void> _toggleDone(String docId, bool isDone) async {
    await _db.collection('notes').doc(docId).update({'isDone': !isDone});
  }

  Future<void> _delete(String docId) async {
    await _db.collection('notes').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Love Notes'),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(quote, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _notesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Errore nel caricamento note'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('Nessuna nota ancora. Aggiungine una 💛'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final d = docs[i];
                      final data = d.data();
                      final text = (data['text'] ?? '') as String;
                      final isDone = (data['isDone'] ?? false) as bool;

                      return Dismissible(
                        key: ValueKey(d.id),
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(Icons.delete),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete),
                        ),
                        onDismissed: (_) => _delete(d.id),
                        child: Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: isDone,
                              onChanged: (_) => _toggleDone(d.id, isDone),
                            ),
                            title: Text(
                              text,
                              style: TextStyle(
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
