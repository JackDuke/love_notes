import 'package:flutter/material.dart';
import 'package:love_notes/common/loading_dialog.dart';
import 'package:love_notes/exception/auth_exception_handler.dart';
import 'package:love_notes/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onPressed;

  const LoginPage({super.key, this.onPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void login() {
    // Show loading dialog
    if (mounted) {
      setState(() {
        LoadingDialog.showLoadingDialog(context, "Loading...");
        AuthService()
            .loginWithEmailAndPassword(
                email: _email.text, password: _password.text)
            .then((status) {
          // Hide loading dialog
          LoadingDialog.hideLoadingDialog(context);
          if (status == AuthResultStatus.successful) {
            // Fluttertoast.showToast(msg: "Successful");
          } else {
            AuthExceptionHandler.generateExceptionMessage(status);
            // Fluttertoast.showToast(msg: errorMsg);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person,
                      size: 100,
                      color: Color.fromARGB(255, 101, 10, 10),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Resistenza calisthenica",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: _email,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Email is empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "Email",
                          hintStyle: const TextStyle(color: Colors.white60)),
                      obscureText: false,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _password,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Password is empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.white60)),
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          login();
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 101, 10, 10),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: widget.onPressed,
                      child: const Text(
                        'Non hai un account? Registrati',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
