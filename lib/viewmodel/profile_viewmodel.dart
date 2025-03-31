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
      id: '1',
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
        id: 'story_$index',
        title: 'The Chronicles of Mysteria: Part ${index + 1}',
        description:
            'An epic fantasy adventure in a world of magic and mystery.',
        image: 'assets/images/example.png',
        author: _user!.name,
        likes: 1200 + (index * 100),
        views: 2500 + (index * 200),
        publishedDate: DateTime.now().subtract(Duration(days: index * 5)),
      ),
    );

    _collaborationStories = List.generate(
      3,
      (index) => Story(
        id: 'collab_$index',
        title: 'Cosmic Voyagers: The Lost Planet',
        description: 'A sci-fi collaboration about space explorers.',
        image: 'assets/images/example.png',
        author: 'Multiple Authors',
        likes: 850 + (index * 75),
        views: 1900 + (index * 150),
        publishedDate:
            DateTime.now().subtract(Duration(days: 10 + (index * 8))),
        collaborators: List.generate(
          4,
          (i) => User(
            id: 'user_$i',
            name: 'Collaborator $i',
            bio: 'Writer',
            profileImage:
                'https://randomuser.me/api/portraits/men/${i + 10}.jpg',
            location: 'Location',
            website: 'website.com',
            followers: 100,
            following: 100,
            stories: 5,
          ),
        ),
      ),
    );

    _savedStories = List.generate(
      6,
      (index) => Story(
        id: 'saved_$index',
        title: 'Midnight Tales: The Haunting ${index + 1}',
        description:
            'A collection of horror stories that will keep you up at night.',
        image: 'assets/images/example.png',
        author: 'Various Authors',
        likes: 600 + (index * 50),
        views: 1500 + (index * 100),
        publishedDate: DateTime.now().subtract(Duration(days: 3 + (index * 2))),
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
