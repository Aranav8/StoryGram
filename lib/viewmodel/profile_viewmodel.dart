import 'package:flutter/material.dart';
import '../data/models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  User? _user;
  List<Story> _userStories = [];
  List<Story> _collaborationStories = [];
  List<Story> _savedStories = [];
  bool _isLoading = true;

  User? get user => _user;
  List<Story> get userStories => _userStories;
  List<Story> get collaborationStories => _collaborationStories;
  List<Story> get savedStories => _savedStories;
  bool get isLoading => _isLoading;

  ProfileViewModel() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _user = User(
      id: 1,
      name: 'Aranav Kumar',
      bio: 'Passionate storyteller with a lot of fantasy.',
      profileImage: null,
      location: 'BML Munjal Univeristy, Gurgaon',
      // website: 'aranav.com',
      followers: 1200,
      following: 345,
      stories: 8,
      isVerified: true,
    );

    _userStories = List.generate(
      4,
      (index) => Story(
        id: index,
        title: 'The Chronicles of Mysteria: Part ${index + 1}',
        description:
            'An epic fantasy adventure in a world of magic and mystery.',
        likes: 1200 + (index * 100),
        views: 2500 + (index * 200),
        publishedDate: DateTime.now().subtract(Duration(days: index * 5)),
        userId: 11,
        lastEdited: DateTime.now(),
        storyType: '',
        status: '',
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  void toggleSaveStory(Story story) {
    final isSaved = _savedStories.any((s) => s.id == story.id);

    if (isSaved) {
      _savedStories.removeWhere((s) => s.id == story.id);
    } else {
      _savedStories.add(story);
    }

    notifyListeners();
  }
}
