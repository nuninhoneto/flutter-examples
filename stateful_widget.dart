import 'package:flutter/material.dart';

// Um StatefulWidget é um widget que pode ter seu estado alterado durante a vida útil do widget.
// "Estado" (State) é a informação que pode ser lida de forma síncrona quando o widget é construído
// e que pode mudar durante a vida útil do widget.
//
// É responsabilidade do implementador do widget garantir que o Estado seja prontamente
// notificado quando o estado mudar, usando o método State.setState.
//
// StatefulWidgets são úteis quando a parte da interface do usuário que eles descrevem
// pode mudar dinamicamente. Por exemplo, um widget que incrementa um contador quando
// um botão é pressionado.

// A implementação de um StatefulWidget requer duas classes:
// 1. Uma subclasse de StatefulWidget.
// 2. Uma subclasse de State.

// A classe StatefulWidget em si é imutável e armazena a configuração do widget.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key, required this.title});

  final String title;

  // O método createState() cria o objeto de estado mutável para este widget.
  // O framework pode chamar este método várias vezes durante a vida útil de um
  // StatefulWidget. Por exemplo, se você mover o widget para um local diferente
  // na árvore de widgets.
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

// A classe State é onde o estado mutável do widget é mantido.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _counter = 0;

  // Este método é chamado quando o estado precisa ser alterado.
  // Envolver a alteração do estado em setState() informa ao Flutter que o estado
  // foi alterado e que o widget precisa ser reconstruído para refletir a mudança.
  void _incrementCounter() {
    setState(() {
      // Esta chamada para setState notifica o Flutter que o estado interno deste
      // widget mudou de uma forma que pode impactar a interface do usuário.
      // O Flutter então agenda uma reconstrução (chama o método build) para este
      // widget State.
      _counter++;
    });
  }

  // O método build é chamado pelo Flutter sempre que o widget precisa ser renderizado.
  // Isso acontece na primeira vez que o widget é construído e sempre que setState()
  // é chamado.
  @override
  Widget build(BuildContext context) {
    // A UI é construída com base no estado atual.
    return Scaffold(
      appBar: AppBar(
        // A classe State pode acessar as propriedades imutáveis do seu
        // StatefulWidget correspondente usando `widget`.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Você pressionou o botão esta quantidade de vezes:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Incrementar',
        child: const Icon(Icons.add),
      ),
    );
  }
}
