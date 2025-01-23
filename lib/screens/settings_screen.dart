import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personalexpensesapp/theme_provider.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Importez flutter_animate

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontFamily: 'Times New Roman', // Police Times New Roman
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section Apparence
          _buildSectionTitle('Apparence').animate().fadeIn(duration: 500.ms).slideX(begin: -0.5),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SwitchListTile(
              title: const Text('Mode Sombre'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5),

          const SizedBox(height: 20),

          // Section Langue
          _buildSectionTitle('Langue').animate().fadeIn(duration: 500.ms).slideX(begin: -0.5),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: const Text('Changer la langue'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Ajouter une action pour changer la langue
              },
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5),

          const SizedBox(height: 20),

          // Section Notifications
          _buildSectionTitle('Notifications').animate().fadeIn(duration: 500.ms).slideX(begin: -0.5),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SwitchListTile(
              title: const Text('Activer les notifications'),
              value: true, // Remplacez par la valeur réelle des préférences de l'utilisateur
              onChanged: (value) {
                // Ajouter une action pour activer/désactiver les notifications
              },
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5),

          const SizedBox(height: 20),

          // Section Confidentialité
          _buildSectionTitle('Confidentialité').animate().fadeIn(duration: 500.ms).slideX(begin: -0.5),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.green),
              title: const Text('Paramètres de confidentialité'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Ajouter une action pour gérer la confidentialité
              },
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5),

          const SizedBox(height: 20),

          // Section Aide et Support
          _buildSectionTitle('Aide et Support').animate().fadeIn(duration: 500.ms).slideX(begin: -0.5),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.help, color: Colors.orange),
              title: const Text('Aide et Support'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Ajouter une action pour ouvrir l'aide et le support
              },
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5),

          const SizedBox(height: 20),

          // Section À Propos
          _buildSectionTitle('À Propos').animate().fadeIn(duration: 500.ms).slideX(begin: -0.5),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.purple),
              title: const Text('À Propos de l\'application'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Ajouter une action pour afficher les informations sur l'application
              },
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5),
        ],
      ),
    );
  }

  // Fonction pour construire un titre de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}