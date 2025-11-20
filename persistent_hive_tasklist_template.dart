import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// TODO: Importar o Hive CE

// --- 1. MODELO DE DADOS (Tarefa) ---
class Tarefa {
  // TODO: Adicionar campo 'key' para o ID gerado pelo Hive
  final String id;
  String titulo;
  bool estaCompleta;

  // TODO: Construtor atualizado para incluir 'key'
  Tarefa({required this.titulo, this.estaCompleta = false}) : id = DateTime.now().microsecondsSinceEpoch.toString();

  // TODO: Métodos para conversão entre Objeto e Map (para Hive) toMap e fromHive
}

// TODO: Criar um serviço HiveService para encapsular operações do Hive
class HiveService {
  // TODO: inicializar Hive e abrir a caixa

  // TODO: Operações CRUD adicionarTarefa, listarTarefas, atualizarTarefa, deletarTarefa
}

// --- 2. VIEWMODEL (ChangeNotifier) ---
class ViewModelListaTarefas extends ChangeNotifier {
  List<Tarefa> _tarefas = [];

  List<Tarefa> get tarefas => _tarefas; // Getter para acessar a lista

  // TODO: Instanciar o HiveService

  // TODO: Carregar dados do Hive na inicialização da ViewModel

  // TODO: criar método privado _carregarDados para atualizar _tarefas e notificar listeners

  // TODO: Atualizar os métodos adicionarTarefa e alternarTarefa para usar o HiveService
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

  // TODO: Criar um metódo deletarTarefa para remover a tarefa do Hive e atualizar a lista

  int get tarefasRestantes => _tarefas.where((t) => !t.estaCompleta).length;
}

void main() {
  // TODO: Inicializar o HiveService antes de rodar o app
  runApp(const AppProvider());
}

class AppProvider extends StatelessWidget {
  const AppProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModelListaTarefas(),
      child: MaterialApp(
        title: 'Hive Demo Web/Mobile',
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
        title: const Text('Tarefas com Hive CE'),
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