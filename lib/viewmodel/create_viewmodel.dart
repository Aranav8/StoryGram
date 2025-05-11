// viewmodel/create_viewmodel.dart
import 'dart:io';
// import 'dart:math'; // Not strictly needed for this timestamp approach unless adding randomness
import 'package:flutter/material.dart';
// FlutterSecureStorage or SharedPreferences not needed for this specific ID approach
import 'package:image_picker/image_picker.dart';
import 'package:collabwrite/data/models/story_model.dart';
import 'package:collabwrite/services/story_service.dart';
import 'package:collabwrite/services/auth_service.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class CreateViewModel extends ChangeNotifier {
  String _title = '';
  String _description = '';
  String _writingContent = '';
  String _selectedStoryType = 'Single Story';
  List<String> _selectedGenres = [];
  String? _coverImagePath;

  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  int? _editingStoryId;
  bool _isPickingImage = false;

  final StoryService _storyService = StoryService();
  final AuthService _authService = AuthService();
  // final _storage = const FlutterSecureStorage(); // Not needed for timestamp ID

  String get title => _title;
  String get description => _description;
  String get writingContent => _writingContent;
  String get selectedStoryType => _selectedStoryType;
  List<String> get selectedGenres => List.unmodifiable(_selectedGenres);
  String? get coverImagePath => _coverImagePath;
  bool get isSaving => _isSaving;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  final List<String> availableStoryTypes = const [
    'Single Story', 'Chapter-based', 'Collaborative'
  ];
  final List<String> popularGenres = const [
    'Fiction', 'Fantasy', 'Adventure', 'Romance', 'Sci-Fi', 'Mystery',
    'Thriller', 'Horror', 'Historical', 'Non-Fiction'
  ];

  void initialize({Story? draftStory}) {
    if (draftStory != null) {
      _editingStoryId = draftStory.id;
      _title = draftStory.title;
      _description = draftStory.description ?? '';
      if (draftStory.chapters.isNotEmpty) {
        _writingContent = draftStory.chapters.first.content;
      } else { _writingContent = ''; }
      _selectedStoryType = draftStory.storyType;
      _selectedGenres = List.from(draftStory.genres);
      _coverImagePath = draftStory.coverImage;
      _hasUnsavedChanges = false;
    } else {
      _editingStoryId = null;
      _title = ''; _description = ''; _writingContent = '';
      _selectedStoryType = availableStoryTypes.first;
      _selectedGenres = []; _coverImagePath = null;
      _hasUnsavedChanges = false;
    }
    if (kDebugMode) print("CreateViewModel: Initialized. Editing Story ID: $_editingStoryId");
    WidgetsBinding.instance.addPostFrameCallback((_) { notifyListeners(); });
  }

  // Temporary client-side ID generation - TIMESTAMP IN SECONDS (Still FLAWED FOR PRODUCTION)
  int _generateTimestampBasedTemporaryId() {
    // Timestamp in seconds since epoch.
    int newId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Check against max int4. This will become an issue closer to 2038.
    if (newId > 2147483647) {
      if (kDebugMode) print("WARNING: Timestamp-based ID exceeded int4 max! This is a critical issue.");
      // Fallback (very bad, will cause collisions or use negative numbers if not careful)
      // For now, let it be, but this indicates the method is no longer viable.
      // A more robust temporary fallback would be the random int within range.
      newId = 2147483647; // Cap at max, will cause immediate collision
    }
    if (newId <= 0) { // Should not happen with current time, but as a safeguard
      newId = 1; // Ensure positive
    }

    if (kDebugMode) print("CreateViewModel: Generated timestamp-based temporary story ID $newId");
    return newId;
  }

  void _setUnsavedChanges() {
    if (!_hasUnsavedChanges) { _hasUnsavedChanges = true; notifyListeners(); }
  }

  void setTitle(String value) { if (_title != value) { _title = value; _setUnsavedChanges(); } }
  void setDescription(String value) { if (_description != value) { _description = value; _setUnsavedChanges(); } }
  void setWritingContent(String value) { if (_writingContent != value) { _writingContent = value; _setUnsavedChanges(); } }
  void selectStoryType(String type) { if (_selectedStoryType != type && availableStoryTypes.contains(type)) { _selectedStoryType = type; _setUnsavedChanges(); notifyListeners(); } }
  void toggleGenre(String genre) { _selectedGenres.contains(genre) ? _selectedGenres.remove(genre) : _selectedGenres.add(genre); _setUnsavedChanges(); notifyListeners(); }

  Future<void> pickCoverImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) { _coverImagePath = image.path; _setUnsavedChanges(); notifyListeners(); }
    } catch (e) { if (kDebugMode) print("CreateViewModel: Error picking image: $e"); }
    finally { _isPickingImage = false; }
  }

  void removeCoverImage() { if (_coverImagePath != null) { _coverImagePath = null; _setUnsavedChanges(); notifyListeners(); } }

  Future<bool> saveDraft() async {
    if (title.trim().isEmpty) { if (kDebugMode) print("CreateViewModel: Title is required to save draft."); return false; }
    _isSaving = true; notifyListeners();

    final userId = await _authService.getCurrentUserId();
    if (userId == null) { _isSaving = false; notifyListeners(); if (kDebugMode) print("CreateViewModel: User not logged in for saveDraft."); return false; }

    int storyIdForRequest;
    if (_editingStoryId != null && _editingStoryId! > 0) {
      storyIdForRequest = _editingStoryId!;
    } else {
      storyIdForRequest = _generateTimestampBasedTemporaryId();
      _editingStoryId = storyIdForRequest; // Store generated ID for this draft session
    }

    final storyToSave = Story(
      id: storyIdForRequest, title: _title, description: _description, coverImage: '',
      authorId: userId, authorName: "Current User", lastEdited: DateTime.now(),
      storyType: _selectedStoryType, status: StoryStatus.draft, genres: _selectedGenres,
      chapters: _writingContent.trim().isNotEmpty ? [Chapter(id: 'temp_draft_ch', title: 'Chapter 1', content: _writingContent)] : [],
    );

    if (kDebugMode) print("CreateViewModel: Saving draft. Story ID: ${storyToSave.id}, User ID: $userId");
    final success = await _storyService.createStory(storyToSave);

    _isSaving = false;
    if (success) { _hasUnsavedChanges = false; if (kDebugMode) print("CreateViewModel: Draft saved successfully.");
    } else {
      if (kDebugMode) print("CreateViewModel: Failed to save draft.");
      _editingStoryId = null; // Clear potentially bad ID if save failed due to collision
    }
    notifyListeners(); return success;
  }

  Future<bool> publishStory() async {
    if (title.trim().isEmpty || writingContent.trim().isEmpty || selectedGenres.isEmpty) { if (kDebugMode) print("CreateViewModel: Title, content, and genres are required to publish."); return false; }
    _isSaving = true; notifyListeners();

    final userId = await _authService.getCurrentUserId();
    if (userId == null) { _isSaving = false; notifyListeners(); if (kDebugMode) print("CreateViewModel: User not logged in for publishStory."); return false; }

    int storyIdForRequest;
    if (_editingStoryId != null && _editingStoryId! > 0) {
      storyIdForRequest = _editingStoryId!;
    } else {
      storyIdForRequest = _generateTimestampBasedTemporaryId();
    }

    final storyToPublish = Story(
      id: storyIdForRequest, title: _title, description: _description, coverImage: '',
      authorId: userId, authorName: "Current User", lastEdited: DateTime.now(), publishedDate: DateTime.now(),
      storyType: _selectedStoryType, status: StoryStatus.published, genres: _selectedGenres,
      chapters: [Chapter(id: 'temp_pub_ch', title: 'Chapter 1', content: _writingContent, isComplete: true)],
    );

    if (kDebugMode) print("CreateViewModel: Publishing story. Story ID: ${storyToPublish.id}, User ID: $userId");
    final success = await _storyService.createStory(storyToPublish);

    _isSaving = false;
    if (success) {
      _hasUnsavedChanges = false;
      if (kDebugMode) print("CreateViewModel: Story published successfully.");
      _editingStoryId = null;
    } else {
      if (kDebugMode) print("CreateViewModel: Failed to publish story.");
      _editingStoryId = null; // Clear ID if publish failed, so next attempt generates fresh
    }
    notifyListeners(); return success;
  }

  Future<String?> getCurrentUserId() async { return await _authService.getCurrentUserId(); }
  @override
  void dispose() { if (kDebugMode) print("CreateViewModel: Disposed"); super.dispose(); }
}