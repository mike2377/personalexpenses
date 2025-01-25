class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category; // Ajout du champ category

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category = 'Autre', // Valeur par défaut pour la catégorie
  });
}