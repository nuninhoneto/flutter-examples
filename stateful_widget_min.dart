import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Minha Página Inicial'),
        ),
        body: ContadorWidget(),
      ),
    );
  }
}

class ContadorWidget extends StatefulWidget {
  const ContadorWidget({super.key});

  @override
  State<ContadorWidget> createState() => _ContadorWidgetState();
}

class _ContadorWidgetState extends State<ContadorWidget> {
  int _contador = 0;

  void _incrementar() {
    setState(() {
      _contador++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
              onPressed: _incrementar,
              child: Text('$_contador'),
            );
  }
}
