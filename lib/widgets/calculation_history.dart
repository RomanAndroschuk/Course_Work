import 'db.dart';
import 'package:flutter/material.dart';

class CalculationHistory extends StatefulWidget {
  final int userId;

  CalculationHistory({required this.userId});

  @override
  State<CalculationHistory> createState() => _CalculationHistoryState();
}

class _CalculationHistoryState extends State<CalculationHistory> {
  List<Map<String, dynamic>> _history = [];
  DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _fetchCalculationHistory();
  }

  Future<void> _fetchCalculationHistory() async {
    final history = await _databaseService.getUserCalculations(widget.userId);
    setState(() {
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculation History"),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: _history.isEmpty
          ? const Center(child: Text("No calculation history available."))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final calculation = _history[index];
                return ListTile(
                  title: Text(calculation['expression']),
                );
              },
            ),
    );
  }
}
