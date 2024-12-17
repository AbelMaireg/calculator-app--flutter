import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'package:app/constants.dart';

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
  final List<(int, String)> history = [
    (1, pi.toString().substring(0, 10)),
    (2, e_num.toString().substring(0, 10))
  ];
  int historyId = 3;

  Color basicOps = Colors.lightBlue;
  Color sciOps = const Color.fromRGBO(13, 60, 125, 1);

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
          setState(() {
            historyId += 1;
            history.add((historyId, result));
          });
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
        title: const Text('Calculator'),
        centerTitle: true,
        backgroundColor: sciOps,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_2),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: Column(
              children: history.reversed.take(2).map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            history.removeWhere((fi) => item.$1 == fi.$1);
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.$2));
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.input),
                        onPressed: () {
                          expression = item.$2;
                          _expressionController.text = item.$2;
                        },
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          item.$2,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
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
            _buildButton('÷', bgColor: basicOps)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('4'),
            _buildButton('5'),
            _buildButton('6'),
            _buildButton('×', bgColor: basicOps)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('1'),
            _buildButton('2'),
            _buildButton('3'),
            _buildButton('-', bgColor: basicOps)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('0'),
            _buildButton('.'),
            _buildButton('='),
            _buildButton('+', bgColor: basicOps)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('C', icon: Icons.clear),
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
            _buildButton('%', bgColor: sciOps),
            _buildButton('abs', bgColor: sciOps),
            _buildButton('ln', bgColor: sciOps),
            _buildButton('shift',
                icon: Icons.filter_tilt_shift, bgColor: Colors.green)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('√', bgColor: sciOps),
            _buildButton('^', bgColor: sciOps),
            _buildButton('INV', bgColor: sciOps),
            _buildButton('π', bgColor: sciOps)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('(', bgColor: sciOps),
            _buildButton(')', bgColor: sciOps),
            _buildButton('log', bgColor: sciOps),
            _buildButton('e', bgColor: sciOps)
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
            _buildButton('sin', bgColor: sciOps),
            _buildButton('cos', bgColor: sciOps),
            _buildButton('tan', bgColor: sciOps),
            _buildButton('shift',
                icon: Icons.filter_tilt_shift, bgColor: Colors.red)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('arcsin', bgColor: sciOps),
            _buildButton('arccos', bgColor: sciOps),
            _buildButton('arctan', bgColor: sciOps),
            _buildButton('smtg', bgColor: sciOps)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('csc', bgColor: sciOps),
            _buildButton('sec', bgColor: sciOps),
            _buildButton('cot', bgColor: sciOps),
            _buildButton('!', bgColor: sciOps),
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
