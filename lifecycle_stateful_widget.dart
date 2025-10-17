import 'package:flutter/material.dart';

// Este arquivo demonstra o ciclo de vida de um StatefulWidget.
// Os logs de cada estágio do ciclo de vida são impressos no console.
void main() => runApp(MaterialApp(home: CicloDeVidaApp()));

class CicloDeVidaApp extends StatefulWidget {
  const CicloDeVidaApp({super.key});

  @override
  State<CicloDeVidaApp> createState() => _CicloDeVidaAppState();
}

class _CicloDeVidaAppState extends State<CicloDeVidaApp> {
  bool _exibirWidget = true;
  int _algumValor = 0;

  void _alternarWidget() {
    setState(() {
      _exibirWidget = !_exibirWidget;
    });
  }

  void _atualizarValor() {
    setState(() {
      _algumValor++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciclo de Vida do Widget'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_exibirWidget)
              CicloDeVidaWidget(value: _algumValor),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _alternarWidget,
              child: Text(_exibirWidget ? 'Remover Widget' : 'Adicionar Widget'),
            ),
            ElevatedButton(
              onPressed: _atualizarValor,
              child: const Text('Atualizar Widget'),
            ),
          ],
        ),
      ),
    );
  }
}

class CicloDeVidaWidget extends StatefulWidget {
  final int value;

  const CicloDeVidaWidget({super.key, required this.value});

  // 1. createState()
  // Imediatamente após o construtor, o Flutter chama createState().
  // Este método é obrigado a existir e retorna uma instância da classe State associada.
  @override
  State<CicloDeVidaWidget> createState() {
    print('1. createState() chamado');
    return _CicloDeVidaWidgetState();
  }
}

class _CicloDeVidaWidgetState extends State<CicloDeVidaWidget> {
  // 2. initState()
  // Este é o primeiro método chamado após o State ser criado.
  // É chamado apenas uma vez para cada objeto State.
  // Use-o para inicializar dados, inscrever-se em streams, etc.
  @override
  void initState() {
    super.initState();
    print('2. initState() chamado');
  }

  // 3. didChangeDependencies()
  // Chamado imediatamente após initState() na primeira vez que o widget é construído.
  // Também é chamado sempre que um objeto do qual este widget depende muda.
  // Por exemplo, se o widget depende de um InheritedWidget e ele muda.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('3. didChangeDependencies() chamado');
  }

  // 4. build()
  // Chamado após didChangeDependencies() e sempre que o widget precisa ser reconstruído.
  // Isso acontece quando setState() é chamado, ou quando as dependências do widget mudam.
  // Este método deve retornar uma árvore de widgets.
  @override
  Widget build(BuildContext context) {
    print('4. build() chamado');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('Valor: ${widget.value}'),
    );
  }

  // 5. didUpdateWidget()
  // Chamado se o widget pai for reconstruído e passar novos parâmetros para este widget.
  // O framework fornece o widget antigo (oldWidget) como um parâmetro para que você
  // possa comparar com o widget atual (widget) e reagir às mudanças.
  @override
  void didUpdateWidget(CicloDeVidaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('5. didUpdateWidget() chamado');
    if (widget.value != oldWidget.value) {
      print('   - O valor mudou de ${oldWidget.value} para ${widget.value}');
    }
  }

  // 6. deactivate()
  // Chamado quando o objeto State é removido da árvore de widgets.
  // Isso pode ser temporário, como ao mover o widget para outra parte da árvore.
  @override
  void deactivate() {
    print('6. deactivate() chamado');
    super.deactivate();
  }

  // 7. dispose()
  // Chamado quando o objeto State é removido da árvore de widgets permanentemente.
  // Use este método para liberar recursos, cancelar timers, fazer unsubscribe de streams, etc.
  // Após este ponto, o objeto State nunca mais será reconstruído.
  @override
  void dispose() {
    print('7. dispose() chamado');
    super.dispose();
  }
}
