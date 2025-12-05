// import 'package:flutter/material.dart';
// import 'package:love_notes/common/loading_dialog.dart';
// import 'package:love_notes/exception/auth_exception_handler.dart';
// import 'package:love_notes/services/auth_service.dart';

// class LoginPage extends StatefulWidget {
//   final void Function()? onPressed;

//   const LoginPage({super.key, this.onPressed});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _email = TextEditingController();
//   final TextEditingController _password = TextEditingController();

//   final _formKey = GlobalKey<FormState>();

//   void login() {
//     // Show loading dialog
//     if (mounted) {
//       setState(() {
//         LoadingDialog.showLoadingDialog(context, "Loading...");
//         AuthService()
//             .loginWithEmailAndPassword(
//                 email: _email.text, password: _password.text)
//             .then((status) {
//           // Hide loading dialog
//           LoadingDialog.hideLoadingDialog(context);
//           if (status == AuthResultStatus.successful) {
//             // Fluttertoast.showToast(msg: "Successful");
//           } else {
//             AuthExceptionHandler.generateExceptionMessage(status);
//             // Fluttertoast.showToast(msg: errorMsg);
//           }
//         });
//       });
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _email.dispose();
//     _password.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       resizeToAvoidBottomInset: true,
//       body: SingleChildScrollView(
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height,
//           child: Form(
//             key: _formKey,
//             child: Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(25.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.monitor_heart,
//                       size: 100,
//                       color: Color.fromARGB(255, 101, 10, 10),
//                     ),
//                     const SizedBox(height: 25),
//                     const Text(
//                       "Love notes",
//                       style: TextStyle(fontSize: 20, color: Colors.white),
//                     ),
//                     const SizedBox(height: 50),
//                     TextFormField(
//                       controller: _email,
//                       validator: (text) {
//                         if (text == null || text.trim().isEmpty) {
//                           return 'Email is empty';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(color: Colors.white),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           hintText: "Email",
//                           hintStyle: const TextStyle(color: Colors.white60)),
//                       obscureText: false,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                     const SizedBox(height: 10),
//                     TextFormField(
//                       controller: _password,
//                       validator: (text) {
//                         if (text == null || text.trim().isEmpty) {
//                           return 'Password is empty';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(color: Colors.white),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           hintText: "Password",
//                           hintStyle: const TextStyle(color: Colors.white60)),
//                       obscureText: true,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                     const SizedBox(height: 50),
//                     ElevatedButton(
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           login();
//                         }
//                       },
//                       style: ButtonStyle(
//                         backgroundColor: MaterialStateProperty.all<Color>(
//                           const Color.fromARGB(255, 101, 10, 10),
//                         ),
//                         shape: MaterialStateProperty.all<OutlinedBorder>(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                       child: Container(
//                         padding: const EdgeInsets.all(25),
//                         child: const Center(
//                           child: Text(
//                             "Login",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     GestureDetector(
//                       onTap: widget.onPressed,
//                       child: const Text(
//                         'Non hai un account? Registrati',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.blue,
//                           decoration: TextDecoration.underline,
//                           decorationColor: Colors.blue,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _authService = AuthService();

  bool _loadingEmail = false;
  bool _loadingGoogle = false;
  String? _err;

  Future<void> _signIn() async {
    setState(() {
      _loadingEmail = true;
      _err = null;
    });

    try {
      print('Click login...');
      await _authService.signInWithEmailPassword(
        email: _email.text,
        password: _pass.text,
      );
      print('Login returned OK');
    } on AuthFailure catch (e) {
      setState(() => _err = '${e.code}: ${e.message}');
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loadingEmail = false);
      }
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      _loadingGoogle = true;
      _err = null;
    });

    try {
      await _authService.signInWithGoogle();
    } on AuthFailure catch (e) {
      setState(() => _err = e.message);
    } finally {
      if (mounted) {
        setState(() => _loadingGoogle = false);
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '💛 Love Notes',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (_err != null) ...[
                  Text(
                    _err!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _loadingEmail ? null : _signIn,
                        child: _loadingEmail
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loadingGoogle ? null : _googleLogin,
                  icon: _loadingGoogle
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: const Text('Accedi con Google'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
