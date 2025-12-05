import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? errorMessage;

  // Colori del tema "Passion Red"
  final Color _redDark = const Color(0xFFD31027);  // Rosso Rubino scuro
  // final Color _redLight = const Color(0xFFEA384D); // Rosso Corallo acceso
  final Color _bgWhite = const Color(0xFFF8F9FA);

  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Un ciclo completo dura 1.2 secondi
    );

    // SEQUENZA "TUM-TUM"
    _heartAnimation = TweenSequence<double>([
      // 1. PRIMO BATTITO (Piccolo: scala 1.0 -> 1.2)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)), // Scatto veloce fuori
        weight: 10, // Dura il 10% del tempo
      ),
      // 2. RITORNO RAPIDO
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)), 
        weight: 10,
      ),
      // 3. SECONDO BATTITO (Grande: scala 1.0 -> 1.5)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2) // Diventa molto grande!
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15, // Scatto potente
      ),
      // 4. RIPOSO LUNGO (Ritorno e pausa)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)), // Ritorno morbido
        weight: 65, // Si prende tutto il resto del tempo per riposare
      ),
    ]).animate(_heartController);

    _heartController.repeat(); // Loop infinito
  }

  @override
  void dispose() {
    // 4. PULISCI QUANDO CHIUDI LA PAGINA
    // <--- ANIMAZIONE STEP 4: Importantissimo per non sprecare memoria!
    _heartController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _traduciErrore(e.code);
        _isLoading = false;
      });
    }
  }

  String _traduciErrore(String code) {
    switch (code) {
      case 'user-not-found': return "Utente non trovato.";
      case 'wrong-password': return "Password sbagliata.";
      case 'invalid-email': return "Email non valida.";
      default: return "Errore di accesso.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Lo sfondo è il gradiente stesso
      backgroundColor: _bgWhite,
      body: Stack(
        children: [
          // 1. DECORAZIONE SFONDO (Cerchi trasparenti per effetto tech)
          // Positioned(
          //   top: -50,
          //   right: -50,
          //   child: Container(
          //     width: 200,
          //     height: 200,
          //     decoration: BoxDecoration(
          //       color: Colors.white.withOpacity(0.1),
          //       shape: BoxShape.circle,
          //     ),
          //   ),
          // ),
          
          // 2. PARTE ALTA: TITOLO
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icona con effetto "Glass"
                ScaleTransition(
                  scale: _heartAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    // decoration: BoxDecoration(
                    //   color: Colors.white, // Sfondo del cerchio bianco
                    //   shape: BoxShape.circle,
                    //   // Aggiungiamo un'ombra rossa ("Glow") per dare profondità
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: _redDark.withOpacity(0.2), // Ombra rossa trasparente
                    //       blurRadius: 20, 
                    //       offset: const Offset(0, 10)
                    //     )
                    //   ]
                    // ),
                    // IL CUORE ORA È ROSSO
                    child: Icon(
                      Icons.favorite_rounded, 
                      size: 100, // L'ho fatto leggermente più grande
                      color: _redDark, // <--- ECCO LA MODIFICA: Usa il tuo rosso rubino
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "LOVE SYNC",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800, // Font molto spesso
                    color: _redDark,
                    letterSpacing: 2.0, // Spaziatura futuristica
                  ),
                ),
                // Text(
                //   "Database Connesso",
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: Colors.white.withOpacity(0.8),
                //     letterSpacing: 1.0
                //   ),
                // ),
              ],
            ),
          ),
      
          // 3. PARTE BASSA: IL FOGLIO BIANCO
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: BoxDecoration(
                color: _redDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Accedi",
                    style: TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 30),
      
                  // INPUT EMAIL
                  _buildRedInput(
                    controller: _emailController,
                    icon: Icons.alternate_email,
                    hint: "Email",
                  ),
                  
                  const SizedBox(height: 20),
      
                  // INPUT PASSWORD
                  _buildRedInput(
                    controller: _passwordController,
                    icon: Icons.lock_outline_rounded,
                    hint: "Password",
                    isPassword: true,
                  ),
      
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.white))),
                    ),
      
                  const Spacer(),
      
                  // BOTTONE
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.white.withOpacity(0.4),
                      //     blurRadius: 20,
                      //     offset: const Offset(0, 10),
                      //   )
                      // ],
                      gradient: const LinearGradient(colors: [Colors.white, Colors.white]),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Trasparente per mostrare il gradiente sotto
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading 
                        ? CircularProgressIndicator(color: _redDark)
                        : Text(
                          "ENTRA", 
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1.2, 
                            color: Colors.red.shade600
                          )
                        ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], // Sfondo neutro chiaro
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: _redDark), // Icona ROSSA
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}