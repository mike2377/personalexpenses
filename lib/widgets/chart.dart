import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chart extends StatefulWidget {
  final List<QueryDocumentSnapshot> recentTransactions;

  const Chart({Key? key, required this.recentTransactions}) : super(key: key);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = [];
    _animations = [];

    // Initialiser les animations pour chaque barre
    for (int i = 0; i < groupedTransactionValues.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 150), // Animation plus rapide
        vsync: this,
      );

      final animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );

      _animationControllers.add(controller);
      _animations.add(animation);

      // Démarrer l'animation avec un délai basé sur l'index
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Map<String, Object>> get groupedTransactionValues {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Commence par lundi

    return List.generate(7, (index) {
      final weekDay = startOfWeek.add(Duration(days: index)); // Ajoute les jours pour obtenir chaque jour de la semaine
      double totalSum = 0.0;

      for (var tx in widget.recentTransactions) {
        final txDate = (tx['date'] as Timestamp).toDate();
        if (txDate.day == weekDay.day &&
            txDate.month == weekDay.month &&
            txDate.year == weekDay.year) {
          totalSum += tx['amount'];
        }
      }

      return {
        'day': DateFormat.E().format(weekDay).substring(0, 1), // Initiale du jour
        'amount': totalSum,
        'fullDay': DateFormat.E().format(weekDay), // Nom complet du jour
      };
    });
  }

  double get maxSpending {
    return groupedTransactionValues.fold(0.0, (sum, item) {
      return sum + (item['amount'] as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Résumé des dépenses
            _buildSummary(),
            const SizedBox(height: 10),
            // Légende des couleurs
            _buildLegend(),
            const SizedBox(height: 10),
            // Graphique
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: groupedTransactionValues.asMap().entries.map((entry) {
                final index = entry.key; // Index de l'élément
                final data = entry.value; // Données de l'élément
                final dayAmount = data['amount'] as double;
                final barHeightFactor =
                    maxSpending == 0 ? 0.0 : dayAmount / maxSpending;

                return Flexible(
                  fit: FlexFit.tight,
                  child: MouseRegion(
                    onEnter: (_) => _showTooltip(context, data),
                    child: Column(
                      children: [
                        FittedBox(
                          child: Text(
                            maxSpending == 0
                                ? '0 F'
                                : '${dayAmount.toStringAsFixed(0)} F',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color.fromARGB(255, 27, 86, 90),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedBuilder(
                          animation: _animations[index],
                          builder: (context, child) {
                            return Container(
                              height: 100 * _animations[index].value,
                              width: 15,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: FractionallySizedBox(
                                heightFactor: barHeightFactor,
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getBarColor(dayAmount),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.3),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['day'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour obtenir la couleur de la barre en fonction du montant
  Color _getBarColor(double amount) {
    if (amount <= 0) {
      return Colors.grey; // Si le montant est nul ou négatif
    } else if (amount < 5000) {
      return const Color.fromARGB(255, 12, 202, 43); // Montant faible
    } else if (amount < 10000) {
      return const Color.fromARGB(255, 228, 213, 8); // Montant moyen
    } else {
      return const Color.fromARGB(255, 194, 16, 16); // Montant élevé
    }
  }

  // Fonction pour afficher un résumé des dépenses
  Widget _buildSummary() {
    final totalSpending = groupedTransactionValues.fold(0.0, (sum, item) {
      return sum + (item['amount'] as double);
    });

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total des dépenses cette semaine :',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Text(
            '${totalSpending.toStringAsFixed(0)} F',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.fromARGB(255, 27, 86, 90),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour afficher une légende des couleurs
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Faible', const Color.fromARGB(255, 12, 202, 43)),
        _buildLegendItem('Moyen', const Color.fromARGB(255, 228, 213, 8)),
        _buildLegendItem('Élevé', const Color.fromARGB(255, 194, 16, 16)),
      ],
    );
  }

  // Fonction pour construire un élément de légende
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

  // Fonction pour afficher une infobulle au survol
  void _showTooltip(BuildContext context, Map<String, Object> data) {
    final day = data['fullDay'] as String;
    final amount = data['amount'] as double;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100, // Ajustez la position selon vos besoins
        left: 100, // Ajustez la position selon vos besoins
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              '$day: ${amount.toStringAsFixed(0)} F',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Supprimer l'infobulle après un délai
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}