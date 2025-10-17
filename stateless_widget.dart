import 'package:flutter/material.dart';

// Um StatelessWidget é um widget que descreve parte da interface do usuário que
// não depende de nada além das informações de configuração (os parâmetros
// passados para seu construtor) e do BuildContext no qual o widget é inflado.
//
// Para widgets que podem mudar dinamicamente - por exemplo, devido à interação
// do usuário ou porque dependem de dados que mudam com o tempo - considere usar
// um StatefulWidget.
//
// A vida útil de um StatelessWidget é simples: ele é criado, seu método build()
// é chamado e isso é tudo. Ele não tem estado mutável. Isso significa que ele
// não pode ser redesenhado por conta própria. Ele é redesenhado apenas quando
// um de seus widgets pais é redesenhado.

// Exemplo de um StatelessWidget:
class MyStatelessWidget extends StatelessWidget {
  final String title;
  final String message;

  // O construtor recebe os dados que o widget exibirá.
  // Esses dados são imutáveis. Uma vez que o widget é construído,
  // esses dados não podem ser alterados.
  const MyStatelessWidget({
    super.key,
    required this.title,
    required this.message,
  });

  // O método build é onde a interface do usuário para este widget é descrita.
  // O Flutter chama este método quando o widget é inserido na árvore de widgets.
  // Ele deve retornar um novo widget.
  @override
  Widget build(BuildContext context) {
    // O método build pode usar os dados passados para o construtor para
    // configurar a aparência do widget.
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}

// Para usar este widget em seu aplicativo, você o instanciaria e o adicionaria
// à sua árvore de widgets, por exemplo, no método build de outro widget:
//
// void main() {
//   runApp(
//     const MaterialApp(
//       home: MyStatelessWidget(
//         title: 'Exemplo de StatelessWidget',
//         message: 'Olá, Mundo!',
//       ),
//     ),
//   );
// }
