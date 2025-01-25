import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:personalexpensesapp/widgets/chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _searchQuery = ''; // Pour la barre de recherche
  String _sortBy = 'date'; // Pour le tri (date, montant, semaine)
  bool _sortAscending = false; // Pour l'ordre de tri (croissant/décroissant)

  @override
  void initState() {
    super.initState();

    // Animation pour les éléments de la liste
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Démarrage des animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Méthode pour afficher une notification
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // ID du canal
      'your_channel_name', // Nom du canal
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // ID de la notification
      title, // Titre de la notification
      body, // Corps de la notification
      platformChannelSpecifics,
    );
  }

  // Méthode pour ajouter une transaction
  void addTransaction(String title, double amount, DateTime date) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('transactions').add({
        'title': title,
        'amount': amount,
        'date': date,
      });

      // Afficher une notification
      await showNotification('Nouvelle Transaction', 'Vous avez ajouté une transaction : $title');
    }
  }

  // Méthode pour éditer une transaction
  void _editTransaction(String id, String title, double amount, DateTime date) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc(id)
          .update({
        'title': title,
        'amount': amount,
        'date': date,
      });
    }
  }

  // Méthode pour supprimer une transaction
  void _deleteTransaction(String id) async {
    final user = _auth.currentUser;
    if (user != null) {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette transaction ?'),
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

      if (confirmDelete == true) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(id)
            .delete();
      }
    }
  }

  // Méthode pour afficher le formulaire d'ajout/édition
  void _showTransactionForm({String? id, String? title, double? amount, DateTime? date}) {
    final _titleController = TextEditingController(text: title);
    final _amountController = TextEditingController(text: amount?.toString());
    final _dateController = TextEditingController(text: date != null ? DateFormat('yyyy-MM-dd').format(date) : null);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? 'Ajouter une transaction' : 'Modifier la transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Montant'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date (AAAA-MM-JJ)'),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final title = _titleController.text;
              final amount = double.tryParse(_amountController.text) ?? 0;
              final date = DateFormat('yyyy-MM-dd').parse(_dateController.text);

              if (id == null) {
                addTransaction(title, amount, date);
              } else {
                _editTransaction(id, title, amount, date);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      // Suppression de l'AppBar ici, car il est déjà géré dans MainLayout
      body: Column(
        children: [
          // Barre de recherche et bouton de tri
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Barre de recherche
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase(); // Recherche insensible à la casse
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Bouton de tri
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.sort, weight: 900), // Icône de tri en gras
                    onPressed: () {
                      showMenu(
                        context: context,
                        position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                        items: [
                          PopupMenuItem(
                            value: 'date',
                            child: const Text('Trier par date'),
                            onTap: () {
                              setState(() {
                                _sortBy = 'date';
                                _sortAscending = !_sortAscending;
                              });
                            },
                          ),
                          PopupMenuItem(
                            value: 'amount',
                            child: const Text('Trier par montant'),
                            onTap: () {
                              setState(() {
                                _sortBy = 'amount';
                                _sortAscending = !_sortAscending;
                              });
                            },
                          ),
                          PopupMenuItem(
                            value: 'week',
                            child: const Text('Trier par semaine'),
                            onTap: () {
                              setState(() {
                                _sortBy = 'week';
                                _sortAscending = !_sortAscending;
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Corps de la page
          Expanded(
            child: user == null
                ? const Center(child: Text('Veuillez vous connecter pour voir les transactions.'))
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('transactions')
                        .orderBy(_sortBy, descending: !_sortAscending)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final transactions = snapshot.data!.docs;
                      // Filtrer les transactions en fonction de la recherche
                      final filteredTransactions = transactions.where((t) {
                        final title = t['title'].toString().toLowerCase();
                        return title.contains(_searchQuery.toLowerCase());
                      }).toList();

                      return Column(
                        children: [
                          Chart(recentTransactions: filteredTransactions),
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final t = filteredTransactions[index];
                                final title = t['title'];
                                final amount = t['amount'];
                                final date = (t['date'] as Timestamp).toDate();

                                return FadeTransition(
                                  opacity: _animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(-1, 0),
                                      end: Offset.zero,
                                    ).animate(_animationController),
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: const Color.fromARGB(255, 27, 86, 90),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: FittedBox(
                                              child: Text(
                                                '${amount.toStringAsFixed(0)} F',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        subtitle: Text(DateFormat('MMM dd, yyyy').format(date)),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              color: Colors.blue,
                                              icon: const Icon(Icons.edit),
                                              onPressed: () => _showTransactionForm(
                                                id: t.id,
                                                title: title,
                                                amount: amount,
                                                date: date,
                                              ),
                                            ),
                                            IconButton(
                                              color: Colors.red,
                                              icon: const Icon(Icons.delete),
                                              onPressed: () => _deleteTransaction(t.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}