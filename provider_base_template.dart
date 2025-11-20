import 'package:flutter/material.dart';
// TODO: Importar o package provider

// TODO: Criar model Tarefa
class Tarefa {
}

// TODO: Criar ViewModelListaTarefas que estende ChangeNotifier
class ViewModelListaTarefas extends ChangeNotifier {
  final List<Tarefa> _tarefas = [];
  
  List<Tarefa> get tarefas => _tarefas; // Getter para acessar a lista

  void adicionarTarefa(String titulo) {
    // TODO: Implementação da lógica de adicionar (e chame notifyListeners())
  }

  void alternarTarefa(String id) {
    // TODO: Implementação da lógica de alternar o status (e chame notifyListeners())
  }

  int get tarefasRestantes {
    // TODO: Implementação da lógica de getter para tarefas restantes (a ser usado no AppBar)
    return 0; 
  }
}

void main() {
  runApp(const AppProvider());
}

class AppProvider extends StatelessWidget {
  const AppProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Disponibilizar o ViewModel no topo da árvore
    return MaterialApp(
        title: 'Abordagem Provider (MVVM Base)',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const TelaListaTarefasProvider(),
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
        title: const Text('2. Provider - Template Base'),
        actions: [
          // TODO: Implementar o Consumer/Selector aqui para o contador de tarefas restantes
        ],
      ),
      body: const Column(
        children: <Widget>[
          EntradaTarefaProvider(), 
          Divider(),
          Expanded(
            child: ListaTarefasProvider(), 
          ),
        ],
      ),
    );
  }
}

class EntradaTarefaProvider extends StatelessWidget {
  const EntradaTarefaProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final controlador = TextEditingController();
    
    // TODO: Usar context.read() para obter o ViewModel
    final viewModel = ViewModelListaTarefas();

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

class ListaTarefasProvider extends StatelessWidget {
  const ListaTarefasProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Usar context.watch() para reconstruir a lista.
    final viewModel = ViewModelListaTarefas();

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
            "TITULO DA TAREFA", // TODO: Usar titulo da tarefa
            style: TextStyle(
              decoration: true ? TextDecoration.lineThrough : null, // TODO: Verificar se a tarefa está completa
              color: true ? Colors.grey : Colors.black, // TODO: Verificar se a tarefa está completa
            ),
          ),
          trailing: Checkbox(
            activeColor: Colors.indigo,
            value: true, // TODO: Verificar se a tarefa está completa
            onChanged: (_) => viewModel.alternarTarefa(""), // TODO: Informar a ViewModel para alternar o status
          ),
        );
      },
    );
  }
}