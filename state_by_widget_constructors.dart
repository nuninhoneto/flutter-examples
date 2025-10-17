import 'package:flutter/material.dart';

// Este arquivo ilustra como o estado pode ser gerenciado e passado entre widgets
// em Flutter. O padrão demonstrado é "levantar o estado" (lifting state up),
// onde um widget pai (StatefulWidget) gerencia o estado e o passa para seus
// widgets filhos (StatelessWidgets) através de seus construtores.
void main() => runApp(MaterialApp(home: AppPassagemDeEstado()));

// O widget pai que gerencia o estado.
class AppPassagemDeEstado extends StatefulWidget {
  const AppPassagemDeEstado({super.key});

  @override
  State<AppPassagemDeEstado> createState() => _AppPassagemDeEstadoState();
}

class _AppPassagemDeEstadoState extends State<AppPassagemDeEstado> {
  // 1. O estado é mantido no widget pai.
  int _contador = 0;

  // 2. O método para modificar o estado também reside no widget pai.
  void _incrementarContador() {
    setState(() {
      _contador++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passando Estado via Construtores'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'O widget pai (Stateful) passa o estado para o widget filho de exibição:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            // 3. O valor do estado (`_contador`) é passado para o `WidgetDeExibicao`
            //    através de seu construtor.
            WidgetDeExibicao(contador: _contador),
            const SizedBox(height: 30),
            const Text(
              'O widget pai (Stateful) passa uma função de callback para o widget filho de botão:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            // 4. A função que altera o estado (`_incrementarContador`) é passada para
            //    o `WidgetDeBotao` como um callback através de seu construtor.
            WidgetDeBotao(onPressed: _incrementarContador),
          ],
        ),
      ),
    );
  }
}

// --- Widgets Filhos (Stateless) ---

// Um widget filho que não tem estado próprio (Stateless).
// Ele simplesmente exibe os dados que recebe de seu pai.
class WidgetDeExibicao extends StatelessWidget {
  final int contador;

  // O construtor recebe o estado do pai.
  const WidgetDeExibicao({super.key, required this.contador});

  @override
  Widget build(BuildContext context) {
    print('WidgetDeExibicao reconstruído');
    return Text(
      'Contagem atual: $contador',
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

// Outro widget filho sem estado próprio.
// Ele notifica o pai sobre um evento (clique de botão) através de um callback.
class WidgetDeBotao extends StatelessWidget {
  final VoidCallback onPressed; // VoidCallback é um typedef para `void Function()`

  // O construtor recebe a função de callback do pai.
  const WidgetDeBotao({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    print('WidgetDeBotao reconstruído');
    return ElevatedButton(
      // Quando o botão é pressionado, a função de callback recebida do pai é chamada.
      // Isso faz com que o estado no pai seja atualizado.
      onPressed: onPressed,
      child: const Text('Incrementar'),
    );
  }
}
