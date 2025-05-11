// viewmodel/story_reader_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:collabwrite/data/models/story_model.dart';
import 'package:collabwrite/data/models/user_model.dart' as app_user;
import 'package:collabwrite/services/story_service.dart';
import 'package:collabwrite/services/auth_service.dart'; // Currently unused, but potentially needed by StoryService implicitly or explicitly
import 'package:flutter/foundation.dart';
import 'dart:math'; // For max()

class StoryReaderViewModel extends ChangeNotifier {
  final Story story;
  app_user.User? _author;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLiked = false; // This tracks if the CURRENT USER has liked the story.
  int _likesCount; // This tracks the TOTAL number of likes for the story.
  int _viewsCount;
  bool _isFollowingAuthor = false;

  final StoryService _storyService = StoryService();
  final AuthService _authService =
      AuthService(); // Potentially used by StoryService or could be passed if methods require it.

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

  String get storyContent {
    // Assuming story.chapters is nullable (e.g., List<ChapterModel>?)
    if (story.storyType.toLowerCase().contains("chapter") &&
        story.chapters != null &&
        story.chapters!.isNotEmpty) {
      // Corrected: Added '!' for isNotEmpty if chapters is nullable after check
      return story
          .chapters! // Corrected: Added '!' for map if chapters is nullable after check
          .map((c) => "## ${c.title}\n\n${c.content}\n\n---\n\n")
          .join();
    }
    // If story.chapters is non-nullable (e.g. List<ChapterModel> chapters = const []),
    // then the 'story.chapters != null' check is redundant and '!' are not needed.
    // The provided code 'story.chapters != null && story.chapters.isNotEmpty' implies it's nullable.
    return story.description ?? "No content available for this story.";
  }

  Future<void> _initialize() async {
    if (kDebugMode) {
      print("StoryReaderViewModel: Initializing for story ID ${story.id}");
    }
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners(); // Called in finally block

    try {
      // 1. Increment view count
      bool viewIncremented = await _storyService.incrementViewCount(story.id);
      if (viewIncremented) {
        // Optimistic local increment. Will be overwritten by freshStory.views later for accuracy.
        // _viewsCount++; // This could be done, but fetching fresh story details is more robust.
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: View count increment attempted for story ${story.id}.");
        }
      } else {
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: Failed to increment view count on backend for story ${story.id}.");
        }
      }

      // 2. Fetch author details
      int? authorIdInt = int.tryParse(story.authorId);
      if (authorIdInt == null && kDebugMode) {
        print(
            "StoryReaderViewModel: Invalid authorId format: ${story.authorId}. Using 0 as fallback for User object.");
      }
      _author = app_user.User(
          id: authorIdInt ?? 0,
          name: story.authorName,
          bio: "A passionate storyteller.", // Placeholder - ideally fetched
          profileImage: null, // Placeholder - ideally fetched
          location: "Unknown",
          followers: 0,
          following: 0,
          stories: 0 // Placeholders
          );

      // 3. Fetch user's actual like status for this story
      // CRITICAL: For like persistence, _storyService.getLikeStatus must correctly
      //           return the persisted like status of the current user for this story.
      //           If this method returns 'false' even after a successful like,
      //           the like will not appear persisted when re-opening the story.
      _isLiked = await _storyService.getLikeStatus(story.id);
      if (kDebugMode) {
        print(
            "StoryReaderViewModel: Initial like status for story ${story.id} from service: $_isLiked");
      }

      // 4. Fetch the full story details to update local counts accurately
      // This ensures likesCount and viewsCount are fresh from the server after any view increments.
      final Story? freshStory = await _storyService.getStoryById(story.id);
      if (freshStory != null) {
        _likesCount = freshStory.likes; // Total likes from all users
        _viewsCount = freshStory.views; // Total views, reflecting any increment
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: Fetched fresh story details. Likes: $_likesCount, Views: $_viewsCount");
        }
      } else {
        if (kDebugMode)
          print(
              "StoryReaderViewModel: Could not fetch fresh story details for story ${story.id}. Counts might be stale.");
      }

      // _isFollowingAuthor = await _userService.getFollowStatus(author.id); // Placeholder for actual service call
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("StoryReaderViewModel: Error during initialization: $e");
        print("StoryReaderViewModel: StackTrace: $stackTrace");
      }
      _errorMessage = "Could not load story details: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike() async {
    if (kDebugMode) {
      print(
          "StoryReaderViewModel: toggleLike called. Current _isLiked: $_isLiked, current _likesCount: $_likesCount");
    }
    bool success = false;
    final originalIsLiked = _isLiked;
    final originalLikesCount = _likesCount;

    // Optimistic UI update
    if (_isLiked) {
      // If currently liked, the action is to unlike
      _likesCount = max(0, _likesCount - 1); // Decrease total likes
      _isLiked = false; // Set user's status to not liked
    } else {
      // If currently not liked, the action is to like
      _likesCount++; // Increase total likes
      _isLiked = true; // Set user's status to liked
    }
    notifyListeners();

    try {
      // CRITICAL: For like persistence, these service methods must correctly
      //           update the like status on the backend.
      if (!originalIsLiked) {
        // Action was to like (originalIsLiked was false, so optimistically set _isLiked to true)
        success = await _storyService.likeStory(story.id);
      } else {
        // Action was to unlike (originalIsLiked was true, so optimistically set _isLiked to false)
        success = await _storyService.unlikeStory(story.id);
      }

      if (!success) {
        // API call failed, revert optimistic update
        _isLiked = originalIsLiked;
        _likesCount = originalLikesCount;
        _errorMessage =
            "Could not ${originalIsLiked ? 'unlike' : 'like'} story. Please try again.";
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: Failed to update like status on backend. Reverting. Success flag: $success");
        }
      } else {
        _errorMessage = null; // Clear error on success
        if (kDebugMode) {
          print(
              "StoryReaderViewModel: Like status updated successfully on backend. Optimistic local _likesCount: $_likesCount, _isLiked: $_isLiked");
        }
        // Optionally, fetch freshStory again here to get server-confirmed like count,
        // though HomeScreen refresh also handles this. For _isLiked, we trust our successful call.
      }
    } catch (e) {
      // Exception occurred, revert optimistic update
      _isLiked = originalIsLiked;
      _likesCount = originalLikesCount;
      _errorMessage =
          "Error ${originalIsLiked ? 'unliking' : 'liking'} story: ${e.toString()}";
      if (kDebugMode) {
        print(
            "StoryReaderViewModel: Exception during toggleLike: $e. Reverting.");
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggleFollowAuthor() async {
    if (_author == null) return;
    _isFollowingAuthor = !_isFollowingAuthor;
    // TODO: Call actual follow/unfollow service method from a UserService, e.g.:
    // try {
    //   if (_isFollowingAuthor) {
    //     await _userService.followUser(_author!.id);
    //   } else {
    //     await _userService.unfollowUser(_author!.id);
    //   }
    // } catch (e) {
    //   _isFollowingAuthor = !_isFollowingAuthor; // Revert on error
    //   // Handle error message
    // }
    if (kDebugMode) {
      print(
          "StoryReaderViewModel: Toggled follow for author ${_author!.name}. New status: $_isFollowingAuthor (Simulated)");
    }
    notifyListeners();
  }
}
