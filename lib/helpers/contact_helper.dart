import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// Colunas da tabela
final String contactTable = "contactTable";
final String idColumn = 'idColumn';
final String nameColumn = 'nameColumn';
final String emailColumn = 'emailColumn';
final String phoneColumn = 'phoneColumn';
final String imgColumn = 'imgColumn';

class ContactHelper {
  // Instancia um construtor interno
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  // Declarando o banco de dados
  Database _db;

  // Inicializando o banco
  Future<Database> get db async {
    // Se _db for null, o bando já está instanciado e apenas sera retornado
    if (_db != null) {
      return _db;
    } else {
      // Se não for nulo será chamada a função initDB() para inicializa-lo
      _db = await initDb();
      return _db;
    }
  }

  // Função para inicialização do banco
  Future<Database> initDb() async {
    // Caminho para a pasta do banco de dados
    final databasesPath = await getDatabasesPath();
    // Juntando o caminho da pasta, com o nome do banco, para obter o caminho completo
    final path = join(databasesPath, "contactsnew.db");

    // Abrindo o banco a primeira vez, passando o caminho, versão e a função para criar a primeira tabela
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          // Query para criação da tabela
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
          "$phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  // INSERT --------------------------------------------------------------------------------------------
  Future<Contact> saveContact(Contact contact) async {
    // Obtendo o banco de dados
    Database dbContact = await db;
    // Inserindo contato no banco, passando a tabela onde será inserido e o objeto transformado em Map
    // Salvando o ID do contato retornado
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  // GET -------------------------------------------------------------------------------------------------
  Future<Contact> getContact(int id) async {
    // Obtendo o banco de dados
    Database dbContact = await db;
    // Retorna uma lista de Maps com o resultados da query
    List<Map> maps = await dbContact.query(contactTable,
        // Query de consulta no banco de dados retornando id, nome, email, phone, img
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        // Onde o ID da coluna for igual ao ID passado como parâmetro na função
        where: "$idColumn = ?",
        whereArgs: [id]);
    // Se a lista de Maps estiver preenchida, retorna o primeiro Map
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      // Se estiver vazia retorna nulo
      return null;
    }
  }

  // DELETE ---------------------------------------------------------------------------------------------
  Future<int> deleteContact(int id) async {
    // Obtendo o banco de dados
    Database dbContact = await db;
    // Deletando o contato especificado, onde o ID da coluna foi igual ao ID passado como parâmentro
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  // UPDATE ----------------------------------------------------------------------------------------------
  Future<int> updateContact(Contact contact) async {
    // Obtendo o banco de dados
    Database dbContact = await db;
    // Atualizando o contato transformado em Map onde o ID da coluna é igual ao ID passado como par^mentro
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  // GET ALL ----------------------------------------------------------------------------------------------
  Future<List> getAllContacts() async {
    // Obtendo o banco de dados
    Database dbContact = await db;
    // Criando uma lista de MAPAS com o resultado da Query
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    // Criando uma lista de CONTATOS para receber os MAPAS
    List<Contact> listContact = List();
    // Populando a lista de contato com os MAPAS transformados e contatos
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  // CONTAGEM DE CONTATOS ----------------------------------------------------------------------------------
  Future<int> getNumber() async {
    // Obtendo o banco de dados
    Database dbContact = await db;
    // Retorna o numero de contatos da tabela de acordo com a query
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  // FECHAR CONEXÃO ----------------------------------------------------------------------------------------
  Future close() async {
    // Obtendo o banco de dados
    Database dbContact = await db;
    dbContact.close();
  }
}

// Model
class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  // Construtor vazio
  Contact();

  // Construtor
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
