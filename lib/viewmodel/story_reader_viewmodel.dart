import 'package:flutter/material.dart';
import 'package:collabwrite/data/models/story_model.dart';
import 'package:collabwrite/data/models/user_model.dart' as app_user;
import 'package:collabwrite/services/story_service.dart';
import 'package:collabwrite/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StoryReaderViewModel extends ChangeNotifier {
  final Story story;
  app_user.User? _author;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLiked = false;
  int _likesCount;
  int _viewsCount;
  bool _isFollowingAuthor = false;
  bool _isSaved = false; // New: Tracks if the story is saved by the user

  final StoryService _storyService = StoryService();
  final AuthService _authService = AuthService();

  StoryReaderViewModel({required this.story})
      : _likesCount = story.likes,
        _viewsCount = story.views {
    _initialize();
  }

  app_user.User? get author => _author;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLiked => _isLiked;
  int get likesCount => _likesCount;
  int get viewsCount => _viewsCount;
  bool get isFollowingAuthor => _isFollowingAuthor;
  bool get isSaved => _isSaved; // New getter

  String get storyContent {
    if (story.storyType.toLowerCase().contains("chapter") &&
        story.chapters != null &&
        story.chapters!.isNotEmpty) {
      return story.chapters!
          .map((c) => "## ${c.title}\n\n${c.content}\n\n---\n\n")
          .join();
    }
    return story.description ?? "No content available for this story.";
  }

  Future<void> _initialize() async {
    if (kDebugMode) {
      print("StoryReaderViewModel: Initializing for story ID ${story.id}");
    }
    _isLoading = true;
    _errorMessage = null;

    try {
      // 1. Check if story is saved
      _isSaved = await _checkIfSaved(story.id);
      if (kDebugMode) {
        print(
            "StoryReaderViewModel: Initial save status for story ${story.id}: $_isSaved");
      }

      // 2. Increment view count
      bool viewIncremented = await _storyService.incrementViewCount(story.id);
      if (viewIncremented) {
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: View count incremented for story ${story.id}.");
        }
      } else {
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: Failed to increment view count for story ${story.id}.");
        }
      }

      // 3. Fetch author details
      int? authorIdInt = int.tryParse(story.authorId);
      if (authorIdInt == null && kDebugMode) {
        print(
            "StoryReaderViewModel: Invalid authorId format: ${story.authorId}.");
      }
      _author = app_user.User(
        id: authorIdInt ?? 0,
        name: story.authorName,
        bio: "A passionate storyteller.",
        profileImage: null,
        location: "Unknown",
        followers: 0,
        following: 0,
        stories: 0,
      );

      // 4. Fetch user's like status
      _isLiked = await _storyService.getLikeStatus(story.id);
      if (kDebugMode) {
        print(
            "StoryReaderViewModel: Initial like status for story ${story.id}: $_isLiked");
      }

      // 5. Fetch fresh story details
      final Story? freshStory = await _storyService.getStoryById(story.id);
      if (freshStory != null) {
        _likesCount = freshStory.likes;
        _viewsCount = freshStory.views;
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: Fetched fresh story. Likes: $_likesCount, Views: $_viewsCount");
        }
      } else {
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: Could not fetch fresh story details for ${story.id}.");
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("StoryReaderViewModel: Error during initialization: $e");
        print("StackTrace: $stackTrace");
      }
      _errorMessage = "Could not load story details: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _checkIfSaved(int storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedStoriesJson = prefs.getString('saved_stories');
    if (savedStoriesJson == null) return false;
    final List<dynamic> savedStoryIds = jsonDecode(savedStoriesJson);
    return savedStoryIds.contains(storyId);
  }

  Future<void> toggleSaveStory() async {
    if (kDebugMode) {
      print(
          "StoryReaderViewModel: toggleSaveStory called. Current _isSaved: $_isSaved");
    }
    final originalIsSaved = _isSaved;
    _isSaved = !_isSaved;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      List<int> savedStoryIds = [];
      final savedStoriesJson = prefs.getString('saved_stories');
      if (savedStoriesJson != null) {
        savedStoryIds =
            (jsonDecode(savedStoriesJson) as List<dynamic>).cast<int>();
      }

      if (_isSaved) {
        if (!savedStoryIds.contains(story.id)) {
          savedStoryIds.add(story.id);
        }
      } else {
        savedStoryIds.remove(story.id);
      }

      await prefs.setString('saved_stories', jsonEncode(savedStoryIds));
      if (kDebugMode) {
        print("StoryReaderViewModel: Saved stories updated: $savedStoryIds");
      }
    } catch (e) {
      _isSaved = originalIsSaved;
      _errorMessage = "Error saving story: ${e.toString()}";
      if (kDebugMode) {
        print("StoryReaderViewModel: Error in toggleSaveStory: $e");
      }
      notifyListeners();
    }
  }

  Future<void> toggleLike() async {
    if (kDebugMode) {
      print(
          "StoryReaderViewModel: toggleLike called. Current _isLiked: $_isLiked");
    }
    bool success = false;
    final originalIsLiked = _isLiked;
    final originalLikesCount = _likesCount;

    if (_isLiked) {
      _likesCount = max(0, _likesCount - 1);
      _isLiked = false;
    } else {
      _likesCount++;
      _isLiked = true;
    }
    notifyListeners();

    try {
      if (!originalIsLiked) {
        success = await _storyService.likeStory(story.id);
      } else {
        success = await _storyService.unlikeStory(story.id);
      }

      if (!success) {
        _isLiked = originalIsLiked;
        _likesCount = originalLikesCount;
        _errorMessage =
            "Could not ${originalIsLiked ? 'unlike' : 'like'} story.";
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: Failed to update like status. Success: $success");
        }
      } else {
        _errorMessage = null;
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: Like status updated. Likes: $_likesCount, Liked: $_isLiked");
        }
      }
    } catch (e) {
      _isLiked = originalIsLiked;
      _likesCount = originalLikesCount;
      _errorMessage =
          "Error ${originalIsLiked ? 'unliking' : 'liking'} story: ${e.toString()}";
      if (kDebugMode) {
        print("StoryReaderViewModel: Exception in toggleLike: $e");
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggleFollowAuthor() async {
    if (_author == null) return;
    _isFollowingAuthor = !_isFollowingAuthor;
    if (kDebugMode) {
      print(
          "StoryReaderViewModel: Toggled follow for author ${_author!.name}: $_isFollowingAuthor");
    }
    notifyListeners();
  }
}
