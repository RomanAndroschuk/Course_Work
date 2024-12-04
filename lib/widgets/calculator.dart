import 'dart:math';
import 'calculation_history.dart';
import 'db.dart';
import 'package:flutter/material.dart';

class Calculator extends StatelessWidget {
  Calculator({super.key, required this.userId});
  final int userId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fancy Calculator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: CalculatorScreen(userId: userId), 
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key, required this.userId});
  final int userId;

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _operand = '';
  double _firstNum = 0;
  double _secondNum = 0;
  bool _shouldClear = false;
  final DatabaseService _databaseService = DatabaseService.instance;

  void _inputNumber(String number) {
    setState(() {
      if (_display.length < 10) {
        if (_shouldClear) {
          _display = number;
          _shouldClear = false;
        } else {
          if (number == '.' && _display.contains('.')) {
            return; 
          }
          _display = _display == '0' && number != '.' ? number : _display + number;
        }
      }
    });
  }

  void _inputOperand(String operand) {
    setState(() {
      _firstNum = double.parse(_display);
      _operand = operand;
      _shouldClear = true;
    });
  }

  void _calculateResult() async {
    setState(() {
      _secondNum = double.parse(_display);
      double result;

      switch (_operand) {
        case '+':
          result = _firstNum + _secondNum;
          break;
        case '-':
          result = _firstNum - _secondNum;
          break;
        case '×':
          result = _firstNum * _secondNum;
          break;
        case '÷':
          result = _secondNum != 0 ? _firstNum / _secondNum : 0;
          break;
        default:
          result = 0;
      }

      _display = result % 1 == 0 ? result.toInt().toString() : result.toString();
      _shouldClear = true;
    });

    await _databaseService.addCalculation(widget.userId, "$_firstNum $_operand $_secondNum = $_display");
  }

  void _clearDisplay() {
    setState(() {
      _display = '0';
      _operand = '';
      _firstNum = 0;
      _secondNum = 0;
      _shouldClear = false;
    });
  }

  void _calculatePercentage() {
    setState(() {
      double result = (double.parse(_display) / 100);
      _display = result % 1 == 0 ? result.toInt().toString() : result.toString();
      _shouldClear = true;
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display != '0') {
        _display = _display.startsWith('-') ? _display.substring(1) : '-' + _display;
      }
    });
  }

  void _insertPi() {
    setState(() {
      _display = pi.toStringAsFixed(6); 
      _shouldClear = true;
    });
  }

  Widget _buildButton(String label, {Color? color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Colors.deepPurple,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        width: 70,
        height: 70,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalculationHistory(userId: widget.userId),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 190, 190, 190),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  _display,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildButtonRow(['C','+/-','%', 'π'], Colors.orange),
            const SizedBox(height: 10),
            _buildButtonRow(['7', '8', '9', '÷'], Colors.orange),
            const SizedBox(height: 10),
            _buildButtonRow(['4', '5', '6', '×'], Colors.orange),
            const SizedBox(height: 10),
            _buildButtonRow(['1', '2', '3', '-'], Colors.orange),
            const SizedBox(height: 10),
            _buildButtonRow(['0', '.', '=', '+'], Colors.orange),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons.map((String label) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: label == 'C'
              ? _buildButton(label, color: Colors.red, onTap: _clearDisplay)
              : label == '='
                  ? _buildButton(label, color: Colors.green, onTap: _calculateResult)
                  : label == '+/-'
                      ? _buildButton(label, color: color, onTap: _toggleSign)
                      : label == '%'
                          ? _buildButton(label, color: color, onTap: _calculatePercentage)
                          : label == 'π'
                              ? _buildButton(label, color: color, onTap: _insertPi)
                              : ['+', '-', '×', '÷'].contains(label)
                                  ? _buildButton(label, color: color, onTap: () => _inputOperand(label))
                                  : _buildButton(label, onTap: () => _inputNumber(label)),
        );
      }).toList(),
    );
  }
}
