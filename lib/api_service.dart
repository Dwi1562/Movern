import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _apiKey = dotenv.env['TMDB_API_KEY']!;
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List> searchMovies(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
