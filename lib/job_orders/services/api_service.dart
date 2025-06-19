import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tbtech/models/job_order.dart';
import 'package:tbtech/utils/constants.dart';
import 'package:tbtech/errors/exceptions.dart';


class ApiService {
  final String _baseUrl = baseApiUrl;

  Future<List<JobOrder>> fetchJobOrders(String token, String visitDate) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/user-schedule?visit_date=$visitDate'),
        headers: {
          "Authorization": "Bearer $token"
        }
        ).timeout(const Duration(seconds: 15));
    try {
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((jsonJobOrder) => JobOrder.fromJson(jsonJobOrder)).toList();
      } else {
        throw ClientException(
          message: 'Failed to load posts from API (Status: ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException(message: "No Internet connection while fetching posts.");
    } on FormatException {
      throw UnexpectedResponseException(message: "Bad response format from API.");
    } on TimeoutException {
      throw NetworkException(message: "Request to API timed out.");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}