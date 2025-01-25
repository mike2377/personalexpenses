import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:personalexpensesapp/screens/main_layout.dart';
import 'package:personalexpensesapp/theme_provider.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Pour les animations

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final FirebaseAuth auth = FirebaseAuth.instance;

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        await auth.signInWithCredential(credential);

        // Récupérer l'URL de la photo de profil
        final User? user = auth.currentUser;
        if (user != null && user.photoURL != null) {
          // Stocker l'URL de la photo de profil dans ThemeProvider
          Provider.of<ThemeProvider>(context, listen: false).setProfilePhotoUrl(user.photoURL!);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (error) {
      print("Erreur de connexion avec Google: $error");
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } catch (error) {
      print("Erreur de connexion avec email: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Carte contenant l'icône utilisateur, le texte "Connexion" et le formulaire
                Card(
                  elevation: 8,
                  shadowColor: Color.fromARGB(183, 27, 86, 90),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Cercle avec icône utilisateur
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 27, 86, 90).withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 27, 86, 90).withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Color.fromARGB(255, 27, 86, 90),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(), // Animation de fade-in et zoom

                        const SizedBox(height: 20),

                        // Texte "Connexion"
                        const Text(
                          'Connexion',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 27, 86, 90),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slide(begin: Offset(0, -1)), // Slide depuis le haut

                        const SizedBox(height: 20),

                        // Champ Email
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Entrez votre email',
                            prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 27, 86, 90)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slide(begin: Offset(-1, 0)), // Slide depuis la gauche

                        const SizedBox(height: 20),

                        // Champ Mot de passe
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Mot de passe',
                            hintText: 'Entrez votre mot de passe',
                            prefixIcon: Icon(Icons.lock, color:Color.fromARGB(255, 27, 86, 90)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          obscureText: true,
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slide(begin: Offset(1, 0)), // Slide depuis la droite

                        const SizedBox(height: 10),

                        // Bouton "Mot de passe oublié ?"
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Gérer le mot de passe oublié
                            },
                            child: const Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(color:Color.fromARGB(255, 27, 86, 90)),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms),

                        const SizedBox(height: 20),

                        // Bouton "Se connecter"
                        ElevatedButton(
                          onPressed: _signInWithEmailAndPassword,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color.fromARGB(255, 27, 86, 90), // Couleur du texte
                            backgroundColor: Colors.white, // Fond blanc
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color.fromARGB(255, 27, 86, 90)), // Bordure violette
                            ),
                          ),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(),

                        const SizedBox(height: 20),

                        // Texte "Ou se connecter avec"
                        const Text(
                          'Ou se connecter avec',
                          style: TextStyle(color: Colors.grey),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms),

                        const SizedBox(height: 10),

                        // Bouton "Se connecter avec Google" avec image du logo Google
                        ElevatedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: Image.asset(
                            'assets/images/google_logo.png', // Chemin de l'image du logo Google
                            width: 64,
                            height: 34,
                          ),
                          label: const Text(
                            'Se connecter avec Google',
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .shake(), // Secouer légèrement
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



