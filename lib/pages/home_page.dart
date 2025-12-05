import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _fraseDelGiorno = "";

  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _generaFrase();
  }

  void _generaFrase() {
    final List<String> frasi = [
      "Sei il mio CSS preferito 💖",
      "Oggi ti trovo in formissima!",
      "Ricordati che ti amo.",
      "Casa è dove ci sei tu.",
      "Meno bug, più abbracci."
    ];
    setState(() {
      _fraseDelGiorno = frasi[Random().nextInt(frasi.length)];
    });
  }

  String _chiStaScrivendo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Anonymous 👻";

    // SOSTITUISCI QUI CON LE VOSTRE EMAIL REALI
    if (user.email == "paolo.cecca96@gmail.com") return "Paolo"; 
    if (user.email == "sua.email@gmail.com") return "Laura";
    
    // Fallback se qualcos'altro non va
    return "Anonymous";
  }

  // Calcolo giorni al weekend
  int _giorniAlWeekend() {
    final now = DateTime.now();
    // 6 = Sabato, 7 = Domenica. Se è Lun(1), mancano 5 giorni.
    if (now.weekday >= 6) return 0; // È già weekend!
    return 6 - now.weekday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Titolo più discreto, perché ora il protagonista è la frase
        // title: Text("Ciao ${_chiStaScrivendo()}", style: const TextStyle(color: Colors.black54, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0), // Più margine ai lati per eleganza
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. NUOVO HEADER TESTUALE (Fuori dalla griglia)
            _buildQuoteHeader(),

            const SizedBox(height: 30), // Spazio per far respirare il testo

            // 2. LA GRIGLIA BENTO (Senza più il blocco frase)
            
            StaggeredGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                
                // BLOCCO 1: NOTE & CHAT
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: _buildBentoCard(
                    color: const Color(0xFF7C4DFF), // Viola
                    title: "Note & Chat",
                    content: "Scrivi...",
                    icon: Icons.movie_filter,
                    isDark: true,
                    onTap: _showAddNoteDialog,
                  ),
                ),

                // BLOCCO 2: CINEMA
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: _buildBentoCard(
                    color: Colors.white,
                    title: "Cinema",
                    content: "Film e Serie TV",
                    icon: Icons.chat_bubble_outline,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prossimamente...")));
                    },
                  ),
                ),

                // BLOCCO 3: WEEKEND (Resta qui, si affianca a Note & Chat)
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: _buildBentoCard(
                    color: const Color(0xFFFF4081), // Rosa
                    title: "Weekend",
                    content: _giorniAlWeekend() == 0 
                        ? "È ORA! 🎉" 
                        : "- ${_giorniAlWeekend()} gg",
                    icon: Icons.weekend,
                    isDark: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            
            // LISTA RECENTI
            const Text("APPUNTI RECENTI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
            const SizedBox(height: 15),
            _buildRecentNotesList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- IL NUOVO WIDGET PER LA FRASE GRANDE ---
  Widget _buildQuoteHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etichetta piccola
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "DAILY MOOD", // ❤️
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: Colors.red.shade300,
              letterSpacing: 1.0
            ),
          ),
        ),
        const SizedBox(height: 15),
        // La frase vera e propria
        Text(
          _fraseDelGiorno,
          style: const TextStyle(
            fontSize: 36, // Molto grande
            height: 1.1, // Interlinea stretta per stile editoriale
            fontWeight: FontWeight.w800, // Grassetto pesante
            color: Color(0xFF1A1A1A), // Quasi nero
            fontFamily: 'Georgia', // Se non hai font custom, Georgia dà un tocco elegante di default
            letterSpacing: -1.0, // Stretto
          ),
        ),
      ],
    );
  }

  // --- WIDGET LISTA RECENTI (Minimal) ---
  Widget _buildRecentNotesList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('notes').orderBy('data', descending: true).limit(5).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        
        return ListView.builder(
          shrinkWrap: true, // Importante dentro una Column
          physics: const NeverScrollableScrollPhysics(), // Non scrolla da sola
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            String autore = doc['autore'];

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: autore == "Paolo" ? Colors.blue[100] : Colors.pink[100],
                  child: Text(
                    autore.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: autore == "Paolo" ? Colors.blue[800] : Colors.pink[800],
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                title: Text(doc['testo'], maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(
                  _formatDate(doc['data']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- IL COMPONENTE "BENTO CARD" ---
  Widget _buildBentoCard({
    required Color color,
    required String title,
    required String content,
    required IconData icon,
    bool isDark = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icona in alto a destra
            Align(
              alignment: Alignment.topRight,
              child: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
            ),
            // Testi
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18, // Font grande per impatto
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- DIALOG PER AGGIUNGERE NOTA ---
  void _showAddNoteDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuova Nota"),
        // Usiamo un Container per definire le dimensioni
        content: SizedBox(
          width: double.maxFinite, // Cerca di occupare tutta la larghezza disponibile
          height: 200,             // Altezza fissa più grande (puoi aumentarla se vuoi)
          child: TextField(
            controller: controller, 
            autofocus: true, 
            textCapitalization: TextCapitalization.sentences,
            
            // --- MODIFICHE PER SCRIVERE TANTO ---
            maxLines: null,        // Nessun limite di righe
            expands: true,         // Riempie tutto lo spazio verticale del Container
            textAlignVertical: TextAlignVertical.top, // Inizia a scrivere dall'alto, non dal centro
            keyboardType: TextInputType.multiline, // La tastiera avrà il tasto "Invio" per andare a capo
            // ------------------------------------

            decoration: InputDecoration(
              hintText: "Scrivi qui i tuoi pensieri...",
              border: OutlineInputBorder( // Aggiungiamo un bordo per definire l'area
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey[50], // Sfondo leggermente grigio nell'area di testo
            )
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Annulla")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                String nomeAutore = _chiStaScrivendo(); 

                FirebaseFirestore.instance.collection('note_condivise').add({
                  'testo': controller.text,
                  'data': Timestamp.now(),
                  'autore': nomeAutore,
                  'uid': FirebaseAuth.instance.currentUser?.uid,
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Salva"),
          )
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "";
    DateTime d = (timestamp as Timestamp).toDate();
    return "${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }
}