import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:personalexpensesapp/widgets/chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Dashboard'),
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to view the dashboard.'))
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
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Nombre de colonnes dans la grille
                          crossAxisSpacing: 10, // Espacement horizontal entre les éléments
                          mainAxisSpacing: 10, // Espacement vertical entre les éléments
                          childAspectRatio: 1.5, // Ratio largeur/hauteur des éléments
                        ),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          final title = t['title'];
                          final amount = t['amount'];
                          final date = (t['date'] as Timestamp).toDate();

                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${amount.toStringAsFixed(0)} Fcfa',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(date),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
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