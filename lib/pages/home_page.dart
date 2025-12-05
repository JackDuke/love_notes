import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String _fraseDelGiorno = "";
  
  // COLORI "PASSION RED"
  final Color _redDark = const Color(0xFFD31027);
  final Color _redLight = const Color(0xFFEA384D);
  final Color _bgWhite = const Color.fromARGB(255, 230, 231, 233);

  // 2. VARIABILI ANIMAZIONE
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _generaFrase();

    // 3. LOGICA BATTITO
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _heartAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)), // Un po' più grande qui
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_heartController);

    _heartController.repeat();
  }

// 4. DISPOSE (Per liberare memoria)
  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
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
    if (user == null) return "Ghost";
    // Modifica con le email reali
    if (user.email == "paolo.cecca96@gmail.com") return "Paolo"; 
    if (user.email == "laura.tortorici1995@gmail.com") return "Laura";
    return "Anonymous";
  }

  int _giorniAlWeekend() {
    final now = DateTime.now();
    if (now.weekday >= 6) return 0; 
    return 6 - now.weekday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite, // Sfondo pulito
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            // 5. ICONA ANIMATA QUI
            ScaleTransition(
              scale: _heartAnimation,
              child: Icon(Icons.favorite_rounded, color: _redDark, size: 28), // Leggermente più grande (28)
            ),
            const SizedBox(width: 10),
            Text(
              "LOVE SYNC",
              style: TextStyle(
                color: _redDark, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 1.5,
                fontSize: 18
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: _redDark),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildQuoteHeader(),

            const SizedBox(height: 30),

            // GRIGLIA BENTO "PASSION STYLE"
            StaggeredGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                
                // 1. CINEMA (Card Hero - Gradiente Rosso)
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: _buildRedBentoCard(
                    title: "Cinema",
                    content: "Film & Serie TV",
                    icon: Icons.movie_filter_rounded,
                    isGradient: true, // <--- Sfondo Rosso Pieno
                    onTap: () {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prossimamente...")));
                    },
                  ),
                ),

                // 2. CHAT (Card Light - Bianco con accenti rossi)
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: _buildRedBentoCard(
                    title: "Nuova Nota",
                    content: "Scrivi...",
                    icon: Icons.edit_note_rounded,
                    isGradient: false, // <--- Sfondo Bianco
                    onTap: _showAddNoteDialog,
                  ),
                ),

                // 3. WEEKEND (Card Light)
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: _buildRedBentoCard(
                    title: "Weekend",
                    content: _giorniAlWeekend() == 0 ? "Party! 🎉" : "- ${_giorniAlWeekend()} gg",
                    icon: Icons.weekend_rounded,
                    isGradient: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            
            Text(
              "TIMELINE", 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey[400], 
                letterSpacing: 2.0
              )
            ),
            const SizedBox(height: 15),
            _buildRecentNotesList(),
            const SizedBox(height: 80), // Spazio per il FAB
          ],
        ),
      ),
      
      // FLOATING ACTION BUTTON ROSSO
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_redDark, _redLight]),
          // shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: _redLight.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
          ]
        ),
        child: FloatingActionButton(
          onPressed: _showAddNoteDialog,
          backgroundColor: Colors.transparent, // Importante per vedere il gradiente
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // --- HEADER CON STILE "PASSION" ---
  Widget _buildQuoteHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _redDark.withOpacity(0.1), // Sfondo rosso chiarissimo
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "DAILY MOOD",
            style: TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.bold, 
              color: _redDark, // Testo rosso scuro
              letterSpacing: 1.0
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          _fraseDelGiorno,
          style: const TextStyle(
            fontSize: 32,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: Colors.black87, // Nero morbido per contrasto
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // --- LISTA NOTE PULITA ---
  Widget _buildRecentNotesList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('notes').orderBy('data', descending: true).limit(10).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Center(child: LinearProgressIndicator(color: Colors.red));
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            String autore = doc['autore'];
            // bool isMe = autore == "Paolo";

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: _redDark.withOpacity(0.1), // isMe ? Colors.grey[100] : _redDark.withOpacity(0.1),
                  child: Text(
                    autore.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: _redDark, // isMe ? Colors.black54 : _redDark
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                title: Text(
                  doc['testo'], 
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis
                ),
                trailing: Text(
                  _formatDate(doc['data']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- BENTO CARD ROSSA/BIANCA ---
  Widget _buildRedBentoCard({
    required String title,
    required String content,
    required IconData icon,
    bool isGradient = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Logica colori: Gradiente se evidenziato, Bianco se normale
          gradient: isGradient 
              ? LinearGradient(colors: [_redDark, _redLight], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: isGradient ? null : Colors.white,
          
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              // Ombra rossa se gradiente, grigia se bianco
              color: isGradient ? _redLight.withOpacity(0.4) : Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
          border: isGradient ? null : Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isGradient ? Colors.white.withOpacity(0.2) : _redDark.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: isGradient ? Colors.white : _redDark, // Icona Bianca o Rossa
                  size: 20
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: isGradient ? Colors.white70 : Colors.grey[400],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(
                    color: isGradient ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // DIALOG (Stile Aggiornato)
  void _showAddNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white, // Rimuove il tint violaceo di Android 12+
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Nuovo Pensiero", style: TextStyle(color: _redDark, fontWeight: FontWeight.bold)),
        content: Container(
          width: double.maxFinite,
          height: 200, // Un po' più compatto
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              hintText: "Scrivi qui...",
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Annulla", style: TextStyle(color: Colors.grey[600]))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _redDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return "${d.day}/${d.month} • ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }
}