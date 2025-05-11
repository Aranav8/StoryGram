// viewmodel/create_viewmodel.dart
import 'dart:io';
import 'package:flutter/material.dart';
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
  bool _isPickingImage = false; // Prevent multiple picker calls

  final StoryService _storyService = StoryService();
  final AuthService _authService = AuthService();

  String get title => _title;
  String get description => _description;
  String get writingContent => _writingContent;
  String get selectedStoryType => _selectedStoryType;
  List<String> get selectedGenres => List.unmodifiable(_selectedGenres);
  String? get coverImagePath => _coverImagePath;
  bool get isSaving => _isSaving;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  final List<String> availableStoryTypes = const [
    'Single Story',
    'Chapter-based',
    'Collaborative'
  ];
  final List<String> popularGenres = const [
    'Fiction',
    'Fantasy',
    'Adventure',
    'Romance',
    'Sci-Fi',
    'Mystery',
    'Thriller',
    'Horror',
    'Historical',
    'Non-Fiction'
  ];

  void initialize({Story? draftStory}) {
    if (draftStory != null) {
      _editingStoryId = draftStory.id;
      _title = draftStory.title;
      _description = draftStory.description ?? '';
      _writingContent = '';
      _selectedStoryType = draftStory.storyType;
      _selectedGenres = List.from(draftStory.genres ?? []);
      _coverImagePath = draftStory.coverImage;
      _hasUnsavedChanges = false;
    } else {
      _editingStoryId = null;
      _title = '';
      _description = '';
      _writingContent = '';
      _selectedStoryType = availableStoryTypes.first;
      _selectedGenres = [];
      _coverImagePath = null;
      _hasUnsavedChanges = false;
    }
    if (kDebugMode) {
      print(
          "CreateViewModel: Initialized with draftStory: ${draftStory?.title ?? 'none'}");
      print(
          "CreateViewModel: title = $_title, description = $_description, writingContent = $_writingContent");
    }
    // Defer notifyListeners to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setUnsavedChanges() {
    if (!_hasUnsavedChanges) {
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

  void setTitle(String value) {
    if (_title != value) {
      _title = value;
      _setUnsavedChanges();
      if (kDebugMode) {
        print("CreateViewModel: setTitle called with value: $value");
      }
    }
  }

  void setDescription(String value) {
    if (_description != value) {
      _description = value;
      _setUnsavedChanges();
      if (kDebugMode) {
        print("CreateViewModel: setDescription called with value: $value");
      }
    }
  }

  void setWritingContent(String value) {
    if (_writingContent != value) {
      _writingContent = value;
      _setUnsavedChanges();
      if (kDebugMode) {
        print("CreateViewModel: setWritingContent called with value: $value");
      }
    }
  }

  void selectStoryType(String type) {
    if (_selectedStoryType != type && availableStoryTypes.contains(type)) {
      _selectedStoryType = type;
      _setUnsavedChanges();
      notifyListeners();
    }
  }

  void toggleGenre(String genre) {
    if (_selectedGenres.contains(genre)) {
      _selectedGenres.remove(genre);
    } else {
      _selectedGenres.add(genre);
    }
    _setUnsavedChanges();
    notifyListeners();
  }

  Future<void> pickCoverImage() async {
    if (_isPickingImage) return; // Prevent multiple calls
    _isPickingImage = true;
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _coverImagePath = image.path; // Store local path for preview
        _setUnsavedChanges();
        if (kDebugMode) {
          print("CreateViewModel: Picked image: ${_coverImagePath}");
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("CreateViewModel: Error picking image: $e");
      }
    } finally {
      _isPickingImage = false;
    }
  }

  void removeCoverImage() {
    if (_coverImagePath != null) {
      _coverImagePath = null;
      _setUnsavedChanges();
      if (kDebugMode) {
        print("CreateViewModel: Removed cover image");
      }
      notifyListeners();
    }
  }

  Future<bool> saveDraft() async {
    if (title.trim().isEmpty) {
      if (kDebugMode) {
        print(
            "CreateViewModel: Validation Error: Title is required to save draft.");
      }
      return false;
    }

    _isSaving = true;
    notifyListeners();

    final userId = await _authService.getCurrentUserId();
    if (userId == null) {
      _isSaving = false;
      notifyListeners();
      if (kDebugMode) {
        print("CreateViewModel: Error: User not logged in.");
      }
      return false; // UI will handle this error
    }

    final storyToSave = Story(
      id: _editingStoryId ?? DateTime.now().millisecondsSinceEpoch.toInt(),
      title: _title,
      description: _description,
      coverImage: '', // Send empty string since we can't upload images
      authorId: userId,
      authorName: "Current User", // Ideally fetch from user profile
      lastEdited: DateTime.now(),
      storyType: _selectedStoryType,
      status: StoryStatus.draft,
      genres: _selectedGenres,
      chapters: _writingContent.trim().isNotEmpty
          ? [
              Chapter(
                id: 'chapter_${DateTime.now().millisecondsSinceEpoch}',
                title: 'Chapter 1',
                content: _writingContent,
                isComplete: false,
              )
            ]
          : [],
    );

    if (kDebugMode) {
      print(
          "CreateViewModel: Saving draft with ID: ${storyToSave.id}, Title: ${storyToSave.title}, User ID: $userId");
    }

    final success = await _storyService.createStory(storyToSave);

    _isSaving = false;
    if (success) {
      _hasUnsavedChanges = false;
      _editingStoryId = storyToSave.id; // Update ID for future saves
      if (kDebugMode) {
        print("CreateViewModel: Draft saved successfully");
      }
    } else {
      if (kDebugMode) {
        print("CreateViewModel: Failed to save draft");
      }
    }
    notifyListeners();
    return success;
  }

  Future<bool> publishStory() async {
    if (title.trim().isEmpty) {
      if (kDebugMode) {
        print("CreateViewModel: Validation Error: Title is required.");
      }
      return false;
    }
    if (writingContent.trim().isEmpty) {
      if (kDebugMode) {
        print("CreateViewModel: Validation Error: Content is required.");
      }
      return false;
    }
    if (selectedGenres.isEmpty) {
      if (kDebugMode) {
        print(
            "CreateViewModel: Validation Error: At least one genre is required.");
      }
      return false;
    }

    _isSaving = true;
    notifyListeners();

    final userId = await _authService.getCurrentUserId();
    if (userId == null) {
      _isSaving = false;
      notifyListeners();
      if (kDebugMode) {
        print("CreateViewModel: Error: User not logged in.");
      }
      return false; // UI will handle this error
    }

    final storyToPublish = Story(
      id: _editingStoryId ?? DateTime.now().millisecondsSinceEpoch.toInt(),
      title: _title,
      description: _description,
      coverImage: '', // Send empty string since we can't upload images
      authorId: userId,
      authorName: "Current User", // Ideally fetch from user profile
      lastEdited: DateTime.now(),
      publishedDate: DateTime.now(),
      storyType: _selectedStoryType,
      status: StoryStatus.published,
      genres: _selectedGenres,
      chapters: [
        Chapter(
          id: 'chapter_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Chapter 1',
          content: _writingContent,
          isComplete: true,
        )
      ],
    );

    if (kDebugMode) {
      print(
          "CreateViewModel: Publishing story with ID: ${storyToPublish.id}, Title: ${storyToPublish.title}, User ID: $userId");
    }

    final success = await _storyService.createStory(storyToPublish);

    _isSaving = false;
    if (success) {
      _hasUnsavedChanges = false;
      _editingStoryId = storyToPublish.id;
      if (kDebugMode) {
        print("CreateViewModel: Story published successfully");
      }
    } else {
      if (kDebugMode) {
        print("CreateViewModel: Failed to publish story");
      }
    }
    notifyListeners();
    return success;
  }

  Future<String?> getCurrentUserId() async {
    return await _authService.getCurrentUserId();
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print("CreateViewModel: Disposed");
    }
    super.dispose();
  }
}
