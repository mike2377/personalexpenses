import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personalexpensesapp/screens/home.dart';
import 'package:personalexpensesapp/screens/dashboard.dart';
import 'package:personalexpensesapp/screens/settings_screen.dart';
import 'package:personalexpensesapp/screens/account_screen.dart';
import 'package:personalexpensesapp/screens/add_screen.dart';
import 'package:personalexpensesapp/theme_provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final GlobalKey<MyHomePageState> _homePageKey = GlobalKey<MyHomePageState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MyHomePage(key: _homePageKey),
      const DashboardScreen(),
      const SettingsScreen(),
      const AccountScreen(),
    ];
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.getTheme();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          _selectedIndex == 0
              ? 'JM Expense Tracker'
              : _selectedIndex == 1
                  ? 'Dashboard'
                  : _selectedIndex == 2
                      ? 'Settings'
                      : 'Account',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Times New Roman',
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white, // Fond blanc pour le cercle
            child: themeProvider.profilePhotoUrl != null
                ? ClipOval(
                    child: Image.network(
                      themeProvider.profilePhotoUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.person, size: 20, color: Colors.grey), // Icône par défaut
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildCustomBottomNavigationBar(theme),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            _animationController.reset();
            _animationController.forward();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => AddScreen(
                  addTransaction: (title, amount, date) {
                    _homePageKey.currentState?.addTransaction(title, amount, date);
                  },
                ),
              ),
            );
          }
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        shape: const CircleBorder(),
      ),
    );
  }

  Widget _buildCustomBottomNavigationBar(ThemeData theme) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.cardColor, // Utiliser la couleur de fond du thème
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
          _buildBottomNavigationItem(0, Icons.home, 'Home', theme),
          _buildBottomNavigationItem(1, Icons.dashboard, 'Dashboard', theme),
          const SizedBox(width: 48),
          _buildBottomNavigationItem(2, Icons.settings, 'Settings', theme),
          _buildBottomNavigationItem(3, Icons.account_circle, 'Account', theme),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationItem(int index, IconData icon, String label, ThemeData theme) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : theme.iconTheme.color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
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