// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- 1. MODELO DE DADOS (Task) ---
class Task {
  final String id;
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false}) : id = DateTime.now().microsecondsSinceEpoch.toString();
}

// --- 2. VIEWMODEL (ChangeNotifier) ---
class TodoListViewModel extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks; // Getter para acessar a lista

  void addTask(String title) {
    if (title.isNotEmpty) {
      // Note: Idealmente, em MVVM puro, você criaria uma cópia defensiva da Task
      // antes de adicioná-la, mas o Flutter geralmente permite essa mutação interna.
      _tasks.add(Task(title: title));
      notifyListeners(); // Notifica todos os Widgets que estão 'escutando'
    }
  }

  void toggleTask(String id) {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.isCompleted = !task.isCompleted;
    notifyListeners(); // Notifica a alteração
  }

  int get remainingTasks => _tasks.where((task) => !task.isCompleted).length;
}

void main() {
  runApp(const ProviderApp());
}

class ProviderApp extends StatelessWidget {
  const ProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolve toda a aplicação com o ChangeNotifierProvider
    // Usando a ViewModel renomeada
    return ChangeNotifierProvider(
      create: (context) => TodoListViewModel(),
      child: MaterialApp(
        title: 'Abordagem Provider (MVVM Conceitual)',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const TodoListScreenProvider(),
      ),
    );
  }
}

// --- 3. WIDGET PRINCIPAL (View) ---
class TodoListScreenProvider extends StatelessWidget {
  const TodoListScreenProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2. Provider (ChangeNotifier)'),
        actions: [
          // Usa Consumer para reagir apenas ao contador de tarefas restantes
          // O tipo agora é TodoListViewModel
          Consumer<TodoListViewModel>(
            builder: (context, model, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    'Pendentes: ${model.remainingTasks}',
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
          TaskInputProvider(), // Widget de entrada (View)
          Divider(),
          Expanded(
            child: TaskListProvider(), // Widget da lista (View)
          ),
        ],
      ),
    );
  }
}

// --- 4. WIDGETS QUE INTERAGEM/ESCUTAM O ESTADO (View) ---

// Widget de Entrada (usa context.read() para a ação)
class TaskInputProvider extends StatelessWidget {
  const TaskInputProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    // Obtém a instância da ViewModel
    final viewModel = context.read<TodoListViewModel>();

    void submitData() {
      viewModel.addTask(controller.text);
      controller.clear();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nova Tarefa',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => submitData(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.indigo),
            onPressed: submitData,
          ),
        ],
      ),
    );
  }
}

// Widget da Lista (usa context.watch() para reconstruir)
class TaskListProvider extends StatelessWidget {
  const TaskListProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém a ViewModel e reconstrói o widget quando notificado
    final viewModel = context.watch<TodoListViewModel>();

    if (viewModel.tasks.isEmpty) {
      return const Center(
        child: Text('Nenhuma tarefa adicionada ainda!', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      itemCount: viewModel.tasks.length,
      itemBuilder: (ctx, index) {
        final task = viewModel.tasks[index];
        return ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : Colors.black,
            ),
          ),
          trailing: Checkbox(
            activeColor: Colors.indigo,
            value: task.isCompleted,
            // Ação chama o método da ViewModel diretamente
            onChanged: (_) => viewModel.toggleTask(task.id),
          ),
        );
      },
    );
  }
}