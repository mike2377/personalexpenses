import 'package:flutter/material.dart';
import 'package:personalexpensesapp/screens/home.dart';
import 'package:personalexpensesapp/screens/dashboard.dart';
import 'package:personalexpensesapp/screens/settings.dart';
import 'package:personalexpensesapp/screens/add_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Clé globale pour accéder à l'état de MyHomePage
  final GlobalKey<MyHomePageState> _homePageKey = GlobalKey<MyHomePageState>();

  // Liste des pages de l'application
  final List<Widget> _pages = [
    MyHomePage(key: GlobalKey<MyHomePageState>()),
    const DashboardScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    // Appeler la méthode addTransaction de MyHomePage
                    final homePage = _pages[_selectedIndex] as MyHomePage;
                    (homePage.key as GlobalKey<MyHomePageState>)
                        .currentState
                        ?.addTransaction(title, amount, date);
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
            const SizedBox(width: 40), // Espace pour le bouton flottant
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _onItemTapped(2),
              color: _selectedIndex == 2 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => _onItemTapped(2),
              color: _selectedIndex == 2 ? Colors.purple : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}