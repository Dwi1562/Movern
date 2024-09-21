import 'package:flutter/material.dart';
import 'package:movie_tmdb_api/trailer_movie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart'; // Make sure you import your ApiService

class MovieDetailScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  MovieDetailScreen({required this.movie});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final ApiService _apiService = ApiService();
  List _videos = [];

  @override
  void initState() {
    super.initState();
    _fetchMovieVideos();
  }

  // Fetch movie videos from the API
  void _fetchMovieVideos() async {
    final movieId = widget.movie['id'];
    if (movieId != null) {
      try {
        final videos = await _apiService.getMovieVideos(movieId);
        setState(() {
          _videos = videos;
          print(_videos);
        });
      } catch (e) {
        print('Error fetching videos: $e');
      }
    }
  }

  // Launch a URL (for YouTube trailer)
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie['title'] ?? 'Movie Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie details
            Center(
              child: Image.network(
                _apiService.getPosterUrl(widget.movie['poster_path'] ?? ''),
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 150);
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              widget.movie['title'] ?? 'Unknown Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Release Date: ${widget.movie['release_date'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Text(
                  'Rating: ${widget.movie['vote_average'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(width: 10.0),
                Icon(Icons.star, color: Colors.yellow[700]),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.movie['overview'] ?? 'No synopsis available.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),

            // Display the watch trailer button if video is available
            _videos.isNotEmpty
                ? ElevatedButton.icon(
                    icon: Icon(Icons.play_circle_outline),
                    label: Text('Watch Trailer'),
                    onPressed: () {
                      final youtubeTrailer = _videos.firstWhere(
                        (video) =>
                            video['site'] == 'YouTube' &&
                            video['type'] == 'Trailer',
                        orElse: () => null,
                      );

                      if (youtubeTrailer != null) {
                        final youtubeKey =
                            youtubeTrailer['key']; // Extract YouTube video key

                        // Navigate to the TrailerScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrailerScreen(youtubeKey: youtubeKey),
                          ),
                        );
                      } else {
                        // Show a message if no trailer is available
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'No YouTube trailer available for this movie.'),
                        ));
                      }
                    },
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
