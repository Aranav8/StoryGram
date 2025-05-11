// services/story_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:collabwrite/data/models/story_model.dart'; // Adjust path if necessary
import 'package:collabwrite/services/auth_service.dart';   // Adjust path if necessary
import 'dart:math'; // For max()

class StoryService {
  static const String _baseUrl = 'http://18.232.150.66:8080';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders(
      {bool requireAuth = true, bool isDeleteOrPostNoBody = false}) async {
    final headers = <String, String>{};
    if (!isDeleteOrPostNoBody) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    if (requireAuth) {
      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        if (kDebugMode) {
          print('StoryService Warning: Auth token not found for a route that requires it.');
        }
      }
    }
    return headers;
  }

  // Helper to build request body for story updates/creations
  Map<String, dynamic> _buildStoryRequestBody(Story story, {bool isCreate = false}) {
    Map<String, dynamic> body = story.toJson(); // Get the full JSON from the model

    // --- Ensure User ID key matches backend expectation for POST/PATCH/PUT ---
    // Your backend GET response uses "UserID" (int) for the author.
    // Your failed PATCH log showed client sending "user_id" (int).
    // We need to be consistent. Story.toJson() now produces "UserID".
    // If your PATCH/POST endpoint *strictly* requires "user_id" (lowercase):
    if (body.containsKey('UserID') && body['UserID'] != null) { // Check if UserID is present and not null
      body['user_id'] = body.remove('UserID');
    } else if (!body.containsKey('user_id') && body['UserID'] == null) { // If UserID was null, ensure user_id is also null or absent
      body.remove('UserID'); // Remove UserID if it was null
      body['user_id'] = null; // Explicitly set user_id to null or let it be absent
    }
    // If UserID was not in body.toJson() output and story.authorId is valid, try to add it.
    else if (!body.containsKey('UserID') && !body.containsKey('user_id')) {
      int? authorIdAsInt = int.tryParse(story.authorId);
      if (authorIdAsInt != null) {
        body['user_id'] = authorIdAsInt; // Add as 'user_id' if backend expects this
      } else {
        if (kDebugMode) print("Warning: Could not parse story.authorId ('${story.authorId}') to int for user_id in request body.");
        body['user_id'] = null; // Or handle error
      }
    }


    // --- Handle Story ID (primary key of the story itself) ---
    // Backend GET response uses "ID" (int) for the story's own ID.
    // Story.toJson() produces "ID".
    // For create, if ID is a placeholder (e.g., 0), it might need to be removed or null.
    if (isCreate) {
      if (body['ID'] == 0) { // Assuming 0 is a client-side placeholder for a new story
        body.remove('ID'); // Let backend auto-generate ID
      }
    } else {
      // For updates, ensure 'last_edited' (or 'LastEdited') is current.
      // Story.toJson() already includes LastEdited.
      body['LastEdited'] = DateTime.now().toUtc().toIso8601String();

      // If PATCH/PUT body expects 'id' (lowercase) instead of 'ID' for the story's PK:
      // if (body.containsKey('ID')) {
      //   body['id'] = body.remove('ID');
      // }
    }
    if (kDebugMode) print("Prepared Request Body: ${jsonEncode(body)}");
    return body;
  }


  // --- Create Story ---
  Future<bool> createStory(Story story) async {
    const String url = '$_baseUrl/createstories';
    final Map<String, dynamic> requestBody = _buildStoryRequestBody(story, isCreate: true);

    // Critical check for user_id (owner of the story)
    if (requestBody['user_id'] == null && requestBody['UserID'] == null) { // Check both possible keys
      if (kDebugMode) print('StoryService Error: Valid user_id/UserID is required for createStory. authorId from model: ${story.authorId}');
      return false;
    }

    if (kDebugMode) print("StoryService: POST $url, Payload: ${jsonEncode(requestBody)}");
    try {
      final response = await http.post(Uri.parse(url), headers: await _getHeaders(), body: jsonEncode(requestBody));
      if (kDebugMode) print("StoryService: createStory response ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error creating story: $e');
      return false;
    }
  }

  Future<List<Story>> getStoriesByAuthor(String authorIdString) async {
    int? numericAuthorId = int.tryParse(authorIdString);
    if (numericAuthorId == null) {
      if (kDebugMode) print('StoryService Error: Non-numeric authorId for getStoriesByAuthor: $authorIdString');
      return [];
    }
    final String url = '$_baseUrl/GetStoriesByUser/$numericAuthorId';
    if (kDebugMode) print("StoryService: GET $url");
    try {
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      if (kDebugMode) print("StoryService: getStoriesByAuthor response ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => Story.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load stories for user. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching stories for user: $e');
    }
  }

  Future<List<Story>> getAllStories() async {
    final String url = '$_baseUrl/GetAllStories';
    if (kDebugMode) print("StoryService: GET $url");
    try {
      final response = await http.get(Uri.parse(url), headers: await _getHeaders(requireAuth: false));
      if (kDebugMode) print("StoryService: getAllStories response ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => Story.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load all stories. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print("StoryService: Exception in getAllStories: $e");
      throw Exception('Error fetching all stories: $e');
    }
  }

  Future<Story?> getStoryById(int storyId) async {
    final String url = '$_baseUrl/GetStories/$storyId';
    if (kDebugMode) print("StoryService: GET $url (for single story details)");
    try {
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      if (kDebugMode) print("StoryService: getStoryById response ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return Story.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        if (kDebugMode) print('Failed to load story $storyId. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching story $storyId: $e');
      return null;
    }
  }

  Future<Story?> updateStory(Story storyToUpdate) async {
    final String url = '$_baseUrl/updateStory/${storyToUpdate.id}';
    final Map<String, dynamic> requestBody = _buildStoryRequestBody(storyToUpdate);

    if (requestBody['user_id'] == null && requestBody['UserID'] == null) {
      if (kDebugMode) print('StoryService Error: Valid user_id/UserID is required for updateStory. authorId from model: ${storyToUpdate.authorId}');
      return null;
    }

    if (kDebugMode) print("StoryService: PUT $url, Payload: ${jsonEncode(requestBody)}");
    try {
      final response = await http.put(Uri.parse(url), headers: await _getHeaders(), body: jsonEncode(requestBody));
      if (kDebugMode) print("StoryService: updateStory response ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return Story.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        if (kDebugMode) print("Failed to update story. Status: ${response.statusCode}, Body: ${response.body}");
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error updating story: $e');
      return null;
    }
  }

  Future<bool> deleteStory(int storyId) async {
    final String url = '$_baseUrl/deleteStory/$storyId';
    if (kDebugMode) print("StoryService: DELETE $url");
    try {
      final response = await http.delete(Uri.parse(url), headers: await _getHeaders(isDeleteOrPostNoBody: true));
      if (kDebugMode) print("StoryService: deleteStory response ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Error deleting story: $e');
      return false;
    }
  }

  Future<List<Chapter>> getChaptersByStory(int storyId) async {
    final String url = '$_baseUrl/getchapterbystory/$storyId';
    if (kDebugMode) print("StoryService: GET $url");
    try {
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      if (kDebugMode) print("StoryService: getChaptersByStory response ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => Chapter.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load chapters. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching chapters: $e');
    }
  }

  Future<bool> incrementViewCount(int storyId) async {
    final Story? currentStory = await getStoryById(storyId);
    if (currentStory == null) {
      if (kDebugMode) print("StoryService Error: Could not fetch story $storyId to increment view count.");
      return false;
    }
    final Story storyWithIncrementedView = currentStory.copyWith(views: currentStory.views + 1);
    final Map<String, dynamic> requestBody = _buildStoryRequestBody(storyWithIncrementedView);

    if (requestBody['user_id'] == null && requestBody['UserID'] == null) {
      if (kDebugMode) print('StoryService Error: Valid user_id/UserID is required for incrementViewCount. authorId from model: ${currentStory.authorId}');
      return false;
    }

    final String url = '$_baseUrl/updateStory/$storyId';
    if (kDebugMode) print("StoryService: PATCH $url (increment view), Payload: ${jsonEncode(requestBody)}");
    try {
      final response = await http.patch(Uri.parse(url), headers: await _getHeaders(), body: jsonEncode(requestBody));
      if (kDebugMode) print("StoryService: incrementViewCount response ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Error incrementing view count for story $storyId: $e');
      return false;
    }
  }

  Future<bool> likeStory(int storyId) async {
    final Story? currentStory = await getStoryById(storyId);
    if (currentStory == null) {
      if (kDebugMode) print("StoryService Error: Could not fetch story $storyId to like.");
      return false;
    }
    final Story storyWithIncrementedLikes = currentStory.copyWith(likes: currentStory.likes + 1);
    final Map<String, dynamic> requestBody = _buildStoryRequestBody(storyWithIncrementedLikes);

    if (requestBody['user_id'] == null && requestBody['UserID'] == null) {
      if (kDebugMode) print('StoryService Error: Valid user_id/UserID is required for likeStory. authorId from model: ${currentStory.authorId}');
      return false;
    }

    final String url = '$_baseUrl/updateStory/$storyId';
    if (kDebugMode) print("StoryService: PATCH $url (like story), Payload: ${jsonEncode(requestBody)}");
    try {
      final response = await http.patch(Uri.parse(url), headers: await _getHeaders(), body: jsonEncode(requestBody));
      if (kDebugMode) print("StoryService: likeStory response ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('Error liking story $storyId: $e');
      return false;
    }
  }

  Future<bool> unlikeStory(int storyId) async {
    final Story? currentStory = await getStoryById(storyId);
    if (currentStory == null) {
      if (kDebugMode) print("StoryService Error: Could not fetch story $storyId to unlike.");
      return false;
    }
    if (currentStory.likes <= 0) {
      if (kDebugMode) print("StoryService Info: Story $storyId already has 0 likes. Cannot unlike further.");
      return true;
    }
    final Story storyWithDecrementedLikes = currentStory.copyWith(likes: max(0, currentStory.likes - 1));
    final Map<String, dynamic> requestBody = _buildStoryRequestBody(storyWithDecrementedLikes);

    if (requestBody['user_id'] == null && requestBody['UserID'] == null) {
      if (kDebugMode) print('StoryService Error: Valid user_id/UserID is required for unlikeStory. authorId from model: ${currentStory.authorId}');
      return false;
    }

    final String url = '$_baseUrl/updateStory/$storyId';
    if (kDebugMode) print("StoryService: PATCH $url (unlike story), Payload: ${jsonEncode(requestBody)}");
    try {
      final response = await http.patch(Uri.parse(url), headers: await _getHeaders(), body: jsonEncode(requestBody));
      if (kDebugMode) print("StoryService: unlikeStory response ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Error unliking story $storyId: $e');
      return false;
    }
  }

  Future<bool> getLikeStatus(int storyId) async {
    final String url = '$_baseUrl/GetStories/$storyId';
    if (kDebugMode) print("StoryService: GET $url (for like status for story $storyId)");
    try {
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      if (kDebugMode) print("StoryService: getLikeStatus response ${response.statusCode}, Body (story $storyId): ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // >>> IMPORTANT: VERIFY THIS FIELD NAME FROM YOUR BACKEND <<<
        // This field must be a boolean in the story's JSON indicating if the *current authenticated user* has liked it.
        if (data.containsKey('currentUserHasLiked')) { // Example field name
          return data['currentUserHasLiked'] as bool? ?? false;
        } else if (data.containsKey('user_has_liked')) { // Another common example
          return data['user_has_liked'] as bool? ?? false;
        } else if (data.containsKey('isLikedByCurrentUser')) { // Yet another example
          return data['isLikedByCurrentUser'] as bool? ?? false;
        }
        else {
          if (kDebugMode) print("StoryService Warning: 'currentUserHasLiked' (or similar) field not found in story response for getLikeStatus. Defaulting to false. Story ID: $storyId");
          return false;
        }
      }
      if (kDebugMode) print("StoryService: Failed to get like status for story $storyId (Status: ${response.statusCode}), defaulting to false.");
      return false;
    } catch (e) {
      if (kDebugMode) print('Error getting like status for story $storyId: $e');
      return false;
    }
  }
}