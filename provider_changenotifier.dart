// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- 1. MODELO DE DADOS (Tarefa) ---
class Tarefa {
  final String id;
  String titulo;
  bool estaCompleta;

  Tarefa({required this.titulo, this.estaCompleta = false}) : id = DateTime.now().microsecondsSinceEpoch.toString();
}

// --- 2. VIEWMODEL (ChangeNotifier) ---
class ViewModelListaTarefas extends ChangeNotifier {
  final List<Tarefa> _tarefas = [];

  List<Tarefa> get tarefas => _tarefas; // Getter para acessar a lista

  void adicionarTarefa(String titulo) {
    if (titulo.isNotEmpty) {
      _tarefas.add(Tarefa(titulo: titulo));
      notifyListeners(); // Notifica todos os Widgets que estão 'escutando'
    }
  }

  void alternarTarefa(String id) {
    final tarefa = _tarefas.firstWhere((t) => t.id == id);
    tarefa.estaCompleta = !tarefa.estaCompleta;
    notifyListeners(); // Notifica a alteração
  }

  int get tarefasRestantes => _tarefas.where((t) => !t.estaCompleta).length;
}

void main() {
  runApp(const AppProvider());
}

class AppProvider extends StatelessWidget {
  const AppProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolve toda a aplicação com o ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (context) => ViewModelListaTarefas(),
      child: MaterialApp(
        title: 'Abordagem Provider (MVVM Conceitual)',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const TelaListaTarefasProvider(),
      ),
    );
  }
}

// --- 3. WIDGET PRINCIPAL (View) ---
class TelaListaTarefasProvider extends StatelessWidget {
  const TelaListaTarefasProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2. Provider (ChangeNotifier)'),
        actions: [
          // Usa Consumer para reagir apenas ao contador de tarefas restantes
          // O tipo agora é ViewModelListaTarefas
          Consumer<ViewModelListaTarefas>(
            builder: (context, viewModel, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    'Pendentes: ${viewModel.tarefasRestantes}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: const Column(
        children: <Widget>[
          EntradaTarefaProvider(), // Widget de entrada (View)
          Divider(),
          Expanded(
            child: ListaTarefasProvider(), // Widget da lista (View)
          ),
        ],
      ),
    );
  }
}

// --- 4. WIDGETS QUE INTERAGEM/ESCUTAM O ESTADO (View) ---

// Widget de Entrada (usa context.read() para a ação)
class EntradaTarefaProvider extends StatelessWidget {
  const EntradaTarefaProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final controlador = TextEditingController();
    // Obtém a instância da ViewModel
    final viewModel = context.read<ViewModelListaTarefas>();

    void enviarDados() {
      viewModel.adicionarTarefa(controlador.text);
      controlador.clear();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controlador,
              decoration: const InputDecoration(
                labelText: 'Nova Tarefa',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => enviarDados(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.indigo),
            onPressed: enviarDados,
          ),
        ],
      ),
    );
  }
}

// Widget da Lista (usa context.watch() para reconstruir)
class ListaTarefasProvider extends StatelessWidget {
  const ListaTarefasProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém a ViewModel e reconstrói o widget quando notificado
    final viewModel = context.watch<ViewModelListaTarefas>();

    if (viewModel.tarefas.isEmpty) {
      return const Center(
        child: Text('Nenhuma tarefa adicionada ainda!', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      itemCount: viewModel.tarefas.length,
      itemBuilder: (ctx, index) {
        final tarefa = viewModel.tarefas[index];
        return ListTile(
          title: Text(
            tarefa.titulo,
            style: TextStyle(
              decoration: tarefa.estaCompleta ? TextDecoration.lineThrough : null,
              color: tarefa.estaCompleta ? Colors.grey : Colors.black,
            ),
          ),
          trailing: Checkbox(
            activeColor: Colors.indigo,
            value: tarefa.estaCompleta,
            // Ação chama o método da ViewModel diretamente
            onChanged: (_) => viewModel.alternarTarefa(tarefa.id),
          ),
        );
      },
    );
  }
}