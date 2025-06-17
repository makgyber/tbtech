import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbtech/utils/constants.dart';

class ApiAuthService {
  final String _baseUrl; // Your API base URL
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';

  ApiAuthService({required String baseUrl}) : _baseUrl = baseUrl;

  Future<bool> loginAndSaveToken(String email, String password) async {
    final Uri tokenUrl = Uri.parse('$_baseUrl/sanctum/token'); // Or your specific login endpoint

    try {
      final response = await http.post(
        tokenUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Add any other headers your API requires
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'device_name': 'mobile'
        }),
      );

      if (response.statusCode == 200) {
        // Successfully authenticated
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? token = responseData['token']; // Common token keys

        if (token != null && token.isNotEmpty) {
          await _saveUserData(token);
          print('Token received and saved successfully.');
          return true;
        } else {
          print('Error: Token not found in API response.');
          // You might want to throw a specific exception here
          return false;
        }
      } else {
        // Handle API errors (e.g., 401 Unauthorized, 400 Bad Request)
        print('Error logging in: ${response.statusCode}');
        print('Response body: ${response.body}');
        // You might want to throw a specific exception here based on status code
        return false;
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('Exception during login: $e');
      return false;
    }
  }

  Future<void> _saveUserData(String token) async {
    final Uri userUrl = Uri.parse('$_baseUrl/user'); // Or your specific login endpoint
    try {
      final response = await http.get(
        userUrl,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8'
        }
      );

      if (response.statusCode == 200) {
        // Successfully authenticated
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final int? userId = responseData['id'];
        final String? userName = responseData['name'];

        if ((userId != null) && (userName != null && userName.isNotEmpty)) {
          await _saveUserAndToken(token, userId, userName);
        }
      }
    } catch (e) {
      print('Exception during login: $e');
    }

  }


  Future<void> _saveUserAndToken(String token, int userId, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    print('Token removed.');
  }

  // Optional: Check if user is authenticated (has a token)
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

// Optional: If using Riverpod to provide this service
final apiAuthServiceProvider = Provider<ApiAuthService>((ref) {
  return ApiAuthService(baseUrl: baseApiUrl); // Replace with your actual API URL
});