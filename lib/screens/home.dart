import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personalexpensesapp/models/transaction.dart';
import 'package:personalexpensesapp/screens/add_screen.dart';
import 'package:personalexpensesapp/chart/barchart.dart';

//page d'acceil affichant le chart des transaction et les transacction ajoute

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //liste de transaction vide
  final List<Transaction> _transaction = [];

  //fonction pour ajouter ne transaction
  void _addTransaction(String title, double amount, DateTime date) {
    setState(() {
      _transaction.add(Transaction(
        //convertit la date en chaine de caractere por l'tiliser comme id
          id: DateTime.now().toString(), 
          title: title, 
          amount: amount, 
          date: date
        )
      );
    });
  }

  //spprimer ne transaction a partir de son id
  void _deleteTransaction(String id) {
    setState(() {
      _transaction.removeWhere((transaction) => transaction.id == id);
      });

  }

  //fonction pour aficher le modal(formlaire pour ajouter transaction)
  void _newTransactionForm() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddScreen(
          addTransaction: _addTransaction,
          );
          }
          
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: const Text(
            "Personal Expenses",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            //bouton '+'
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _newTransactionForm,
              color: Colors.white,
            ),
          ]
        ),
        body: Column(
          children: [
            //afficher le chart en barre
            Chart(
              recentTransactions: _transaction,
            ),
            
            Expanded(

              //permet d'ajouter plusieurs transaction rendre la page scrollable
                child: ListView.builder(
                    itemCount: _transaction.length,
                    itemBuilder: (context, index) {
                      final t = _transaction[index];

                      //card pour afficher les transactions 
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        //afficher les informations de la card
                        child: ListTile(

                          //cercle qui va contenir le montant
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.purple,
                            child:Padding(
                              padding: const EdgeInsets.all(5),
                              //adapte le montant afin qu'il puisse tenir dans le 'CircleAvatar'
                              child: FittedBox(
                                //afficher le montant
                                child: Text(
                                  '\$${t.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                              ),
                            )
                          ),
                          //afficher le titre de la transaction
                          title: Text(
                            t.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),

                          //afficher la date en dessos du titre
                          subtitle: Text(DateFormat('MMM dd, yyyy').format(t.date)),

                          //bouton pour supprimer ne transaction
                          trailing: IconButton(
                            color: Colors.red,
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteTransaction(t.id);
                            },
                          ),
                          ),
                      );
                    }))
          ],
        ),

        //bouton flottant pour afficher le formlaire d'ajout de transaction
        floatingActionButton: FloatingActionButton(
          onPressed: _newTransactionForm,
          child: const Icon(Icons.add),
        ));
  }
}
