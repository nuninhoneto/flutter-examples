import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar se é Web
import 'dart:async';
import 'dart:convert'; // Para converter a lista em JSON na Web

// ============================================================================
// 1. CAMADA DE DADOS (MODEL & SERVICES)
// ============================================================================

class Tarefa {
  final int? id;
  final String titulo;
  bool estaCompleta;

  Tarefa({this.id, required this.titulo, this.estaCompleta = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'estaCompleta': estaCompleta ? 1 : 0,
    };
  }

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      titulo: map['titulo'],
      // Garante compatibilidade: SQLite retorna int (0/1), JSON pode retornar bool ou int
      estaCompleta: map['estaCompleta'] == 1 || map['estaCompleta'] == true,
    );
  }
}

// --- Serviço de Banco de Dados HÍBRIDO (Funciona em Web e Mobile) ---
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Apenas para Web: chave para salvar a lista inteira
  static const String _webStorageKey = 'tarefas_web_db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Se for Web, não iniciamos o SQLite real. Retornamos erro ou null se tentarem usar.
    // Mas nossos métodos CRUD vão checar kIsWeb antes.
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

  // --- MÉTODOS CRUD ADAPTADOS ---

  Future<void> inserirTarefa(Tarefa tarefa) async {
    if (kIsWeb) {
      await _inserirWeb(tarefa);
    } else {
      final db = await database;
      await db.insert('tarefas', tarefa.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Tarefa>> buscarTarefas() async {
    if (kIsWeb) {
      return await _buscarWeb();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('tarefas');
      return List.generate(maps.length, (i) => Tarefa.fromMap(maps[i]));
    }
  }

  Future<void> atualizarTarefa(Tarefa tarefa) async {
    if (kIsWeb) {
      await _atualizarWeb(tarefa);
    } else {
      final db = await database;
      await db.update(
        'tarefas',
        tarefa.toMap(),
        where: 'id = ?',
        whereArgs: [tarefa.id],
      );
    }
  }

  Future<void> deletarTarefa(int id) async {
    if (kIsWeb) {
      await _deletarWeb(id);
    } else {
      final db = await database;
      await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
    }
  }

  // --- Lógica Específica para WEB (Simulando DB com JSON) ---
  
  Future<List<Tarefa>> _buscarWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_webStorageKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => Tarefa.fromMap(e)).toList();
  }

  Future<void> _inserirWeb(Tarefa t) async {
    final lista = await _buscarWeb();
    // Gera um ID falso baseado no tempo, já que não temos AutoIncrement no JSON
    final novaTarefa = Tarefa(
      id: DateTime.now().millisecondsSinceEpoch, 
      titulo: t.titulo, 
      estaCompleta: t.estaCompleta
    );
    lista.add(novaTarefa);
    await _salvarListaWeb(lista);
  }

  Future<void> _atualizarWeb(Tarefa t) async {
    final lista = await _buscarWeb();
    final index = lista.indexWhere((element) => element.id == t.id);
    if (index != -1) {
      lista[index] = t;
      await _salvarListaWeb(lista);
    }
  }

  Future<void> _deletarWeb(int id) async {
    final lista = await _buscarWeb();
    lista.removeWhere((element) => element.id == id);
    await _salvarListaWeb(lista);
  }

  Future<void> _salvarListaWeb(List<Tarefa> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(lista.map((e) => e.toMap()).toList());
    await prefs.setString(_webStorageKey, jsonString);
  }
}

// --- Serviço de Preferências (Configurações Gerais) ---
class PreferencesService {
  static const String _keyNomeUsuario = 'nome_usuario';

  Future<void> salvarNomeUsuario(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNomeUsuario, nome);
  }

  Future<String> lerNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNomeUsuario) ?? 'Usuário';
  }
}

// ============================================================================
// 2. VIEWMODEL (O restante do código permanece IGUAL)
// ============================================================================

class ViewModelListaTarefas extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final PreferencesService _prefsService = PreferencesService();

  List<Tarefa> _tarefas = [];
  String _nomeUsuario = 'Carregando...';
  bool _isLoading = true;

  List<Tarefa> get tarefas => _tarefas;
  String get nomeUsuario => _nomeUsuario;
  bool get isLoading => _isLoading;
  int get tarefasRestantes => _tarefas.where((t) => !t.estaCompleta).length;

  ViewModelListaTarefas() {
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      _tarefas = await _dbHelper.buscarTarefas();
      _nomeUsuario = await _prefsService.lerNomeUsuario();
    } catch (e) {
      debugPrint("ERRO AO CARREGAR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> atualizarNomeUsuario(String novoNome) async {
    _nomeUsuario = novoNome;
    await _prefsService.salvarNomeUsuario(novoNome);
    notifyListeners();
  }

  Future<void> adicionarTarefa(String titulo) async {
    if (titulo.isNotEmpty) {
      final novaTarefa = Tarefa(titulo: titulo);
      await _dbHelper.inserirTarefa(novaTarefa);
      _tarefas = await _dbHelper.buscarTarefas();
      notifyListeners();
    }
  }

  Future<void> alternarTarefa(Tarefa tarefa) async {
    tarefa.estaCompleta = !tarefa.estaCompleta;
    await _dbHelper.atualizarTarefa(tarefa);
    notifyListeners();
  }

  Future<void> removerTarefa(int id) async {
    await _dbHelper.deletarTarefa(id);
    _tarefas = await _dbHelper.buscarTarefas();
    notifyListeners();
  }
}

// ============================================================================
// 3. UI (WIDGETS - IGUAL)
// ============================================================================

void main() {
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
        title: 'Persistência Web/Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
        home: const TelaPrincipal(),
      ),
    );
  }
}

class TelaPrincipal extends StatelessWidget {
  const TelaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewModelListaTarefas>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Minhas Tarefas', style: TextStyle(fontSize: 18)),
                Text('Olá, ${viewModel.nomeUsuario}!', style: const TextStyle(fontSize: 12)),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(child: Text('${viewModel.tarefasRestantes} pendentes')),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
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

  void _mostrarConfiguracoes(BuildContext context) {
    final viewModel = context.read<ViewModelListaTarefas>();
    final controller = TextEditingController(text: viewModel.nomeUsuario);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Nome'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nome')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
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
                labelText: kIsWeb ? 'Nova Tarefa (Web Storage)' : 'Nova Tarefa (SQLite)',
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
      return const Center(child: Text('Nenhuma tarefa.', style: TextStyle(color: Colors.grey)));
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
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(tarefa.titulo, style: TextStyle(decoration: tarefa.estaCompleta ? TextDecoration.lineThrough : null, color: tarefa.estaCompleta ? Colors.grey : Colors.black)),
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