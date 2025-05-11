import 'package:collabwrite/data/models/author_model.dart';
import 'package:flutter/material.dart';
import 'package:collabwrite/data/models/user_model.dart'
    as ui_user_model; // Alias for UI User model
import 'package:collabwrite/data/models/story_model.dart'
    as data_story_model; // Alias for data Story model
import 'package:collabwrite/services/auth_service.dart';
import 'package:collabwrite/services/user_service.dart';
import 'package:collabwrite/services/story_service.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final StoryService _storyService = StoryService();

  ui_user_model.User? _user;
  List<data_story_model.Story> _userStories = [];
  List<data_story_model.Story> _collaborationStories =
      []; // Placeholder for now
  List<data_story_model.Story> _savedStories = []; // Placeholder for now
  bool _isLoading = true;
  String? _errorMessage;

  ui_user_model.User? get user => _user;
  List<data_story_model.Story> get userStories => _userStories;
  List<data_story_model.Story> get collaborationStories =>
      _collaborationStories;
  List<data_story_model.Story> get savedStories => _savedStories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProfileViewModel() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? currentUserId = await _authService.getCurrentUserId();

      if (currentUserId == null || currentUserId.isEmpty) {
        _errorMessage = "User not logged in. Please login again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch user details
      // Assuming authorId from authService is an int, but userService expects String.
      // And Author model uses int ID. UserService.getAuthorById uses String.
      // Let's assume currentUserId from authService is the string representation of the numeric ID.
      final Author fetchedAuthor =
          await _userService.getAuthorById(currentUserId);
      _user = ui_user_model.User(
        id: fetchedAuthor.id,
        name: fetchedAuthor.name,
        bio: fetchedAuthor.bio,
        profileImage: fetchedAuthor.profileImage,
        location: fetchedAuthor.location ?? 'N/A',
        website: fetchedAuthor.website,
        followers: fetchedAuthor.followers,
        following: fetchedAuthor.following,
        stories: fetchedAuthor.storiesCount,
        isVerified: fetchedAuthor.isVerified,
      );

      // Fetch user's own stories
      _userStories = await _storyService.getStoriesByAuthor(currentUserId);

      // TODO: Implement fetching actual collaboration stories
      // For now, using dummy data or empty list.
      // _collaborationStories = ...
      // Example: if Story model had a simple authorId and we fetched all stories
      // final allStories = await _storyService.getAllStories();
      // _collaborationStories = allStories.where((story) =>
      //    story.authorId != currentUserId &&
      //    story.collaborators.any((c) => c.userId == currentUserId)
      // ).toList();
      // This is a placeholder for actual implementation
      _collaborationStories = _generateDummyCollaborationStories(currentUserId);

      // TODO: Implement fetching/loading saved stories
      // For now, using dummy data or empty list if `toggleSaveStory` is purely local
      // _savedStories = ...
      _savedStories = _generateDummySavedStories();
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing profile data: $e");
      }
      _errorMessage = "Failed to load profile data: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Placeholder for dummy collaboration stories if needed
  List<data_story_model.Story> _generateDummyCollaborationStories(
      String currentUserId) {
    // Replace with actual data fetching or keep empty
    return [];
    // Example:
    // return data_story_model.Story.generateDummyStories(2).where((story) {
    //   // Ensure this dummy story is not authored by current user but has them as collaborator
    //   bool isCollaborator = story.collaborators.any((c) => c.userId == currentUserId && c.role != data_story_model.CollaboratorRole.owner);
    //   return story.authorId != currentUserId && isCollaborator;
    // }).toList();
  }

  // Placeholder for dummy saved stories
  List<data_story_model.Story> _generateDummySavedStories() {
    // Replace with actual data fetching or logic for locally saved stories
    return [];
    // Example:
    // return data_story_model.Story.generateDummyStories(3);
  }

  void toggleSaveStory(data_story_model.Story story) {
    final isSaved = _savedStories.any((s) => s.id == story.id);

    if (isSaved) {
      _savedStories.removeWhere((s) => s.id == story.id);
    } else {
      _savedStories.add(story);
    }
    // TODO: If saved stories are backend-driven, call an API here.
    notifyListeners();
  }
}
