// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:love_notes/auth/auth.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
  
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSplashScreen.withScreenFunction(
//       splash: Center(
//         child: Lottie.asset('assets/splash.json')
//       ),
//       backgroundColor: Colors.black,
//       screenFunction: () async {
//         return const Auth();
//       },
//       splashIconSize: 250,
//       duration: 3000,
//       splashTransition: SplashTransition.fadeTransition,
//       pageTransitionType: PageTransitionType.topToBottom,
//       animationDuration: const Duration(seconds: 3)
//     );
//   }
// }
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💛 Love Notes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              SizedBox(height: 16),
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Sto controllando l\'accesso...'),
            ],
          ),
        ),
      ),
    );
  }
}
