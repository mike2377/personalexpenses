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

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Define a GlobalKey for MyHomePage
  final GlobalKey<MyHomePageState> _homePageKey = GlobalKey<MyHomePageState>();

  // Declare the list of pages without initializing it
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize the list of pages in the constructor body
    _pages = [
      MyHomePage(key: _homePageKey), // Pass the key to MyHomePage
      const DashboardScreen(),
      const SettingsScreen(), // Page Settings
      const AccountScreen(), // Page Account
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber, // Couleur de fond de l'AppBar
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
            fontSize: 20, // Taille de la police
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
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ajouter une nouvelle transaction
          if (_selectedIndex == 0) {
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
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => _onItemTapped(0),
              color: _selectedIndex == 0 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.dashboard),
              onPressed: () => _onItemTapped(1),
              color: _selectedIndex == 1 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _onItemTapped(2), // Page Settings
              color: _selectedIndex == 2 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => _onItemTapped(3), // Page Account
              color: _selectedIndex == 3 ? Colors.purple : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}