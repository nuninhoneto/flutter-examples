import 'package:flutter/material.dart';

void main() => runApp(
      const MaterialApp(
        home: WidgetPai(),
      ),
    );

class WidgetPai extends StatefulWidget {
  const WidgetPai({super.key});

  @override
  State<WidgetPai> createState() => _EstadoWidgetPai();
}

class _EstadoWidgetPai extends State<WidgetPai> {
  int _contador = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Estado por Callbacks"),
      ),
      body: Center(
        child: WidgetFilho(
          contador: _contador,
          onCounterChanged: (int novoValor) {
            setState(() {
              _contador = novoValor;
            });
          },
        ),
      ),
    );
  }
}

class WidgetFilho extends StatelessWidget {
  final int contador;
  final ValueChanged<int> onCounterChanged;

  const WidgetFilho(
      {super.key, required this.contador, required this.onCounterChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Contador no WidgetFilho:',
        ),
        Text(
          '$contador',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        ElevatedButton(
          onPressed: () {
            onCounterChanged(contador + 1);
          },
          child: const Text('Incrementar'),
        ),
      ],
    );
  }
}