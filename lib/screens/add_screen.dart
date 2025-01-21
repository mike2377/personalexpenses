import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddScreen extends StatefulWidget {

    final void Function(String title, double amount, DateTime date) addTransaction;
    const AddScreen({super.key, required this.addTransaction});

    @override
    State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {

    //variable por controler le title, amount, date

    final _title = TextEditingController();
    final _amount = TextEditingController();
    DateTime? _selectedDate;

    void _valider() {
        
        //verifier en envoyer les donner du formulaire
        final title = _title.text;
        final amount = double.tryParse(_amount.text);
        if (title.isEmpty || amount == null || _selectedDate == null) {
            return;
        }

        //rei,itialise le formlaire et le fermer 
        widget.addTransaction(title, amount, _selectedDate!);
        _title.clear();
        _amount.clear();
        _selectedDate = null;
        Navigator.pop(context);

    }

    void datePicker(){
        showDatePicker(
            context: context,
            initialDate: _selectedDate,
            //date a partir de 2023
            firstDate: DateTime(2023),
            //date actuel
            lastDate: DateTime.now(),
        ).then((value) {
          //recuper la date selectionner
            if (value!= null) {
                _selectedDate = value;
            }
        });
    }


    @override
    Widget build(BuildContext context) {
      //formulaire pour ajout de transactions
      return Card(
        elevation: 5,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                //textfield pour title et amont
                TextField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                    controller: _amount,
                    decoration: const InputDecoration(labelText: 'Amount'
                    ),

                ),
                const Spacer(),

                //ligne pour le choix de la date
                Row(
                    children: [
                    const Text('Date Chosen '),
                    Expanded(

                      //permet de selectinner la date par la fonction datePicker
                        child: GestureDetector(
                            onTap: datePicker,

                            //style du bouton permettant de selectionner la date
                            child: Text(
                                _selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(_selectedDate!) // Formatage de la date
                                : 'Choose Date',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                ),
                                textAlign: TextAlign.end,
                            ),
                            
                        ),
                    ),
                    ],
                ),
                const SizedBox(height: 16.0),
                
                //bouton pour ajouter les transactions
                ElevatedButton(
                    onPressed: _valider,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                    ),
                    child: const Text(
                        'Add Transaction',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                        ),
                    ),
                ),
                ],
            ),
        ),

      );
    }
}