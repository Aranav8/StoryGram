// viewmodel/edit_story_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:collabwrite/data/models/story_model.dart'; // Adjust import path as needed

class EditStoryViewModel extends ChangeNotifier {
  late Story _story;
  late Chapter _chapter;
  late int _chapterIndex;

  late TextEditingController chapterTitleController;
  late TextEditingController contentController;

  String get appBarTitle =>
      'Chapter ${_chapterIndex + 1}: ${chapterTitleController.text}';
  String get storyTitle => _story.title;
  String get chapterProgress =>
      'Chapter ${_chapterIndex + 1}/${_story.chapters?.length ?? 1}';

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _hasUnsavedChanges = false;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  bool _justSaved = false;
  bool get justSaved => _justSaved;

  Story get storyObjectForCollaboration => _story;

  // ADD THIS METHOD if you want to update the story in EditStoryViewModel after returning
  void refreshStoryAfterCollaboration(Story updatedStoryFromCollaboration) {
    _story = updatedStoryFromCollaboration;
    // Potentially re-initialize controllers if chapter details could have changed
    // For now, just notify to rebuild UI if any story-level details changed
    notifyListeners();
  }

  int get wordCount {
    return contentController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .length;
  }

  EditStoryViewModel({required Story story, required Chapter chapter}) {
    _story = story;
    _chapter = chapter; // Keep original reference to update

    // Find chapter index
    _chapterIndex =
        _story.chapters?.indexWhere((ch) => ch.id == _chapter.id) ?? 0;
    if (_chapterIndex == -1) _chapterIndex = 0; // Fallback

    chapterTitleController = TextEditingController(text: _chapter.title);
    contentController = TextEditingController(text: _chapter.content);

    chapterTitleController.addListener(_onTextChanged);
    contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      _hasUnsavedChanges = true;
      if (_justSaved) {
        _justSaved = false; // If user types after saving, hide "Saved" chip
      }
      notifyListeners();
    }
    // To update AppBar title dynamically if chapter title changes
    if (chapterTitleController.text != _chapter.title) {
      notifyListeners(); // For AppBar title refresh
    }
  }

  Future<bool> saveDraft() async {
    if (chapterTitleController.text.trim().isEmpty) {
      // Optionally show a message: "Chapter title cannot be empty"
      return false;
    }

    _isSaving = true;
    _justSaved = false;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Update the actual chapter object within the story's list
    final chapterInStory =
        _story.chapters?.firstWhere((ch) => ch.id == _chapter.id);
    if (chapterInStory != null) {
      chapterInStory.title = chapterTitleController.text;
      chapterInStory.content = contentController.text;
      // Optionally update chapter's isComplete status if relevant here
    }

    // Update story's last edited time
    _story = _story.copyWith(lastEdited: DateTime.now());
    // Note: If Story is not using copyWith for mutations, you might directly set:
    // _story.lastEdited = DateTime.now();

    print(
        'Draft saved for: ${_story.title} - Chapter: ${chapterInStory?.title}');

    _isSaving = false;
    _hasUnsavedChanges = false;
    _justSaved = true;
    notifyListeners();
    return true;
  }

  Future<bool> publishChapter() async {
    if (chapterTitleController.text.trim().isEmpty) return false;
    if (contentController.text.trim().isEmpty) return false;

    _isSaving = true;
    _justSaved = false;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final chapterInStory =
        _story.chapters?.firstWhere((ch) => ch.id == _chapter.id);
    if (chapterInStory != null) {
      chapterInStory.title = chapterTitleController.text;
      chapterInStory.content = contentController.text;
      chapterInStory.isComplete =
          true; // Example: Publishing marks chapter as complete
    }
    _story = _story.copyWith(
        lastEdited: DateTime.now(), status: StoryStatus.published);
    // Potentially update story status if all chapters are complete etc.

    print(
        'Chapter published: ${_story.title} - Chapter: ${chapterInStory?.title}');

    _isSaving = false;
    _hasUnsavedChanges = false;
    _justSaved = true; // Or navigate away, so 'Saved' chip might not be needed
    notifyListeners();
    return true;
  }

  // Placeholder for text formatting actions
  void toggleBold() {
    /* TODO: Implement Rich Text Editing Logic */ notifyListeners();
  }

  void toggleItalic() {
    /* TODO: Implement Rich Text Editing Logic */ notifyListeners();
  }

  void toggleUnderline() {
    /* TODO: Implement Rich Text Editing Logic */ notifyListeners();
  }

  void toggleBulletList() {
    /* TODO: Implement Rich Text Editing Logic */ notifyListeners();
  }

  void startDictation() {
    /* TODO: Implement Dictation Logic */ notifyListeners();
  }

  @override
  void dispose() {
    chapterTitleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
