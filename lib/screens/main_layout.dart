import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personalexpensesapp/screens/home.dart';
import 'package:personalexpensesapp/screens/dashboard.dart';
import 'package:personalexpensesapp/screens/settings_screen.dart'; // Page Settings
import 'package:personalexpensesapp/screens/account_screen.dart'; // Page Account
import 'package:personalexpensesapp/screens/add_screen.dart';
import 'package:personalexpensesapp/theme_provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  // Déclarez les champs sans `late` et initialisez-les à null
  AnimationController? _animationController;
  Animation<double>? _animation;

  // Define a GlobalKey for MyHomePage
  final GlobalKey<MyHomePageState> _homePageKey = GlobalKey<MyHomePageState>();

  // Declare the list of pages without initializing it
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Initialize the list of pages
    _pages = [
      MyHomePage(key: _homePageKey), // Pass the key to MyHomePage
      const DashboardScreen(),
      const SettingsScreen(), // Page Settings
      const AccountScreen(), // Page Account
    ];

    // Initialize animation controller and animation
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _animationController!.forward();
  }

  @override
  void dispose() {
    // Dispose of the animation controller
    _animationController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Restart animation when switching pages
    _animationController?.reset();
    _animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Vérifiez si l'animation est initialisée
    if (_animation == null || _animationController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 86, 90), // Couleur de fond de l'AppBar
        title: Text(
          _selectedIndex == 0
              ? 'Personal Expenses'
              : _selectedIndex == 1
                  ? 'Dashboard'
                  : _selectedIndex == 2
                      ? 'Settings'
                      : 'Account',
          style: const TextStyle(
            color: Colors.black, // Texte sombre
            fontFamily: 'Times New Roman', // Police Times New Roman
            fontSize: 25, // Taille de la police
            fontWeight: FontWeight.bold, // Texte en gras
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundImage: themeProvider.profilePhotoUrl != null
                ? NetworkImage(themeProvider.profilePhotoUrl!)
                : null,
            radius: 20,
            child: themeProvider.profilePhotoUrl == null
                ? const Icon(Icons.person, size: 20) // Icône par défaut
                : null,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FadeTransition(
        opacity: _animation!,
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  // Bouton flottant personnalisé avec effet de rebond
  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _animation!,
      child: FloatingActionButton(
        onPressed: () {
          // Ajouter une nouvelle transaction
          if (_selectedIndex == 0) {
            // Animation de rebond
            _animationController?.reset();
            _animationController?.forward();

            // Ouvrir le formulaire d'ajout de transaction
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => AddScreen(
                  addTransaction: (title, amount, date) {
                    // Appeler la méthode addTransaction de MyHomePageState
                    _homePageKey.currentState?.addTransaction(title, amount, date);
                  },
                ),
              ),
            );
          }
        },
        backgroundColor: const Color.fromARGB(255, 27, 86, 90), // Couleur du bouton
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        shape: const CircleBorder(), // Rendre le bouton circulaire
      ),
    );
  }

  // Modèle personnalisé pour la barre de navigation
  Widget _buildCustomBottomNavigationBar() {
    return Container(
      height: 80, // Hauteur de la barre de navigation
      decoration: BoxDecoration(
        color: Colors.white, // Couleur de fond
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavigationItem(0, Icons.home, 'Home'),
          _buildBottomNavigationItem(1, Icons.dashboard, 'Dashboard'),
          const SizedBox(width: 48), // Espace pour le bouton flottant
          _buildBottomNavigationItem(2, Icons.settings, 'Settings'),
          _buildBottomNavigationItem(3, Icons.account_circle, 'Account'),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 27, 86, 90).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color.fromARGB(255, 27, 86, 90) : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color.fromARGB(255, 27, 86, 90) : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}