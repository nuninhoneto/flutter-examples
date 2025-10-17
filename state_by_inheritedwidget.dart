import 'package:flutter/material.dart';

void main() => runApp(
      MeuEstadoProvider(
        dados: "Dados Fornecidos pelo Provider",
        child: MaterialApp(
          home: TelaInicial(),
        ),
      ),
    );

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessa os dados do `MeuEstadoProvider` mais próximo na árvore.
    // Isso funciona porque `MeuEstadoProvider` é um ancestral de `TelaInicial`.
    var dados = MeuEstadoProvider.of(context).dados;
    return Scaffold(
      appBar: AppBar(
        title: const Text("InheritedWidget"),
      ),
      body: Center(
        child: Text(dados),
      ),
    );
  }
}

class MeuEstadoProvider extends InheritedWidget {
  const MeuEstadoProvider({
    super.key,
    required this.dados,
    required super.child,
  });

  final String dados;

  static MeuEstadoProvider of(BuildContext context) {
    // Este método procura o ancestral `MeuEstadoProvider` mais próximo.
    final resultado = context.dependOnInheritedWidgetOfExactType<MeuEstadoProvider>();

    // Garante que o widget foi encontrado. Se não, uma exceção é lançada.
    assert(resultado != null, 'Nenhum MeuEstadoProvider foi encontrado no contexto');

    return resultado!;
  }

  @override
  // Este método informa ao Flutter se os widgets que dependem destes dados
  // devem ser reconstruídos quando os dados mudam.
  bool updateShouldNotify(MeuEstadoProvider oldWidget) => dados != oldWidget.dados;
}
