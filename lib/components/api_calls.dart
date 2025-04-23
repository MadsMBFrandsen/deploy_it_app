import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://staging.deploy-it.dk/api";

  // Helper method to get token
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isEmpty) {
      throw Exception('No auth token found');
    }
    return token;
  }

  // Fetch all VM configs
  static Future<List<Map<String, dynamic>>> fetchAllVMConfigs() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/configurations'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );



    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load VM configurations: ${response.body}');
    }
  }


  // Fetch all VM configs
  static Future<List<Map<String, dynamic>>> fetchAllVMConfigPackages() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/packages'), // <- Adjust endpoint if needed!
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load packages: ${response.body}');
    }
  }



  // Fetch a single VM by ID
  static Future<Map<String, dynamic>> fetchVM(String id) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/vms/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('VM not found');
    }
  }

  // Create a new VM
  static Future<http.Response> createVM(Map<String, dynamic> vmData) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/vms'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/vms/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/vms/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to delete VM');
    }
  }

  // Get list of all VMs
  static Future<List<Map<String, dynamic>>> getAllVMs() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/vms'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );



    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch VMs: ${response.body}');
    }
  }

  // Get specific VM status
  static Future<Map<String, dynamic>> getVMStatus(String vmId) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/vms/$vmId/status'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch VM status');
    }
  }

  // ---------------- User Section ---------------- //

  // Login (no token needed yet)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Invalid credentials');
    }
  }

  // Get current user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  static Future<String> signUpUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> body = {
      "name": username,
      "email": email,
      "password": password,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return "User created successfully";
    } else {
      try {
        final responseData = jsonDecode(response.body);

        if (responseData['message'] != null) {
          throw Exception(responseData['message']);
        } else {
          throw Exception("Failed to create user");
        }
      } catch (e) {
        throw Exception(response.body);
      }
    }
  }



  // Update user profile
  static Future<String> updateUserProfile({
    required String username,
    String? oldPassword,
    String? newPassword,
    required String email,
  }) async {
    final token = await _getToken();

    // Build body dynamically
    final Map<String, dynamic> body = {
      "username": username,
      "email": email,
    };

    if (oldPassword != null && newPassword != null) {
      body["oldPassword"] = oldPassword;
      body["newPassword"] = newPassword;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/user/update'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return "User data updated successfully";
    } else {
      throw Exception("Failed to update user profile");
    }
  }


  // Get all users
  static Future<List<Map<String, dynamic>>> getUsers() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  // Update user
  static Future<String> updateUser(String userId, Map<String, dynamic> data) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
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
  static Future<String> deleteUser(String userId) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return "User deleted successfully";
    } else {
      throw Exception("Failed to delete user");
    }
  }




  // ---------------- Payment Section ---------------- //

  static Future<Map<String, dynamic>> getPaymentStatus() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/user/paid-status'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch payment status');
    }
  }

}