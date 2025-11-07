import 'package:flutter/material.dart';

// Passo 1: Criar a classe que gerenciará o estado.
// Ela deve estender (ou usar o mixin) `ChangeNotifier`.
class ContadorNotifier extends ChangeNotifier {
  // O estado privado que queremos gerenciar.
  int _contador = 0;

  // Um getter público para que a UI possa ler o estado, mas não modificá-lo diretamente.
  int get contador => _contador;

  // Um método público para modificar o estado.
  void incrementar() {
    _contador++;
    // Passo 2: Notificar todos os "ouvintes" (listeners) que o estado mudou.
    // Widgets que usam `ListenableBuilder` serão reconstruídos.
    notifyListeners();
  }
}

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
  // Instanciamos nosso notifier. Em apps maiores, isso seria feito
  // por um `InheritedWidget` ou um pacote como `Provider`.
  final ContadorNotifier _contadorNotifier = ContadorNotifier();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exemplo com ChangeNotifier')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Você pressionou o botão esta quantidade de vezes:'),
            // Passo 3: Usar `ListenableBuilder` para ouvir o notifier.
            // Apenas o widget retornado pelo `builder` será reconstruído
            // quando `notifyListeners()` for chamado.
            ListenableBuilder(
              listenable: _contadorNotifier,
              builder: (BuildContext context, Widget? child) {
                return MeuTexto(contador: _contadorNotifier.contador);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // A UI chama o método que altera o estado.
        onPressed: () => _contadorNotifier.incrementar(),
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