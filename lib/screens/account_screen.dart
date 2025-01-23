import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:personalexpensesapp/theme_provider.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Pour les animations

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  // Fonction pour gérer la déconnexion
  void _signOut(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(), // Indicateur de chargement
        ),
      );

      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
        );
      }
    }
  }

  // Fonction pour changer le mot de passe
  void _changePassword(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Un email de réinitialisation a été envoyé.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi de l\'email: $e')),
        );
      }
    }
  }

  // Fonction pour supprimer le compte
  void _deleteAccount(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text('Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(), // Indicateur de chargement
        ),
      );

      try {
        final user = FirebaseAuth.instance.currentUser;
        await user?.delete();
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression du compte: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon Compte',
          style: TextStyle(
            fontFamily: 'Times New Roman', // Police Times New Roman
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
                // Animation de la photo de profil
                CircleAvatar(
                  backgroundImage: themeProvider.profilePhotoUrl != null
                      ? NetworkImage(themeProvider.profilePhotoUrl!)
                      : null,
                  radius: 60,
                  child: themeProvider.profilePhotoUrl == null
                      ? const Icon(Icons.person, size: 60) // Icône par défaut
                      : null,
                )
                    .animate() // Début de l'animation
                    .fadeIn(duration: 500.ms) // Fade-in
                    .scale(begin: Offset(0.5, 0.5), end: Offset(1, 1)) // Zoom
                    .shake(duration: 500.ms), // Secouer légèrement

                const SizedBox(height: 20),

                // Animation du nom de l'utilisateur
                if (user != null) ...[
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Color.fromARGB(255, 27, 86, 90)),
                          const SizedBox(width: 10),
                          Text(
                            user.displayName ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slide(begin: Offset(-1, 0)), // Slide depuis la gauche

                  // Animation de l'email de l'utilisateur
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.email, color: Color.fromARGB(255, 27, 86, 90)),
                          const SizedBox(width: 10),
                          Text(
                            user.email ?? 'No Email',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slide(begin: Offset(1, 0)), // Slide depuis la droite
                ],

                const SizedBox(height: 20),

                // Grille de fonctionnalités (2 colonnes)
                GridView.count(
                  crossAxisCount: 2, // 2 colonnes
                  shrinkWrap: true, // Permet à la grille de s'adapter à l'espace disponible
                  physics: const NeverScrollableScrollPhysics(), // Désactive le défilement de la grille
                  mainAxisSpacing: 10, // Espacement vertical entre les éléments
                  crossAxisSpacing: 10, // Espacement horizontal entre les éléments
                  childAspectRatio: 1.2, // Ajuster le ratio hauteur/largeur des éléments
                  children: [
                    // Bouton pour modifier le profil
                    _buildFeatureButton(
                      icon: Icons.edit,
                      label: 'Modifier le profil',
                      color: Color.fromARGB(255, 27, 86, 90),
                      onPressed: () {
                        // Ajouter une action pour modifier le profil
                      },
                    ),

                    // Bouton pour changer le mot de passe
                    _buildFeatureButton(
                      icon: Icons.lock,
                      label: 'Changer le mot de passe',
                      color: Colors.blue,
                      onPressed: () => _changePassword(context),
                    ),

                    // Bouton pour supprimer le compte
                    _buildFeatureButton(
                      icon: Icons.delete,
                      label: 'Supprimer le compte',
                      color: Colors.red,
                      onPressed: () => _deleteAccount(context),
                    ),

                    // Bouton de déconnexion
                    _buildFeatureButton(
                      icon: Icons.logout,
                      label: 'Déconnexion',
                      color: Colors.red,
                      onPressed: () => _signOut(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fonction pour construire un bouton de fonctionnalité
  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Réduire le padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color), // Réduire la taille de l'icône
              const SizedBox(height: 8), // Réduire l'espacement
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12, // Réduire la taille du texte
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(); // Animation de fade-in et zoom
  }
}