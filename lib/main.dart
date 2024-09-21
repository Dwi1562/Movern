import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_tmdb_api/movie_detail_screen.dart';
import 'api_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovieSearchScreen(),
    );
  }
}

class MovieSearchScreen extends StatefulWidget {
  @override
  _MovieSearchScreenState createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  List _movies = [];

  void _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _movies = [];
      });
      return;
    }

    final movies = await _apiService.searchMovies(query);
    setState(() {
      _movies = movies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
                onChanged: _search, // Call _search every time the text changes
              ),
            ),
            SizedBox(height: 10), // Adds spacing below the search bar
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(movie: movie),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // Movie Poster
                          movie['poster_path'] != null
                              ? Image.network(
                                  'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 75,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image, size: 50);
                                  },
                                )
                              : Container(
                                  width: 50,
                                  height: 75,
                                  color: Colors.grey,
                                  child: Icon(Icons.image_not_supported),
                                ),
                          SizedBox(width: 10),
                          // Movie Details (Title, Year, Rating)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '(${movie['release_date']?.substring(0, 4) ?? 'Unknown'})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.orange, size: 18),
                                    SizedBox(width: 5),
                                    Text(
                                      movie['vote_average'].toString(),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
