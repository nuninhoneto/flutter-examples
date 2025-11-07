import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Widget raiz
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Minha Página Inicial'),
        ),
        body: Center(
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  const Text('Olá, Mundo!'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print('Clique!');
                    },
                    child: const Text('Um botão'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}