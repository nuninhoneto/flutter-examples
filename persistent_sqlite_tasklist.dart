import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// ============================================================================
// 1. CAMADA DE DADOS (MODEL & SERVICES)
// ============================================================================

// --- Modelo de Dados: Tarefa ---
class Tarefa {
  final int? id; // SQLite precisa de um int como chave primária (geralmente)
  final String titulo;
  bool estaCompleta;

  Tarefa({this.id, required this.titulo, this.estaCompleta = false});

  // Converte um Objeto Tarefa para um Map (para salvar no SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'estaCompleta': estaCompleta ? 1 : 0, // SQLite não tem boolean, usamos 0 ou 1
    };
  }

  // Converte um Map vindo do SQLite para um Objeto Tarefa
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      titulo: map['titulo'],
      estaCompleta: map['estaCompleta'] == 1,
    );
  }
}

// --- Serviço de Banco de Dados (SQLite) ---
class DatabaseHelper {
  // Padrão Singleton para garantir apenas uma instância do banco
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tarefas_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tarefas(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, estaCompleta INTEGER)',
        );
      },
    );
  }

  // Métodos CRUD (Create, Read, Update, Delete)
  Future<int> inserirTarefa(Tarefa tarefa) async {
    final db = await database;
    return await db.insert('tarefas', tarefa.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Tarefa>> buscarTarefas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tarefas');
    return List.generate(maps.length, (i) => Tarefa.fromMap(maps[i]));
  }

  Future<void> atualizarTarefa(Tarefa tarefa) async {
    final db = await database;
    await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<void> deletarTarefa(int id) async {
    final db = await database;
    await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }
}

// --- Serviço de Preferências (Shared Preferences) ---
class PreferencesService {
  static const String _keyNomeUsuario = 'nome_usuario';

  Future<void> salvarNomeUsuario(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNomeUsuario, nome);
  }

  Future<String> lerNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNomeUsuario) ?? 'Usuário'; // Valor padrão
  }
}

// ============================================================================
// 2. VIEWMODEL (GERENCIAMENTO DE ESTADO)
// ============================================================================

class ViewModelListaTarefas extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final PreferencesService _prefsService = PreferencesService();

  List<Tarefa> _tarefas = [];
  String _nomeUsuario = 'Carregando...';
  // Inicia como true, então a tela já nasce carregando
  bool _isLoading = true; 

  List<Tarefa> get tarefas => _tarefas;
  String get nomeUsuario => _nomeUsuario;
  bool get isLoading => _isLoading;
  int get tarefasRestantes => _tarefas.where((t) => !t.estaCompleta).length;

  // Construtor
  ViewModelListaTarefas() {
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {    
    try {
      // Carrega do SQLite
      _tarefas = await _dbHelper.buscarTarefas();
      
      // Carrega do Shared Preferences
      _nomeUsuario = await _prefsService.lerNomeUsuario();
    } catch (e) {
      debugPrint("ERRO AO CARREGAR DADOS: $e");
      // Em caso de erro, a lista fica vazia mas o app não trava
    } finally {
      // O bloco finally garante que o loading pare, mesmo se der erro no banco
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Ações ---
  Future<void> atualizarNomeUsuario(String novoNome) async {
    _nomeUsuario = novoNome;
    await _prefsService.salvarNomeUsuario(novoNome); // Persiste
    notifyListeners();
  }

  Future<void> adicionarTarefa(String titulo) async {
    if (titulo.isNotEmpty) {
      final novaTarefa = Tarefa(titulo: titulo);
      await _dbHelper.inserirTarefa(novaTarefa); // Persiste
      _tarefas = await _dbHelper.buscarTarefas(); // Recarrega lista atualizada
      notifyListeners();
    }
  }

  Future<void> alternarTarefa(Tarefa tarefa) async {
    tarefa.estaCompleta = !tarefa.estaCompleta;
    await _dbHelper.atualizarTarefa(tarefa); // Persiste atualização
    notifyListeners();
  }

  Future<void> removerTarefa(int id) async {
    await _dbHelper.deletarTarefa(id); // Persiste remoção
    _tarefas = await _dbHelper.buscarTarefas(); // Recarrega
    notifyListeners();
  }
}

// ============================================================================
// 3. CAMADA DE UI (WIDGETS)
// ============================================================================

void main() {
  // Garante que a ligação com widgets nativos esteja inicializada antes de rodar
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppPersistencia());
}

class AppPersistencia extends StatelessWidget {
  const AppPersistencia({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModelListaTarefas(),
      child: MaterialApp(
        title: 'Persistência Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: true,
        ),
        home: const TelaPrincipal(),
      ),
    );
  }
}

class TelaPrincipal extends StatelessWidget {
  const TelaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer para reconstruir a tela se o estado mudar (ex: loading)
    return Consumer<ViewModelListaTarefas>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Minhas Tarefas', style: TextStyle(fontSize: 18)),
                Text(
                  'Olá, ${viewModel.nomeUsuario}!', 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(child: Text('${viewModel.tarefasRestantes} pendentes')),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _mostrarConfiguracoes(context),
              )
            ],
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : const Column(
                  children: [
                    EntradaTarefaWidget(),
                    Expanded(child: ListaTarefasWidget()),
                  ],
                ),
        );
      },
    );
  }

  // Modal simples para editar o nome (Shared Preferences)
  void _mostrarConfiguracoes(BuildContext context) {
    final viewModel = context.read<ViewModelListaTarefas>();
    final controller = TextEditingController(text: viewModel.nomeUsuario);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configurações'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Seu Nome (Salvo em Prefs)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.atualizarNomeUsuario(controller.text);
              Navigator.of(ctx).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class EntradaTarefaWidget extends StatelessWidget {
  const EntradaTarefaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controlador = TextEditingController();
    final viewModel = context.read<ViewModelListaTarefas>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controlador,
              decoration: const InputDecoration(
                labelText: 'Nova Tarefa (Salva em SQLite)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                 viewModel.adicionarTarefa(value);
                 controlador.clear();
              },
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              viewModel.adicionarTarefa(controlador.text);
              controlador.clear();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class ListaTarefasWidget extends StatelessWidget {
  const ListaTarefasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ViewModelListaTarefas>();

    if (viewModel.tarefas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma tarefa.\nAdicione uma para salvar no Banco!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.tarefas.length,
      itemBuilder: (ctx, index) {
        final tarefa = viewModel.tarefas[index];
        return Dismissible(
          key: Key(tarefa.id.toString()),
          background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
          onDismissed: (direction) {
            viewModel.removerTarefa(tarefa.id!);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tarefa removida")));
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(
                tarefa.titulo,
                style: TextStyle(
                  decoration: tarefa.estaCompleta ? TextDecoration.lineThrough : null,
                  color: tarefa.estaCompleta ? Colors.grey : Colors.black,
                ),
              ),
              leading: Checkbox(
                value: tarefa.estaCompleta,
                onChanged: (_) => viewModel.alternarTarefa(tarefa),
              ),
            ),
          ),
        );
      },
    );
  }
}