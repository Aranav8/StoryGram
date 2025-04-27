import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collabwrite/data/models/story_model.dart';

class CreateViewModel extends ChangeNotifier {
  String _title = '';
  String _description = '';
  String _writingContent = '';
  String _selectedStoryType = 'Single Story';
  List<String> _selectedGenres = [];
  String? _coverImagePath;

  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String? _editingStoryId;

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
    }
  }

  void setDescription(String value) {
    if (_description != value) {
      _description = value;
      _setUnsavedChanges();
    }
  }

  void setWritingContent(String value) {
    if (_writingContent != value) {
      _writingContent = value;
      _setUnsavedChanges();
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
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _coverImagePath = image.path;
        _setUnsavedChanges();
        notifyListeners();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void removeCoverImage() {
    if (_coverImagePath != null) {
      _coverImagePath = null;
      _setUnsavedChanges();
      notifyListeners();
    }
  }

  Future<bool> saveDraft() async {
    if (title.trim().isEmpty) {
      print("Validation Error: Title is required to save draft.");
      return false;
    }

    _isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    String currentUserId = "user_123";
    String currentUserName = "Current User";

    final storyToSave = Story(
      id: _editingStoryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title,
      description: _description,
      coverImage: _coverImagePath,
      authorId: currentUserId,
      authorName: currentUserName,
      lastEdited: DateTime.now(),
      storyType: _selectedStoryType,
      status: StoryStatus.draft,
      genres: _selectedGenres,
    );

    print("Saving draft: ${storyToSave.title}");

    _isSaving = false;
    _hasUnsavedChanges = false;
    notifyListeners();
    return true;
  }

  Future<bool> publishStory() async {
    if (title.trim().isEmpty) {
      print("Validation Error: Title is required.");
      return false;
    }
    if (writingContent.trim().isEmpty) {
      print("Validation Error: Content is required.");
      return false;
    }
    if (selectedGenres.isEmpty) {
      print("Validation Error: At least one genre is required.");
      return false;
    }

    _isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    String currentUserId = "user_123";
    String currentUserName = "Current User";

    final storyToPublish = Story(
      id: _editingStoryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title,
      description: _description,
      coverImage: _coverImagePath,
      authorId: currentUserId,
      authorName: currentUserName,
      lastEdited: DateTime.now(),
      publishedDate: DateTime.now(),
      storyType: _selectedStoryType,
      status: StoryStatus.published,
      genres: _selectedGenres,
    );

    print("Publishing story: ${storyToPublish.title}");

    _isSaving = false;
    _hasUnsavedChanges = false;
    notifyListeners();
    return true;
  }
}
