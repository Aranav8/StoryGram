import 'package:flutter/material.dart';
import 'package:collabwrite/data/models/story_model.dart';

enum StorySortOption { lastEditedDesc, lastEditedAsc, titleAsc, titleDesc }

class LibraryViewModel extends ChangeNotifier {
  List<Story> _allStories = [];
  List<Story> _filteredStories = [];
  bool _isLoading = true;
  bool _isSearchActive = false;
  String _searchQuery = '';

  Set<StoryStatus> _selectedStatuses = {};
  Set<String> _selectedTypes = {};
  StorySortOption _sortOption = StorySortOption.lastEditedDesc;

  List<Story> get filteredStories => List.unmodifiable(_filteredStories);
  bool get isLoading => _isLoading;
  bool get isSearchActive => _isSearchActive;
  String get searchQuery => _searchQuery;
  Set<StoryStatus> get selectedStatuses => Set.unmodifiable(_selectedStatuses);
  Set<String> get selectedTypes => Set.unmodifiable(_selectedTypes);
  StorySortOption get sortOption => _sortOption;

  LibraryViewModel() {
    loadStories();
  }

  Future<void> loadStories() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));
    _allStories = Story.generateDummyStories(8);

    _applyFiltersAndSort();

    _isLoading = false;
    notifyListeners();
  }

  void toggleSearch() {
    _isSearchActive = !_isSearchActive;
    if (!_isSearchActive) {
      _searchQuery = '';
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFiltersAndSort();
    }
  }

  void applyFilters({
    required Set<StoryStatus> statuses,
    required Set<String> types,
    required StorySortOption sort,
  }) {
    _selectedStatuses = statuses;
    _selectedTypes = types;
    _sortOption = sort;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    List<Story> filtered = List.from(_allStories);

    if (_isSearchActive && _searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((story) => story.title.toLowerCase().contains(query))
          .toList();
    }

    if (_selectedStatuses.isNotEmpty) {
      filtered = filtered
          .where((story) => _selectedStatuses.contains(story.status))
          .toList();
    }

    if (_selectedTypes.isNotEmpty) {
      filtered = filtered
          .where((story) => _selectedTypes.contains(story.storyType))
          .toList();
    }

    switch (_sortOption) {
      case StorySortOption.lastEditedDesc:
        filtered.sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
        break;
      case StorySortOption.lastEditedAsc:
        filtered.sort((a, b) => a.lastEdited.compareTo(b.lastEdited));
        break;
      case StorySortOption.titleAsc:
        filtered.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case StorySortOption.titleDesc:
        filtered.sort(
            (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    _filteredStories = filtered;
  }

  Future<bool> deleteStory(int storyId) async {
    print("Deleting story: $storyId");
    await Future.delayed(const Duration(milliseconds: 500));

    _allStories.removeWhere((story) => story.id == storyId);
    _applyFiltersAndSort();
    notifyListeners();
    return true;
  }

  Future<bool> updateStoryStatus(int storyId, StoryStatus newStatus) async {
    print("Updating status for $storyId to $newStatus");
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _allStories.indexWhere((s) => s.id == storyId);
    if (index != -1) {
      _allStories[index].status = newStatus;
      _allStories[index] =
          _allStories[index].copyWith(lastEdited: DateTime.now());
      _applyFiltersAndSort();
      notifyListeners();
      return true;
    }
    return false;
  }
}
