import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _apiKey = dotenv.env['TMDB_API_KEY'] ?? ''; // Pastikan API key tersedia di .env
  final String _baseUrl = 'https://api.themoviedb.org/3';

  // Method to search for movies based on a query
  Future<List> searchMovies(String query) async {
    final url = '$_baseUrl/search/movie?api_key=$_apiKey&query=$query';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load movies');
    }
  }

  // Method to get poster URL for a movie
  String getPosterUrl(String path) {
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  // Method to get video details (trailers, etc.) for a movie
  Future<List> getMovieVideos(int movieId) async {
    final url = '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
