import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart'; // Import do Hive CE

// --- 1. MODELO DE DADOS (Tarefa) ---
class Tarefa {
  // No Hive, cada objeto salvo ganha uma chave (key) automática, que usaremos como ID
  final dynamic key; 
  String titulo;
  bool estaCompleta;

  Tarefa({this.key, required this.titulo, this.estaCompleta = false});

  // Converte para Map para salvar na "Caixa" do Hive
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'estaCompleta': estaCompleta,
    };
  }

  // Converte do formato salvo no Hive de volta para Objeto
  // key: é o ID único que o Hive gera automaticamente
  factory Tarefa.fromHive(dynamic key, Map<dynamic, dynamic> map) {
    return Tarefa(
      key: key,
      titulo: map['titulo'] ?? '',
      estaCompleta: map['estaCompleta'] ?? false,
    );
  }
}

// --- Serviço de Banco de Dados (Hive Service) ---
class HiveService {
  // O nome da nossa "caixa" (como se fosse a tabela)
  static const String _boxName = 'tarefasBox';

  // Inicializa o Hive (Deve ser chamado no main)
  static Future<void> init() async {
    await Hive.initFlutter();
    // Abre a caixa. Se não existir, o Hive cria.
    await Hive.openBox(_boxName);
  }

  // Referência para a caixa aberta
  Box get _box => Hive.box(_boxName);

  // --- CRUD ---

  Future<void> adicionarTarefa(String titulo) async {
    final novaTarefa = {'titulo': titulo, 'estaCompleta': false};
    // .add() insere e gera uma chave (ID) automaticamente
    await _box.add(novaTarefa); 
  }

  List<Tarefa> listarTarefas() {
    // _box.toMap() retorna um mapa onde a Chave é o ID e o Valor é o dado
    return _box.toMap().entries.map((entry) {
      final key = entry.key;
      final value = Map<String, dynamic>.from(entry.value);
      return Tarefa.fromHive(key, value);
    }).toList();
  }

  Future<void> atualizarTarefa(Tarefa tarefa) async {
    final dadosAtualizados = tarefa.toMap();
    // .put(key, valor) atualiza o dado naquela chave específica
    await _box.put(tarefa.key, dadosAtualizados);
  }

  Future<void> deletarTarefa(dynamic key) async {
    await _box.delete(key);
  }
}

// --- 2. VIEWMODEL (ChangeNotifier) ---
class ViewModelListaTarefas extends ChangeNotifier {
  List<Tarefa> _tarefas = [];

  List<Tarefa> get tarefas => _tarefas; // Getter para acessar a lista

  final HiveService _hiveService = HiveService();
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ViewModelListaTarefas() {
    _carregarDados();
  }

  void _carregarDados() {
    _isLoading = true;
    // Hive é tão rápido que muitas leituras são síncronas, mas vamos manter o padrão
    try {
      _tarefas = _hiveService.listarTarefas();
    } catch (e) {
      debugPrint("Erro: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> adicionarTarefa(String titulo) async {
    if (titulo.isNotEmpty) {
      await _hiveService.adicionarTarefa(titulo);
      _carregarDados(); // Recarrega a lista
    }
  }

  Future<void> alternarTarefa(dynamic id) async {
    final tarefa = _tarefas.firstWhere((t) => t.key == id);
    tarefa.estaCompleta = !tarefa.estaCompleta;
    await _hiveService.atualizarTarefa(tarefa);
    _carregarDados();
  }

  Future<void> removerTarefa(dynamic key) async {
    await _hiveService.deletarTarefa(key);
    _carregarDados();
  }

  int get tarefasRestantes => _tarefas.where((t) => !t.estaCompleta).length;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // INICIALIZAÇÃO DO HIVE ANTES DE RODAR O APP
  await HiveService.init();

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
            onChanged: (_) => viewModel.alternarTarefa(tarefa.key),
          ),
        );
      },
    );
  }
}