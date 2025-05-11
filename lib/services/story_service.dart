// services/story_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:collabwrite/data/models/story_model.dart';
import 'package:collabwrite/services/auth_service.dart';

class StoryService {
  static const String _baseUrl = 'http://18.232.150.66:8080';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (requireAuth) {
      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        print('Warning: Auth token not found for a route that requires it.');
      }
    }
    return headers;
  }

  // Create a new story
  Future<bool> createStory(Story story) async {
    const String url = '$_baseUrl/createstories';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({
          'id': story.id,
          'title': story.title,
          'description': story.description ?? '',
          'cover_image':
              story.coverImage ?? '', // Send empty string if no image
          'user_id': 1,
          'likes': story.likes,
          'views': story.views,
          'published_date': story.publishedDate?.toUtc().toIso8601String(),
          'last_edited': story.lastEdited.toUtc().toIso8601String(),
          'story_type': story.storyType,
          'status': story.status.toString().split('.').last.toLowerCase(),
          'genres': story.genres,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Story created successfully: ${story.title}');
        return true;
      } else {
        print(
            'Failed to create story: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating story: ${e.toString()}');
      return false;
    }
  }

  // Existing method for getting stories by author
  Future<List<Story>> getStoriesByAuthor(String authorId) async {
    final String url = '$_baseUrl/GetStoriesByUser/$authorId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        try {
          return responseData
              .map((data) => Story.fromJson(data as Map<String, dynamic>))
              .toList();
        } catch (e) {
          print('Error parsing stories: $e');
          print('Received data for stories: $responseData');
          throw Exception(
              'Failed to parse stories for author (ID: $authorId). Error: $e');
        }
      } else {
        throw Exception(
            'Failed to load stories for author (ID: $authorId). Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception(
          'Error fetching stories for author (ID: $authorId): ${e.toString()}');
    }
  }
}
