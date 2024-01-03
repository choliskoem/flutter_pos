import 'package:flutter_pos/data/models/response/product_response_model.dart';
import 'package:flutter_pos/presentation/order/models/order_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../presentation/home/models/order_item.dart';

class ProductLocalDatasource {
  ProductLocalDatasource._init();
  static final ProductLocalDatasource instance = ProductLocalDatasource._init();

  final String tableProducts = 'products';
  final String tableOrders = 'orders';
  final String tableOrderItem = 'order_item';

  static Database? _database;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price INTEGER,
        stock INTEGER,
        image TEXT,
        category TEXT,
        is_best_seller INTEGER,
        is_sync INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableOrders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nominal INTEGER,
        payment_method TEXT,
        total_item INTEGER,
        id_kasir INTEGER,
        name_kasir TEXT,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrderItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER

      )
    ''');
  }

  //save order
  Future<int> saveOrder(OrderModel order) async {
    final db = await instance.database;
    int id = await db.insert(tableOrders, order.toMapForLocal());
    for (var orderItem in order.orders) {
      await db.insert(tableOrderItem, orderItem.toMapForLocal(id));
    }
    return id;
  }

  //get order isSync = 0
  Future<List<OrderModel>> getOrders() async {
    final db = await instance.database;
    final result = await db.query(tableOrders, where: 'is_sync = 0');
    return result.map((e) => OrderModel.fromLocalMap(e)).toList();
  }

  //get order item by order
  Future<List<OrderItem>> getOrderItems(int idOrder) async {
    final db = await instance.database;
    final result = await db.query(tableOrderItem, where: 'id_order = $idOrder');
    return result.map((e) => OrderItem.fromMap(e)).toList();
  }

//update isSync order by id
  Future<int> updateIsSyncOrderById(int id) async {
    final db = await instance.database;
    return await db.update(tableOrders, {'is_sync': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('pos8.db');
    return _database!;
  }

  //remove all data product
  Future removeAllProduct() async {
    final db = await instance.database;
    await db.delete(tableProducts);
  }

  //insert data product from list product
  Future<void> insertAllProduct(List<Product> products) async {
    final db = await instance.database;
    for (var product in products) {
      await db.insert(tableProducts, product.toMap());
    }
  }

  //insert data product
  Future<Product> insertProduct(Product product) async {
    final db = await instance.database;
    int id = await db.insert(tableProducts, product.toMap());
    return product.copyWith(id: id);
  }

  Future<List<Product>> getAllProduct() async {
    final db = await instance.database;
    final result = await db.query(tableProducts);
    return result.map((e) => Product.fromMap(e)).toList();
  }
}
