import 'package:flutter/material.dart';
import '../../data/models/story_model.dart';

class HomeViewModel extends ChangeNotifier {
  List<String> filters = ["+", "Trending", "Genres", "Collaboration"];
  int selectedFilter = 1;

  List<Story> stories = Story.generateDummyStories(10);

  HomeViewModel() {}

  void selectFilter(int index) {
    if (selectedFilter != index) {
      selectedFilter = index;
      print("Filter selected: ${filters[index]}");
      notifyListeners();
    }
  }
}
