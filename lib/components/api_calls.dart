import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://your-api.com/api";

  // Fetch all VM configs
  static Future<List<Map<String, dynamic>>> fetchAllVMConfigs() async {
    final response = await http.get(Uri.parse('$baseUrl/vms/configs'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load VM configurations');
    }
  }

  // Fetch a single VM by ID
  static Future<Map<String, dynamic>> fetchVM(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/vms/$id'));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('VM not found');
    }
  }

  // Create a new VM
  static Future<http.Response> createVM(Map<String, dynamic> vmData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/vms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vmData),
    );
    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to create VM');
    }
  }

  // Update VM
  static Future<http.Response> updateVM(String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/vms/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData),
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to update VM');
    }
  }

  // Delete VM
  static Future<http.Response> deleteVM(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/vms/$id'));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to delete VM');
    }
  }

  // Get list of all VMs
  static Future<List<Map<String, dynamic>>> getAllVMs() async {
    final response = await http.get(Uri.parse('$baseUrl/vms'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch VMs');
    }
  }

  // Get specific VM status
  static Future<Map<String, dynamic>> getVMStatus(String vmId) async {
    final response = await http.get(Uri.parse('$baseUrl/vms/$vmId/status'));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch VM status');
    }
  }

  // ---------------- User Section ---------------- //

  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Invalid credentials');
    }
  }

  // Get current user profile
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  // Update user profile
  static Future<String> updateUserProfile({
    required String token,
    required String username,
    required String password,
    required String email,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "username": username,
        "password": password,
        "email": email,
      }),
    );

    if (response.statusCode == 200) {
      return "User data updated successfully";
    } else {
      throw Exception("Failed to update user profile");
    }
  }

  // Get all users
  static Future<List<Map<String, dynamic>>> getUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  // Update user
  static Future<String> updateUser(String token, String userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return "User updated successfully";
    } else {
      throw Exception("Failed to update user");
    }
  }

  // Delete user
  static Future<String> deleteUser(String token, String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return "User deleted successfully";
    } else {
      throw Exception("Failed to delete user");
    }
  }

  // ---------------- Payment Section ---------------- //

  static Future<Map<String, dynamic>> getPaymentStatus(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/billing/status'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch payment status');
    }
  }
}
