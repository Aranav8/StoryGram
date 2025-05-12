// services/story_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:collabwrite/data/models/story_model.dart';
import 'package:collabwrite/services/auth_service.dart';
import 'dart:math';

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
          print(
              'StoryService Warning: Auth token not found for a route that requires it.');
        }
      }
    }
    return headers;
  }

  Map<String, dynamic> _buildStoryRequestBody(Story story,
      {bool isCreate = false}) {
    Map<String, dynamic> body = story.toJson();

    // Remove 'Chapters' from the main story create/update payload
    // if chapters are handled by separate endpoints.
    body.remove('Chapters');
    body.remove('chapters');

    if (body.containsKey('UserID') && body['UserID'] != null) {
      body['user_id'] = body.remove('UserID');
    } else if (!body.containsKey('user_id') && body['UserID'] == null) {
      body.remove('UserID');
      body['user_id'] = null;
    } else if (!body.containsKey('UserID') && !body.containsKey('user_id')) {
      int? authorIdAsInt = int.tryParse(story.authorId);
      body['user_id'] = authorIdAsInt;
    }

    if (!isCreate) {
      body['LastEdited'] = DateTime.now().toUtc().toIso8601String();
    }
    if (kDebugMode)
      print(
          "Prepared Story Request Body for ${isCreate ? 'CREATE' : 'UPDATE'}: ${jsonEncode(body)}");
    return body;
  }

  Future<Story?> createStory(Story storyMetadata) async {
    // Now expects mainly metadata
    const String url = '$_baseUrl/createstories';
    // _buildStoryRequestBody will now pass the client-generated ID for new stories.
    // It will NOT include chapters if removed in _buildStoryRequestBody.
    final Map<String, dynamic> requestBody =
        _buildStoryRequestBody(storyMetadata, isCreate: true);

    if (requestBody['user_id'] == null) {
      if (kDebugMode)
        print(
            'StoryService Error: Valid user_id is required for createStory. authorId from model: ${storyMetadata.authorId}');
      return null;
    }
    if (!requestBody.containsKey('ID') ||
        requestBody['ID'] == null ||
        (requestBody['ID'] is int && requestBody['ID'] == 0)) {
      if (kDebugMode)
        print(
            'StoryService Error: Valid Story ID is required in the payload for createStory. Current ID in payload: ${requestBody['ID']}');
      return null;
    }

    if (kDebugMode)
      print(
          "StoryService: POST $url (Story Metadata), Payload: ${jsonEncode(requestBody)}");
    try {
      final response = await http.post(Uri.parse(url),
          headers: await _getHeaders(), body: jsonEncode(requestBody));
      if (kDebugMode)
        print(
            "StoryService: createStory (Metadata) response ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        // The response here might NOT have chapters.
        return Story.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error creating story metadata: $e');
      return null;
    }
  }

  // --- Chapter Specific Methods ---

  Future<Chapter?> createChapter(
      {required int storyId,
      required String title,
      required String content,
      int chapterNumber = 1, // Default or determine dynamically
      bool isComplete = false}) async {
    const String url = '$_baseUrl/createchapter';
    final Map<String, dynamic> requestBody = {
      "story_id": storyId,
      "title": title,
      "content": content,
      "chapter_number": chapterNumber,
      "is_complete": isComplete,
      // "created_at" and "updated_at" are usually set by the backend
    };
    if (kDebugMode)
      print(
          "StoryService: POST $url (Create Chapter), Payload: ${jsonEncode(requestBody)}");
    try {
      final response = await http.post(Uri.parse(url),
          headers: await _getHeaders(), body: jsonEncode(requestBody));
      if (kDebugMode)
        print(
            "StoryService: createChapter response ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        // 201 Created is typical
        return Chapter.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error creating chapter for story $storyId: $e');
      return null;
    }
  }

  Future<Chapter?> getChapterById(String chapterId) async {
    // Assuming chapter ID can be string or int based on your model
    final String url = '$_baseUrl/getchapterbyid/$chapterId';
    if (kDebugMode) print("StoryService: GET $url");
    try {
      final response =
          await http.get(Uri.parse(url), headers: await _getHeaders());
      if (kDebugMode)
        print(
            "StoryService: getChapterById response ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return Chapter.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error fetching chapter $chapterId: $e');
      return null;
    }
  }

  // getChaptersByStory was already defined, ensure it's correct
  Future<List<Chapter>> getChaptersByStory(int storyId) async {
    final String url = '$_baseUrl/getchapterbystory/$storyId';
    if (kDebugMode)
      print("StoryService: GET $url (Chapters for story $storyId)");
    try {
      final response =
          await http.get(Uri.parse(url), headers: await _getHeaders());
      if (kDebugMode)
        print(
            "StoryService: getChaptersByStory response ${response.statusCode}, Body: ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        if (responseData.isEmpty) {
          if (kDebugMode)
            print(
                "StoryService: No chapters found for story $storyId from backend.");
          return [];
        }
        return responseData
            .map((data) => Chapter.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        if (kDebugMode)
          print(
              'Failed to load chapters for story $storyId. Status: ${response.statusCode}');
        return []; // Return empty list on failure rather than throwing, or handle error upstream
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching chapters for story $storyId: $e');
      return []; // Return empty list on exception
    }
  }

  Future<Chapter?> updateChapter(
      {required String
          chapterId, // Assuming chapter ID from your model (string or int)
      required int storyId,
      required String title,
      required String content,
      required int chapterNumber,
      required bool isComplete}) async {
    final String url = '$_baseUrl/updatechapter/$chapterId';
    final Map<String, dynamic> requestBody = {
      "story_id": storyId, // Backend might use this for validation or linking
      "title": title,
      "content": content,
      "chapter_number": chapterNumber,
      "is_complete": isComplete,
    };
    if (kDebugMode)
      print(
          "StoryService: PUT $url (Update Chapter), Payload: ${jsonEncode(requestBody)}");
    try {
      final response = await http.put(Uri.parse(url),
          headers: await _getHeaders(), body: jsonEncode(requestBody));
      if (kDebugMode)
        print(
            "StoryService: updateChapter response ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return Chapter.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error updating chapter $chapterId: $e');
      return null;
    }
  }

  Future<bool> deleteChapter(String chapterId) async {
    final String url = '$_baseUrl/deletechapter/$chapterId';
    if (kDebugMode) print("StoryService: DELETE $url (Delete Chapter)");
    try {
      final response = await http.delete(Uri.parse(url),
          headers: await _getHeaders(isDeleteOrPostNoBody: true));
      if (kDebugMode)
        print(
            "StoryService: deleteChapter response ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Error deleting chapter $chapterId: $e');
      return false;
    }
  }

  // ... Other StoryService methods (getStoriesByAuthor, getStoryById, updateStory etc.)
  // updateStory should primarily update story metadata.
  Future<Story?> updateStory(Story storyMetadata) async {
    final String url = '$_baseUrl/updateStory/${storyMetadata.id}';
    final Map<String, dynamic> requestBody =
        _buildStoryRequestBody(storyMetadata, isCreate: false);

    if (requestBody['user_id'] == null) {
      if (kDebugMode)
        print(
            'StoryService Error: Valid user_id is required for updateStory. authorId from model: ${storyMetadata.authorId}');
      return null;
    }
    if (!requestBody.containsKey('ID') ||
        requestBody['ID'] == null ||
        (requestBody['ID'] is int && requestBody['ID'] == 0)) {
      if (kDebugMode)
        print(
            'StoryService Error: Story ID is missing or invalid in the request body for updateStory. Original story ID: ${storyMetadata.id}. Current ID in payload: ${requestBody['ID']}');
      return null;
    }

    if (kDebugMode)
      print(
          "StoryService: PUT $url (Update Story Metadata), Payload: ${jsonEncode(requestBody)}");
    try {
      final response = await http.put(Uri.parse(url),
          headers: await _getHeaders(), body: jsonEncode(requestBody));
      if (kDebugMode)
        print(
            "StoryService: updateStory (Metadata) response ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return Story.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        if (kDebugMode)
          print(
              "Failed to update story metadata. Status: ${response.statusCode}, Body: ${response.body}");
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error updating story metadata: $e');
      return null;
    }
  }

  // ... (getStoriesByAuthor, getAllStories, getStoryById, updateStory, deleteStory, etc., remain the same as the previous good version)
  Future<List<Story>> getStoriesByAuthor(String authorIdString) async {
    int? numericAuthorId = int.tryParse(authorIdString);
    if (numericAuthorId == null) {
      if (kDebugMode)
        print(
            'StoryService Error: Non-numeric authorId for getStoriesByAuthor: $authorIdString');
      return [];
    }
    final String url = '$_baseUrl/GetStoriesByUser/$numericAuthorId';
    if (kDebugMode) print("StoryService: GET $url");
    try {
      final response =
          await http.get(Uri.parse(url), headers: await _getHeaders());
      if (kDebugMode)
        print(
            "StoryService: getStoriesByAuthor response ${response.statusCode}, Body: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData
            .map((data) => Story.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Failed to load stories for user. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching stories for user: $e');
      throw Exception('Error fetching stories for user: $e');
    }
  }

  Future<List<Story>> getAllStories() async {
    final String url = '$_baseUrl/GetAllStories';
    if (kDebugMode) print("StoryService: GET $url");
    try {
      final response = await http.get(Uri.parse(url),
          headers: await _getHeaders(requireAuth: false));
      if (kDebugMode)
        print(
            "StoryService: getAllStories response ${response.statusCode}, Body: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData
            .map((data) => Story.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Failed to load all stories. Status: ${response.statusCode}, Body: ${response.body}');
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
      final response =
          await http.get(Uri.parse(url), headers: await _getHeaders());
      if (kDebugMode)
        print(
            "StoryService: getStoryById response ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return Story.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        if (kDebugMode)
          print(
              'Failed to load story $storyId. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching story $storyId: $e');
      return null;
    }
  }

  Future<bool> deleteStory(int storyId) async {
    final String url = '$_baseUrl/deleteStory/$storyId';
    if (kDebugMode) print("StoryService: DELETE $url");
    try {
      final response = await http.delete(Uri.parse(url),
          headers: await _getHeaders(isDeleteOrPostNoBody: true));
      if (kDebugMode)
        print(
            "StoryService: deleteStory response ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Error deleting story: $e');
      return false;
    }
  }

  Future<bool> incrementViewCount(int storyId) async {
    final Story? currentStory = await getStoryById(storyId);
    if (currentStory == null) {
      if (kDebugMode)
        print(
            "StoryService Error: Could not fetch story $storyId to increment view count.");
      return false;
    }
    final Map<String, dynamic> patchData = {'Views': currentStory.views + 1};
    final String url = '$_baseUrl/updateStory/$storyId';

    if (kDebugMode)
      print(
          "StoryService: PATCH $url (increment view), Payload: ${jsonEncode(patchData)}");
    try {
      final response = await http.patch(Uri.parse(url),
          headers: await _getHeaders(), body: jsonEncode(patchData));
      if (kDebugMode)
        print(
            "StoryService: incrementViewCount response ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode)
        print('Error incrementing view count for story $storyId: $e');
      return false;
    }
  }

  Future<bool> likeStory(int storyId) async {
    final Story? currentStory = await getStoryById(storyId);
    if (currentStory == null) {
      if (kDebugMode)
        print("StoryService Error: Could not fetch story $storyId to like.");
      return false;
    }
    final Map<String, dynamic> patchData = {'Likes': currentStory.likes + 1};
    final String url = '$_baseUrl/updateStory/$storyId';

    if (kDebugMode)
      print(
          "StoryService: PATCH $url (like story), Payload: ${jsonEncode(patchData)}");
    try {
      final response = await http.patch(Uri.parse(url),
          headers: await _getHeaders(), body: jsonEncode(patchData));
      if (kDebugMode)
        print(
            "StoryService: likeStory response ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('Error liking story $storyId: $e');
      return false;
    }
  }

  Future<bool> unlikeStory(int storyId) async {
    final Story? currentStory = await getStoryById(storyId);
    if (currentStory == null) {
      if (kDebugMode)
        print("StoryService Error: Could not fetch story $storyId to unlike.");
      return false;
    }
    if (currentStory.likes <= 0) {
      if (kDebugMode)
        print(
            "StoryService Info: Story $storyId already has 0 likes. Cannot unlike further.");
      return true;
    }
    final Map<String, dynamic> patchData = {
      'Likes': max(0, currentStory.likes - 1)
    };
    final String url = '$_baseUrl/updateStory/$storyId';

    if (kDebugMode)
      print(
          "StoryService: PATCH $url (unlike story), Payload: ${jsonEncode(patchData)}");
    try {
      final response = await http.patch(Uri.parse(url),
          headers: await _getHeaders(), body: jsonEncode(patchData));
      if (kDebugMode)
        print(
            "StoryService: unlikeStory response ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Error unliking story $storyId: $e');
      return false;
    }
  }

  Future<bool> getLikeStatus(int storyId) async {
    final String url = '$_baseUrl/GetStories/$storyId';
    if (kDebugMode)
      print("StoryService: GET $url (for like status for story $storyId)");
    try {
      final response =
          await http.get(Uri.parse(url), headers: await _getHeaders());
      if (kDebugMode)
        print(
            "StoryService: getLikeStatus response ${response.statusCode}, Body (story $storyId): ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('CurrentUserHasLiked')) {
          return data['CurrentUserHasLiked'] as bool? ?? false;
        } else {
          if (kDebugMode)
            print(
                "StoryService Warning: 'CurrentUserHasLiked' field not found in story response for getLikeStatus. Defaulting to false. Story ID: $storyId. Response keys: ${data.keys.toList()}");
          return false;
        }
      }
      if (kDebugMode)
        print(
            "StoryService: Failed to get like status for story $storyId (Status: ${response.statusCode}), defaulting to false.");
      return false;
    } catch (e) {
      if (kDebugMode) print('Error getting like status for story $storyId: $e');
      return false;
    }
  }
}
