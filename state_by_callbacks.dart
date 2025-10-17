import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: AppCallback()));

// Este arquivo contém um exemplo simples de como um widget filho pode notificar
// um widget pai para atualizar o estado usando uma função de callback.

// --- Widget Pai (Stateful) ---
// Este widget gerencia o estado e passa uma função de callback para seu filho.
class AppCallback extends StatefulWidget {
  const AppCallback({super.key});

  @override
  State<AppCallback> createState() => _AppCallbackState();
}

class _AppCallbackState extends State<AppCallback> {
  // 1. O estado é mantido no widget pai.
  bool _estaLigado = false;

  // 2. Esta é a função de callback que será passada para o filho.
  //    Quando chamada, ela atualiza o estado do pai usando setState.
  void _alternarEstado() {
    setState(() {
      _estaLigado = !_estaLigado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizando com Callbacks'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Widget que exibe o estado atual
            Text(
              _estaLigado ? 'LIGADO' : 'DESLIGADO',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _estaLigado ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),

            // 3. O widget filho recebe a função de callback através de seu construtor.
            BotaoDeAcao(
              onPressed: _alternarEstado, // Passando a referência da função
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget Filho (Stateless) ---
// Este widget não tem estado próprio. Ele apenas invoca o callback quando é pressionado.
class BotaoDeAcao extends StatelessWidget {
  // O filho declara um campo para receber a função de callback.
  // VoidCallback é um atalho para `void Function()`.
  final VoidCallback onPressed;

  // O construtor exige que o callback seja fornecido.
  const BotaoDeAcao({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // 4. O evento `onPressed` do botão interno aciona o callback recebido do pai.
      //    Isso notifica o pai para que ele possa atualizar seu estado.
      onPressed: onPressed,
      child: const Text('Alternar Estado'),
    );
  }
}