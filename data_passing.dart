import 'package:flutter/material.dart';

void main() => runApp(
      MaterialApp(
        home: HomePage(dados: DadosDoApp(), produtos: Catalogo(),),
      ),
    );

class DadosDoApp {
  String usuarioLogado = "Professor Dart";
  List<String> produtos = [];
}

class Catalogo {
  List<String> produtos = [];
}

class CarrinhoDeCompras {
  List<String> produtosNoCarrinho = [];
}

// Widget Pai
class HomePage extends StatelessWidget {
  final DadosDoApp dados; // O dado tem que ser passado por parâmetro
  const HomePage({super.key, required this.dados, required Catalogo produtos});
  
  @override
  Widget build(BuildContext context) {
    return DetalhesDaConta(dados: dados); // Passando o dado...
  }
}

// Widget Filho Intermediário (só repassa o dado)
class DetalhesDaConta extends StatelessWidget {
  final DadosDoApp dados;
  const DetalhesDaConta({super.key, required this.dados});
  
  @override
  Widget build(BuildContext context) {
    return WidgetNeto(dados: dados); // ...e repassando o dado
  }
}

// Widget Neto (finalmente usa o dado)
class WidgetNeto extends StatelessWidget {
  final DadosDoApp dados;
  const WidgetNeto({super.key, required this.dados});
  
  @override
  Widget build(BuildContext context) {
    // Imaginar que este Widget precisa atualizar o nome do usuário...
    return Text('Bem-vindo, ${dados.usuarioLogado}');
  }
}
// Conclusão: Isso é difícil de manter. Precisamos de um Gestor de Estado!