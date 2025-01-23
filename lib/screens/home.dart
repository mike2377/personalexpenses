import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:personalexpensesapp/widgets/chart.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialisation de l'AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // Initialisation de l'animation
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    // Démarrage de l'animation
    _animationController.forward();
  }

  @override
  void dispose() {
    // Libération des ressources de l'AnimationController
    _animationController.dispose();
    super.dispose();
  }

  // Méthode publique pour ajouter une transaction
  void addTransaction(String title, double amount, DateTime date) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('transactions').add({
        'title': title,
        'amount': amount,
        'date': date,
      });
    }
  }

  void _deleteTransaction(String id) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Afficher une boîte de dialogue de confirmation
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

      // Si l'utilisateur confirme la suppression
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

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Personal Expenses'),
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to view transactions.'))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('transactions')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final transactions = snapshot.data!.docs;
                return Column(
                  children: [
                    Chart(recentTransactions: transactions),
                    Expanded(
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
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
                                    backgroundColor: Color.fromARGB(255, 27, 86, 90),
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
                                  trailing: IconButton(
                                    color: Colors.red,
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteTransaction(t.id),
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
    );
  }
}