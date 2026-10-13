import 'package:flutter/material.dart';

import 'widgets/calculator_button.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      // Mantém a paleta padrão do Material 3 do Flutter.
      theme: ThemeData(useMaterial3: true),
      home: const CalculadoraPage(),
    );
  }
}

class CalculadoraPage extends StatefulWidget {
  const CalculadoraPage({super.key});

  @override
  State<CalculadoraPage> createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  String _visor = '0';
  double? _primeiroNumero;
  String? _operador;
  bool _iniciarNovoNumero = false;

  void _pressionarNumero(String numero) {
    setState(() {
      if (_iniciarNovoNumero || _visor == '0') {
        _visor = numero;
        _iniciarNovoNumero = false;
      } else if (_visor.length < 15) {
        _visor += numero;
      }
    });

    debugPrint('Número recebido pela calculadora: $numero');
  }

  void _pressionarDecimal() {
    setState(() {
      if (_iniciarNovoNumero) {
        _visor = '0.';
        _iniciarNovoNumero = false;
      } else if (!_visor.contains('.')) {
        _visor += '.';
      }
    });
  }

  void _pressionarOperador(String operador) {
    final numeroAtual = double.tryParse(_visor);
    if (numeroAtual == null) return;

    if (_primeiroNumero != null && _operador != null && !_iniciarNovoNumero) {
      final resultado = _calcular(_primeiroNumero!, numeroAtual, _operador!);
      if (resultado == null) {
        _mostrarErroDivisaoPorZero();
        return;
      }
      setState(() {
        _visor = _formatar(resultado);
        _primeiroNumero = resultado;
        _operador = operador;
        _iniciarNovoNumero = true;
      });
      return;
    }

    setState(() {
      _primeiroNumero = numeroAtual;
      _operador = operador;
      _iniciarNovoNumero = true;
    });
  }

  void _pressionarIgual() {
    if (_primeiroNumero == null || _operador == null) return;

    final segundoNumero = double.tryParse(_visor);
    if (segundoNumero == null) return;

    final resultado = _calcular(_primeiroNumero!, segundoNumero, _operador!);
    if (resultado == null) {
      _mostrarErroDivisaoPorZero();
      return;
    }

    setState(() {
      _visor = _formatar(resultado);
      _primeiroNumero = null;
      _operador = null;
      _iniciarNovoNumero = true;
    });
  }

  double? _calcular(double primeiro, double segundo, String operador) {
    switch (operador) {
      case '+':
        return primeiro + segundo;
      case '−':
        return primeiro - segundo;
      case '×':
        return primeiro * segundo;
      case '÷':
        return segundo == 0 ? null : primeiro / segundo;
      default:
        return null;
    }
  }

  String _formatar(double numero) {
    if (!numero.isFinite) return 'Erro';
    final texto = numero.toStringAsFixed(8).replaceFirst(RegExp(r'\.?0+$'), '');
    return texto == '-0' ? '0' : texto;
  }

  void _mostrarErroDivisaoPorZero() {
    setState(() {
      _visor = '0';
      _primeiroNumero = null;
      _operador = null;
      _iniciarNovoNumero = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Não é possível dividir por zero.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _limpar() {
    setState(() {
      _visor = '0';
      _primeiroNumero = null;
      _operador = null;
      _iniciarNovoNumero = false;
    });
  }

  void _limparEntrada() {
    setState(() {
      _visor = '0';
      _iniciarNovoNumero = false;
    });
  }

  void _apagarUltimoDigito() {
    setState(() {
      if (_iniciarNovoNumero) return;
      if (_visor.length == 1 || (_visor.length == 2 && _visor.startsWith('-'))) {
        _visor = '0';
      } else {
        _visor = _visor.substring(0, _visor.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final linhasDeBotoes = <List<Widget>>[
      [
        CalculatorButton(label: 'AC', kind: CalculatorButtonKind.utility, onPressed: _limpar),
        CalculatorButton(label: '⌫', kind: CalculatorButtonKind.utility, onPressed: _apagarUltimoDigito),
        CalculatorButton(label: 'CE', kind: CalculatorButtonKind.utility, onPressed: _limparEntrada),
        CalculatorButton(label: '÷', kind: CalculatorButtonKind.operator, onPressed: () => _pressionarOperador('÷')),
      ],
      [
        _numero('7'), _numero('8'), _numero('9'),
        CalculatorButton(label: '×', kind: CalculatorButtonKind.operator, onPressed: () => _pressionarOperador('×')),
      ],
      [
        _numero('4'), _numero('5'), _numero('6'),
        CalculatorButton(label: '−', kind: CalculatorButtonKind.operator, onPressed: () => _pressionarOperador('−')),
      ],
      [
        _numero('1'), _numero('2'), _numero('3'),
        CalculatorButton(label: '+', kind: CalculatorButtonKind.operator, onPressed: () => _pressionarOperador('+')),
      ],
      [
        CalculatorButton(
          label: '00',
          onPressed: () {
            _pressionarNumero('0');
            _pressionarNumero('0');
          },
        ),
        _numero('0'),
        CalculatorButton(label: ',', onPressed: _pressionarDecimal),
        CalculatorButton(label: '=', kind: CalculatorButtonKind.equals, onPressed: _pressionarIgual),
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: SingleChildScrollView(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (_operador != null && _primeiroNumero != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '${_formatar(_primeiroNumero!)} $_operador',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            Text(
                              _visor.replaceAll('.', ','),
                              maxLines: 1,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final linha in linhasDeBotoes)
                    Expanded(
                      child: Row(
                        children: [
                          for (final botao in linha)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: botao,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numero(String numero) {
    return CalculatorButton(
      label: numero,
      onPressed: () => _pressionarNumero(numero),
    );
  }
}
