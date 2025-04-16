import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://fake-api.local/api/vms";

  // --------------------------- Auth Headers -------------------------------
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --------------------------- VM Configs -------------------------------
  static Future<List<Map<String, dynamic>>> vmconfig() async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      {
        "id": "9200",
        "name": "Standard VPS",
        "desc": "A mid-tier VPS configuration",
        "hardware": {"memory": 8, "processors": 1, "cores": 4, "disksize": 100}
      },
      {
        "id": "9300",
        "name": "Premium VPS",
        "desc": "High performance",
        "hardware": {"memory": 16, "processors": 1, "cores": 8, "disksize": 250}
      },
      {
        "id": "9400",
        "name": "Ultra VPS",
        "desc": "Next-gen config",
        "hardware": {"memory": 32, "processors": 2, "cores": 16, "disksize": 500}
      },
    ];
  }

  static Future<http.Response> createVM(Map<String, dynamic> vmData) async {
    final headers = await _getAuthHeaders();
    await Future.delayed(Duration(seconds: 1));
    print("Creating VM with headers: $headers and data: $vmData");
    return http.Response(jsonEncode({"message": "VM created successfully"}), 201);
  }

  static Future<Map<String, dynamic>> fetchVM(String id) async {
    await Future.delayed(Duration(milliseconds: 800));
    print("Fetching VM with ID: $id");

    final fakeData = {
      "9000": {
        "id": "9000",
        "name": "default vm config",
        "desc": "A default config",
        "hardware": {"memory": 2, "processors": 1, "cores": 2, "disksize": 30}
      },
      "9100": {
        "id": "9100",
        "name": "Basic VPS",
        "desc": "A starter VPS configuration",
        "hardware": {"memory": 4, "processors": 1, "cores": 2, "disksize": 50}
      },
      "9200": {
        "id": "9200",
        "name": "Standard VPS",
        "desc": "A mid-tier VPS configuration",
        "hardware": {"memory": 8, "processors": 1, "cores": 4, "disksize": 100}
      },
      "9300": {
        "id": "9300",
        "name": "Premium VPS",
        "desc": "A high-performance VPS configuration",
        "hardware": {"memory": 16, "processors": 1, "cores": 8, "disksize": 250}
      }
    };

    if (!fakeData.containsKey(id)) {
      throw Exception("VM not found");
    }

    return fakeData[id]!;
  }

  static Future<List<Map<String, dynamic>>> fetchAllVMConfigs() async {
    await Future.delayed(Duration(milliseconds: 800));
    return [
      {
        "id": "9000",
        "name": "default vm config",
        "desc": "A default config",
        "hardware": {"memory": 2, "processors": 1, "cores": 2, "disksize": 30}
      },
      {
        "id": "9100",
        "name": "Basic VPS",
        "desc": "A starter VPS configuration",
        "hardware": {"memory": 4, "processors": 1, "cores": 2, "disksize": 50}
      },
      {
        "id": "9200",
        "name": "Standard VPS",
        "desc": "A mid-tier VPS configuration",
        "hardware": {"memory": 8, "processors": 1, "cores": 4, "disksize": 100}
      },
      {
        "id": "9300",
        "name": "Premium VPS",
        "desc": "A high-performance VPS configuration",
        "hardware": {"memory": 16, "processors": 1, "cores": 8, "disksize": 250}
      }
    ];
  }

  static Future<http.Response> updateVM(String id, Map<String, dynamic> updatedData) async {
    await Future.delayed(Duration(seconds: 1));
    print("Updating VM $id with data: $updatedData");
    return http.Response(jsonEncode({"message": "VM updated successfully"}), 200);
  }

  static Future<http.Response> deleteVM(String id) async {
    await Future.delayed(Duration(milliseconds: 600));
    print("Deleting VM with ID: $id");
    return http.Response(jsonEncode({"message": "VM deleted successfully"}), 200);
  }

  // --------------------------- Users -------------------------------
  static Map<String, dynamic> _mockUser = {
    "username": "SuperMan",
    "password": "*****",
    "email": "clark@kent.kryp",
    "role": "admin",
  };

  static const String _mockToken = "mocked-token-1234";

  static Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(Duration(milliseconds: 500));
    return Map<String, dynamic>.from(_mockUser);
  }

  static Future<String> updateUserProfile({
    required String username,
    required String password,
    required String email,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    print("Updating user: $username, email: $email");

    _mockUser['username'] = username;
    _mockUser['password'] = '*****';
    _mockUser['email'] = email;

    return "User data updated successfully";
  }

  static final List<Map<String, dynamic>> _mockUsers = [
    {'id': '1', 'name': 'Alice Johnson', 'email': 'alice@example.com'},
    {'id': '2', 'name': 'Bob Smith', 'email': 'bob@example.com'},
    {'id': '3', 'name': 'Charlie Brown', 'email': 'charlie@example.com'},
  ];

  static Future<List<Map<String, dynamic>>> getUsers() async {
    await Future.delayed(Duration(milliseconds: 500));
    return List<Map<String, dynamic>>.from(_mockUsers);
  }

  static Future<void> deleteUser(String userId) async {
    await Future.delayed(Duration(milliseconds: 300));
    _mockUsers.removeWhere((user) => user['id'] == userId);
  }

  static Future<MockHttpResponse> updateUser(String userId, Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 400));
    final index = _mockUsers.indexWhere((user) => user['id'] == userId);
    if (index == -1) throw Exception('User not found');

    _mockUsers[index] = {'id': userId, ...data};
    return MockHttpResponse(statusCode: 200, body: '{"message": "User updated successfully"}');
  }

  // --------------------------- Auth -------------------------------
  static const _validUsername = "admin";
  static const _validPassword = "1234";

  static Future<Map<String, dynamic>> login(String username, String password) async {
    await Future.delayed(Duration(milliseconds: 600));

    print('***');
    print(_validUsername);
    print(_validPassword);
    print('***');

    if (username == _validUsername && password == _validPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _mockToken);

      return {"role": "admin"};
    } else {
      throw Exception("Invalid username or password");
    }
  }

  // --------------------------- Billing -------------------------------
  static Future<Map<String, dynamic>> getPaymentStatus() async {
    await Future.delayed(Duration(milliseconds: 800));
    final nextPaymentDate = DateTime(2025, 3, 12);
    final today = DateTime.now();
    final difference = nextPaymentDate.difference(today).inDays;
    final isOverdue = difference < 0;

    return {
      "hasPaid": false,
      "nextPayment": "${nextPaymentDate.year}-${_twoDigits(nextPaymentDate.month)}-${_twoDigits(nextPaymentDate.day)}",
      "daysRemaining": difference,
      "isOverdue": isOverdue,
    };
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // --------------------------- VM Status -------------------------------
  static Future<List<Map<String, dynamic>>> getAllVMs() async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      {"id": "vps-001", "name": "My Premium VPS"},
      {"id": "vps-002", "name": "Backup VPS"},
    ];
  }

  static Future<Map<String, dynamic>> getVMStatus(String vmId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return {
      "cpu_usage": _randomPercent(),
      "ram_usage": _randomPercent(),
      "storage_usage": _randomPercent(),
      "chart_data": List.generate(7, (_) => 25 + Random().nextInt(71)),
      "logs": [
        "CPU usage spike detected",
        "Scheduled backup completed",
        "Disk usage at 90%",
        "Auto update applied",
        "SSH login from unknown IP"
      ]
    };
  }

  static Future<Map<String, dynamic>> getStatusData() async {
    await Future.delayed(Duration(milliseconds: 800));
    return {
      "cpuUsage": 0.72,
      "ramUsage": 0.58,
      "storageUsage": 0.91,
      "chartData": [0.3, 0.5, 0.7, 0.6, 0.85, 0.65, 0.75],
      "logs": [
        "Disk almost full",
        "High memory usage",
        "CPU load spike",
        "Service restarted",
        "Unauthorized login attempt"
      ],
    };
  }

  static String _randomPercent() {
    final value = 25 + Random().nextInt(71);
    return '$value%';
  }
}

class MockHttpResponse {
  final int statusCode;
  final String body;

  MockHttpResponse({required this.statusCode, required this.body});
}
