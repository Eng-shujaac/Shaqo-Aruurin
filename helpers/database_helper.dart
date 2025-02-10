import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
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
    String path = join(await getDatabasesPath(), 'safar_kaab.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    print('Creating database tables...');

    await _createTables(db);

    print('Creating default admin user...');
    // Create default admin user
    String adminPassword = _hashPassword('Abdi3320');
    await db.insert('users', {
      'id': const Uuid().v4(),
      'username': 'Abdishakur',
      'password': adminPassword,
      'isAdmin': 1,
      'fullName': 'Abdishakur Mohamed N',
      'email': 'admin@safarkaab.com'
    });
    print('Admin user created successfully');
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE,
        password TEXT,
        isAdmin INTEGER,
        fullName TEXT,
        email TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE flights (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        fromCity TEXT NOT NULL,
        fromCode TEXT NOT NULL,
        toCity TEXT NOT NULL,
        toCode TEXT NOT NULL,
        airline TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        price REAL NOT NULL,
        seats INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        flightId TEXT,
        userId TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (flightId) REFERENCES flights (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE tickets (
        id TEXT PRIMARY KEY,
        flightId TEXT,
        userId TEXT,
        reference TEXT,
        status TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (flightId) REFERENCES flights (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        userId TEXT,
        title TEXT,
        message TEXT,
        isRead INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop existing tables
      await db.execute('DROP TABLE IF EXISTS notifications');
      await db.execute('DROP TABLE IF EXISTS tickets');
      await db.execute('DROP TABLE IF EXISTS bookings');
      await db.execute('DROP TABLE IF EXISTS flights');
      await db.execute('DROP TABLE IF EXISTS users');
      
      // Recreate tables with new schema
      await _createTables(db);
      
      // Recreate default admin user
      String adminPassword = _hashPassword('Abdi3320');
      await db.insert('users', {
        'id': const Uuid().v4(),
        'username': 'Abdishakur',
        'password': adminPassword,
        'isAdmin': 1,
        'fullName': 'Abdishakur Mohamed N',
        'email': 'admin@safarkaab.com'
      });
    }
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> usernameExists(String username) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return results.isNotEmpty;
  }

  Future<void> insertUser(
    String username,
    String password, {
    bool isAdmin = false,
    String? fullName,
    String? email,
  }) async {
    if (await usernameExists(username)) {
      throw Exception('Username already exists');
    }

    final db = await database;
    await db.insert(
      'users',
      {
        'id': const Uuid().v4(),
        'username': username,
        'password': _hashPassword(password),
        'isAdmin': isAdmin ? 1 : 0,
        'fullName': fullName,
        'email': email,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Map<String, dynamic>?> getUser(
    String username,
    String password,
  ) async {
    final db = await database;

    // Hash the provided password
    String hashedPassword = _hashPassword(password);

    print('Login attempt:');
    print('Username: $username');
    print('Provided password hash: $hashedPassword');

    // First check if the username exists
    final userCheck = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (userCheck.isEmpty) {
      print('Login failed: Username not found');
      return null;
    }

    // Now check username and password combination
    final results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    print('Query results: ${results.length} matches found');
    if (results.isNotEmpty) {
      print('Login successful: User found');
      print('User details: ${results.first}');
    } else {
      print('Login failed: Invalid password');
      final storedUser = userCheck.first;
      print('Stored password hash: ${storedUser['password']}');
    }

    return results.isNotEmpty ? results.first : null;
  }

  Future<String> insertFlight(Map<String, dynamic> flight) async {
    final db = await database;
    final id = const Uuid().v4();
    flight['id'] = id;
    flight['createdAt'] = DateTime.now().toIso8601String();

    print('Inserting flight: $flight');
    try {
      // Validate required fields
      final requiredFields = [
        'type', 'fromCity', 'fromCode', 'toCity', 'toCode',
        'airline', 'date', 'time', 'price', 'seats'
      ];
      
      for (final field in requiredFields) {
        if (!flight.containsKey(field) || flight[field] == null) {
          throw Exception('Missing required field: $field');
        }
      }

      // Validate data types
      if (flight['price'] is! num) {
        throw Exception('Price must be a number');
      }
      if (flight['seats'] is! int) {
        throw Exception('Seats must be an integer');
      }

      await db.insert('flights', flight);
      print('Flight inserted successfully with ID: $id');
    } catch (e) {
      print('Error inserting flight: $e');
      throw Exception('Failed to insert flight: ${e.toString()}');
    }
    return id;
  }

  Future<void> updateFlight(Map<String, dynamic> flight) async {
    final db = await database;
    await db.update(
      'flights',
      flight,
      where: 'id = ?',
      whereArgs: [flight['id']],
    );
  }

  Future<void> deleteFlight(int id) async {
    final db = await database;
    await db.delete(
      'flights',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getFlights(String type) async {
    final db = await database;
    try {
      final results = await db.query(
        'flights',
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'createdAt DESC',
      );
      print('Retrieved ${results.length} $type flights');
      return results;
    } catch (e) {
      print('Error getting flights: $e');
      throw Exception('Failed to get flights: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTickets(String userId) async {
    final db = await database;
    final tickets = await db.rawQuery('''
      SELECT t.*, f.fromCity, f.toCity, f.date, f.time
      FROM tickets t
      JOIN flights f ON t.flightId = f.id
      WHERE t.userId = ?
      ORDER BY t.createdAt DESC
    ''', [userId]);
    return tickets;
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    final db = await database;
    await db.update(
      'tickets',
      {'status': status},
      where: 'id = ?',
      whereArgs: [ticketId],
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final db = await database;
    return await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<bool> bookFlight(String flightId, String userId) async {
    final db = await database;

    try {
      // Check if flight has available seats
      final List<Map<String, dynamic>> flights = await db.query(
        'flights',
        where: 'id = ?',
        whereArgs: [flightId],
      );

      if (flights.isEmpty) {
        print('Flight not found: $flightId');
        return false;
      }

      final int availableSeats = flights.first['seats'] as int;
      if (availableSeats <= 0) {
        print('No seats available for flight: $flightId');
        return false;
      }

      // Create booking and update seats in a transaction
      await db.transaction((txn) async {
        // Create booking
        await txn.insert('bookings', {
          'id': const Uuid().v4(),
          'flightId': flightId,
          'userId': userId,
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Update seats
        await txn.update(
          'flights',
          {'seats': availableSeats - 1},
          where: 'id = ?',
          whereArgs: [flightId],
        );
      });

      return true;
    } catch (e) {
      print('Error booking flight: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT f.*, b.createdAt
      FROM bookings b
      JOIN flights f ON b.flightId = f.id
      WHERE b.userId = ?
      ORDER BY b.createdAt DESC
    ''', [userId]);
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'safar_kaab.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('Database deleted successfully');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> createTicket(Map<String, dynamic> ticket) async {
    final db = await database;
    await db.insert('tickets', ticket);

    // Create notification for admin
    final admins = await db.query(
      'users',
      where: 'isAdmin = ?',
      whereArgs: [1],
    );

    for (final admin in admins) {
      await db.insert('notifications', {
        'id': const Uuid().v4(),
        'userId': admin['id'],
        'title': 'New Ticket Booking',
        'message':
            'A new ticket needs your approval. Reference: ${ticket['reference']}',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }
}
