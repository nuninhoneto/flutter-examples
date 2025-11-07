import 'package:flutter/material.dart';

// --- UI ---

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PaginaContador(),
    );
  }
}

class PaginaContador extends StatefulWidget {
  const PaginaContador({super.key});

  @override
  State<PaginaContador> createState() => _EstadoPaginaContador();
}

class _EstadoPaginaContador extends State<PaginaContador> {
  // Passo 1: Usar ValueNotifier para um único valor.
  // Ele já implementa o padrão Notifier, então não precisamos de uma classe customizada.
  // O valor inicial (0) é passado no construtor.
  final ValueNotifier<int> _contador = ValueNotifier<int>(0);

  @override
  void dispose() {
    // É uma boa prática dar dispose nos notifiers para liberar recursos.
    _contador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exemplo com ValueNotifier')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Você pressionou o botão esta quantidade de vezes:'),
            // Passo 2: Usar `ValueListenableBuilder` para ouvir o `ValueNotifier`.
            // Ele é otimizado para `ValueNotifier` e já nos dá o valor atual no builder.
            ValueListenableBuilder<int>(
              valueListenable: _contador,
              builder: (BuildContext context, int valor, Widget? child) {
                // O `builder` é chamado sempre que o valor do notifier muda.
                return MeuTexto(contador: valor);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Passo 3: Para alterar o estado, basta modificar a propriedade `.value`.
        // Isso notificará automaticamente os listeners (como o ValueListenableBuilder).
        onPressed: () => _contador.value++,
        tooltip: 'Incrementar',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MeuTexto extends StatelessWidget {
  final int contador;

  const MeuTexto({super.key, required this.contador});

  @override
  Widget build(BuildContext context) {
     return Text(
                  '$contador',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
  }
}