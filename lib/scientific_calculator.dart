import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'constants.dart';

class ScientificCalculator extends StatefulWidget {
  final VoidCallback toggleTheme;
  const ScientificCalculator({super.key, required this.toggleTheme});

  @override
  ScientificCalculatorState createState() => ScientificCalculatorState();
}

class ScientificCalculatorState extends State<ScientificCalculator> {
  String expression = '0';
  String result = '0';
  bool isScientificMode = false;
  bool isScientificModeShift = false;

  late TextEditingController _expressionController;

  @override
  void initState() {
    super.initState();
    _expressionController = TextEditingController(text: expression);
  }

  @override
  void dispose() {
    _expressionController.dispose();
    super.dispose();
  }

  void onButtonPressed(String text) {
    setState(() {
      if (text == 'C') {
        expression = '0';
        result = '0';
      } else if (text == 'backspace') {
        if (expression.length == 1) {
          expression = '0';
        } else {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (text == '=') {
        try {
          Parser p = Parser();
          Expression exp = p.parse(expression
              .replaceAll('×', '*')
              .replaceAll('÷', '/')
              .replaceAll('π', pi)
              .replaceAll('e', e_num)
              .replaceAll('√', 'sqrt')
              .replaceAllMapped(
                RegExp(r'INV\((\d+(\.\d+)?)\)'),
                (match) => '(${match.group(1)})^(-1)',
              ));
          ContextModel cm = ContextModel();
          result = '${exp.evaluate(EvaluationType.REAL, cm)}';
        } catch (e) {
          result = 'Error';
        }
      } else if (text == 'shift') {
        toggleScientificModeShift();
      } else {
        if (expression == '0') {
          expression = text;
        } else {
          expression += text;
        }
      }
      _expressionController.text = expression;
    });
  }

  void toggleScientificMode() {
    setState(() {
      isScientificMode = !isScientificMode;
    });
  }

  void toggleScientificModeShift() {
    setState(() {
      isScientificModeShift = !isScientificModeShift;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific Calculator'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                      controller: _expressionController,
                      style: const TextStyle(fontSize: 24, color: Colors.grey),
                      onChanged: (value) {
                        setState(() {
                          expression = value;
                        });
                      },
                      textAlign: TextAlign.right),
                  const SizedBox(height: 10),
                  Text(
                    result,
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: toggleScientificMode,
                child: Text(isScientificMode ? 'Basic' : 'Scientific'),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                if (isScientificMode && !isScientificModeShift)
                  _buildScientificKeyboard(),
                if (isScientificMode && isScientificModeShift)
                  _buildScientificKeyboardShift(),
                _buildBasicKeyboard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicKeyboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('7'),
            _buildButton('8'),
            _buildButton('9'),
            _buildButton('÷')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('4'),
            _buildButton('5'),
            _buildButton('6'),
            _buildButton('×')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('1'),
            _buildButton('2'),
            _buildButton('3'),
            _buildButton('-')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('0'),
            _buildButton('.'),
            _buildButton('='),
            _buildButton('+')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('C'),
            _buildButton('backspace', icon: Icons.backspace)
          ],
        ),
      ],
    );
  }

  Widget _buildScientificKeyboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('sin'),
            _buildButton('cos'),
            _buildButton('tan'),
            _buildButton('shift',
                icon: Icons.filter_tilt_shift, bgColor: Colors.green)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('√'),
            _buildButton('^'),
            _buildButton('!'),
            _buildButton('π')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('('),
            _buildButton(')'),
            _buildButton('log'),
            _buildButton('e')
          ],
        ),
      ],
    );
  }

  Widget _buildScientificKeyboardShift() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('arcsin'),
            _buildButton('arccos'),
            _buildButton('arctan'),
            _buildButton('shift',
                icon: Icons.filter_tilt_shift, bgColor: Colors.red)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('sinh'),
            _buildButton('cosh'),
            _buildButton('tanh'),
            _buildButton('smtg')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('%'),
            _buildButton('abs'),
            _buildButton('ln'),
            _buildButton('INV')
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String text, {IconData? icon, Color? bgColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: bgColor ?? Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1.0),
            ),
          ),
          child: icon != null
              ? Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                )
              : Text(
                  text,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
        ),
      ),
    );
  }
}
