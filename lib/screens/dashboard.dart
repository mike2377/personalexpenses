import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:personalexpensesapp/widgets/chart.dart'; // Importez le fichier chart.dart
import 'package:fl_chart/fl_chart.dart'; // Pour le graphique en barres

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category = 'Autre',
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  String _currentDateTime = ''; // Pour afficher la date et l'heure en temps réel
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Mettre à jour la date et l'heure en temps réel
    _updateDateTime();

    // Initialisation de l'animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Démarrer l'animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Méthode pour mettre à jour la date et l'heure
  void _updateDateTime() {
    setState(() {
      _currentDateTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    });

    // Mettre à jour toutes les secondes
    Future.delayed(const Duration(seconds: 1), _updateDateTime);
  }

  // Convertit un DocumentSnapshot en objet Transaction
  Transaction _transactionFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      title: data['title'],
      amount: data['amount'],
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? 'Autre',
    );
  }

  // Méthode pour obtenir la première lettre du jour de la semaine
  String _getDayOfWeekAbbreviation(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'L'; // Lundi
      case 2:
        return 'M'; // Mardi
      case 3:
        return 'M'; // Mercredi
      case 4:
        return 'J'; // Jeudi
      case 5:
        return 'V'; // Vendredi
      case 6:
        return 'S'; // Samedi
      case 7:
        return 'D'; // Dimanche
      default:
        return '';
    }
  }

  // Fonction pour obtenir la couleur en fonction du montant des dépenses
  Color _getBarColor(double amount) {
    if (amount <= 5000) {
      return Colors.green; // Faible
    } else if (amount <= 10000) {
      return Colors.orange; // Moyen
    } else {
      return Colors.red; // Élevé
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final user = _auth.currentUser;

    return Scaffold(
      body: user == null
          ? const Center(
              child:
                  Text('Veuillez vous connecter pour voir le tableau de bord.'))
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
                final transactions =
                    snapshot.data!.docs.map(_transactionFromFirestore).toList();

                // Calcul des statistiques
                double totalExpenses = 0;
                int transactionCount = transactions.length;

                // Grouper les dépenses par jour de la semaine (avec abréviations)
                Map<String, double> weeklyExpenses = {
                  'L': 0, // Lundi
                  'M': 0, // Mardi
                  'M': 0, // Mercredi
                  'J': 0, // Jeudi
                  'V': 0, // Vendredi
                  'S': 0, // Samedi
                  'D': 0, // Dimanche
                };

                for (var t in transactions) {
                  totalExpenses += t.amount;
                  String dayAbbreviation = _getDayOfWeekAbbreviation(t.date);
                  weeklyExpenses[dayAbbreviation] =
                      (weeklyExpenses[dayAbbreviation] ?? 0) + t.amount;
                }

                double averageExpense =
                    transactionCount > 0 ? totalExpenses / transactionCount : 0;

                // Liste ordonnée des jours de la semaine
                final List<String> orderedDays = [
                  'L',
                  'M',
                  'M',
                  'J',
                  'V',
                  'S',
                  'D'
                ];

                // Données pour l'histogramme des dépenses par jour de la semaine
                List<BarChartGroupData> weeklyBarData =
                    orderedDays.asMap().entries.map((entry) {
                  int index = entry.key;
                  String day = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: weeklyExpenses[day] ?? 0,
                        color: _getBarColor(weeklyExpenses[day] ?? 0),
                        width: 20,
                        borderRadius: BorderRadius.circular(5),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100000, // Hauteur maximale fixée à 100 000
                          color: Colors.grey[200],
                        ),
                      ),
                    ],
                  );
                }).toList();

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Affichage de la date et de l'heure en temps réel
                        FadeTransition(
                          opacity: _animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: Text(
                              _currentDateTime,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 27, 86, 90),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Ajout du composant Chart ici
                        FadeTransition(
                          opacity: _animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: Chart(
                              recentTransactions: snapshot.data!.docs,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),


                        // Statistiques résumées sous forme de grille
                        FadeTransition(
                          opacity: _animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2, // Nombre de colonnes
                              crossAxisSpacing: 10, // Espacement horizontal
                              mainAxisSpacing: 10, // Espacement vertical
                              childAspectRatio: 1.5, // Ratio largeur/hauteur
                              children: [
                                _buildStatisticCard(
                                    'Total des Dépenses',
                                    '${totalExpenses.toStringAsFixed(0)} Fcfa',
                                    Icons.attach_money),
                                _buildStatisticCard('Nombre de Transactions',
                                    '$transactionCount', Icons.list),
                                _buildStatisticCard(
                                    'Dépense Moyenne',
                                    '${averageExpense.toStringAsFixed(0)} Fcfa',
                                    Icons.trending_up),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),



                        // Titre du graphique en barres
                        FadeTransition(
                          opacity: _animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: const Text(
                              'Graphe des dépenses par Jour de la Semaine',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Légende des couleurs
                        FadeTransition(
                          opacity: _animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: _buildLegend(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Graphique en barres amélioré
                        FadeTransition(
                          opacity: _animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: SizedBox(
                              height: 300, // Hauteur du graphique
                              child: BarChart(
                                BarChartData(
                                  barGroups: weeklyBarData,
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 10000,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey[300],
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 10000,
                                        reservedSize: 40,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              '${(value ~/ 1000).toInt()}k',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              orderedDays[value.toInt()],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: false,
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: false,
                                      ),
                                    ),
                                  ),
                                  barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          '${rod.toY.toInt()} Fcfa',
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  maxY: 100000, // Valeur maximale de l'axe des Y
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Liste des transactions
                        FadeTransition(
                          opacity: _animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: const Text(
                              'Dernières Transactions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final t = transactions[index];
                            return FadeTransition(
                              opacity: _animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(-1, 0),
                                  end: Offset.zero,
                                ).animate(_animationController),
                                child: Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.money_off,
                                        color: Color.fromARGB(255, 27, 86, 90)),
                                    title: Text(
                                      t.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${DateFormat('MMM dd, yyyy').format(t.date)} - ${t.category}',
                                    ),
                                    trailing: Text(
                                      '${t.amount.toStringAsFixed(0)} Fcfa',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 27, 86, 90),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Widget pour afficher une légende des couleurs
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Faible', Colors.green),
        _buildLegendItem('Moyen', Colors.orange),
        _buildLegendItem('Élevé', Colors.red),
      ],
    );
  }

  // Widget pour construire un élément de légende
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Widget pour afficher une carte de statistique
  Widget _buildStatisticCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Color.fromARGB(255, 27, 86, 90)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 27, 86, 90),
              ),
            ),
          ],
        ),
      ),
    );
  }
}