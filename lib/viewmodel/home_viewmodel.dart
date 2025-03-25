import 'package:flutter/material.dart';
import '../../data/models/story_model.dart';

class HomeViewModel extends ChangeNotifier {
  List<String> filters = ["+", "Trending", "Genres", "Collaboration"];
  int selectedFilter = 1;
  List<Story> stories = Story.dummyStories;

  void selectFilter(int index) {
    selectedFilter = index;
    notifyListeners();
  }
}
