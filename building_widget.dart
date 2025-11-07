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
        body: PaddedText(),
      ),
    );
  }
}

class PaddedText extends StatelessWidget {
  final String _mensagem = 'Olá, Mundo!';
  const PaddedText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("$_mensagem"),
    );
  }
}

