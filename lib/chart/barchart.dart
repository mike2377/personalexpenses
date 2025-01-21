import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personalexpensesapp/models/transaction.dart';


class Chart extends StatelessWidget {
  final List<Transaction> recentTransactions;

  const Chart({Key? key, required this.recentTransactions}) : super(key: key);

  List<Map<String, Object>> get groupedTransactionValues {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(Duration(days: index));
      double totalSum = 0.0;

      for (var tx in recentTransactions) {
        if (tx.date.day == weekDay.day &&
            tx.date.month == weekDay.month &&
            tx.date.year == weekDay.year) {
          totalSum += tx.amount;
        }
      }

      return {
        'day': DateFormat.E().format(weekDay).substring(0, 1), // Ex: "M", "T"
        'amount': totalSum,
      };
    }).reversed.toList(); // Réverser pour commencer par le jour actuel
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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: groupedTransactionValues.map((data) {
            final dayAmount = data['amount'] as double;
            final barHeightFactor = maxSpending == 0 ? 0.0 : dayAmount / maxSpending;

            return Flexible(
              fit: FlexFit.tight,
              child: Column(
                children: [
                  FittedBox(
                    child: Text(
                      maxSpending == 0
                          ? '\$'
                          : '\$${dayAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 60,
                    width: 10,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300], // Couleur par défaut pour les barres
                    ),
                    child: FractionallySizedBox(
                      heightFactor: barHeightFactor,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: dayAmount > 0 ? Colors.purple : Colors.transparent, // Violet si montant > 0
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['day'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
