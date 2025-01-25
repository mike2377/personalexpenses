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
      _showLoadingDialog(context); // Afficher l'indicateur de chargement

      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        // Rediriger vers l'écran de connexion et supprimer toutes les routes précédentes
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } catch (e) {
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        _showErrorSnackBar(context, 'Erreur lors de la déconnexion: $e');
      }
    }
  }

  // Fonction pour changer le mot de passe
  void _changePassword(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _showLoadingDialog(context); // Afficher l'indicateur de chargement

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        _showSuccessSnackBar(context, 'Un email de réinitialisation a été envoyé.');
      } catch (e) {
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        _showErrorSnackBar(context, 'Erreur lors de l\'envoi de l\'email: $e');
      }
    } else {
      _showErrorSnackBar(context, 'Aucun utilisateur connecté.');
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
      _showLoadingDialog(context); // Afficher l'indicateur de chargement

      try {
        final user = FirebaseAuth.instance.currentUser;
        await user?.delete();
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } catch (e) {
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        _showErrorSnackBar(context, 'Erreur lors de la suppression du compte: $e');
      }
    }
  }

  // Afficher un indicateur de chargement
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(), // Indicateur de chargement
      ),
    );
  }

  // Afficher un message d'erreur
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Afficher un message de succès
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Titre déplacé dans le body
                const Text(
                  'Mon Compte',
                  style: TextStyle(
                    fontFamily: 'Times New Roman', // Police Times New Roman
                    fontWeight: FontWeight.bold,
                    fontSize: 24, // Taille de la police
                  ),
                ),
                const SizedBox(height: 20),

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
                  _buildUserInfoCard(
                    icon: Icons.person,
                    label: user.displayName ?? 'No Name',
                    color: Color.fromARGB(255, 27, 86, 90),
                  ).animate().fadeIn(duration: 500.ms).slide(begin: Offset(-1, 0)), // Slide depuis la gauche

                  // Animation de l'email de l'utilisateur
                  _buildUserInfoCard(
                    icon: Icons.email,
                    label: user.email ?? 'No Email',
                    color: Colors.grey,
                  ).animate().fadeIn(duration: 500.ms).slide(begin: Offset(1, 0)), // Slide depuis la droite
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

  // Fonction pour construire une carte d'informations utilisateur
  Widget _buildUserInfoCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
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