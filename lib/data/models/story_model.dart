import 'package:collabwrite/data/models/user_model.dart';

enum StoryStatus {
  draft,
  published,
  archived,
}

class Chapter {
  final String id;
  final String title;
  bool isComplete;

  Chapter({
    required this.id,
    required this.title,
    this.isComplete = false,
  });
}

class Story {
  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final String authorId;
  final String authorName;
  final int likes;
  final int views;
  final DateTime? publishedDate;
  final DateTime lastEdited;
  final List<User> collaborators;
  final List<Chapter>? chapters;
  final String storyType;
  StoryStatus status;
  final List<String>? genres;

  Story({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    required this.authorId,
    required this.authorName,
    this.likes = 0,
    this.views = 0,
    this.publishedDate,
    required this.lastEdited,
    this.collaborators = const [],
    this.chapters,
    required this.storyType,
    this.status = StoryStatus.draft,
    this.genres,
  });

  Story copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImage,
    String? authorId,
    String? authorName,
    int? likes,
    int? views,
    DateTime? publishedDate,
    DateTime? lastEdited,
    List<User>? collaborators,
    List<Chapter>? chapters,
    String? storyType,
    StoryStatus? status,
    List<String>? genres,
    bool? clearCoverImage,
    bool? clearPublishedDate,
    bool? clearChapters,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage:
          clearCoverImage == true ? null : coverImage ?? this.coverImage,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      publishedDate: clearPublishedDate == true
          ? null
          : publishedDate ?? this.publishedDate,
      lastEdited: lastEdited ?? this.lastEdited,
      collaborators: collaborators ?? this.collaborators,
      chapters: clearChapters == true ? null : chapters ?? this.chapters,
      storyType: storyType ?? this.storyType,
      status: status ?? this.status,
      genres: genres ?? this.genres,
    );
  }

  static List<Story> generateDummyStories(int count) {
    final dummyUser = User(
        id: 'user_0',
        name: 'Aranav Kumar',
        bio: 'Bio',
        location: 'Location',
        followers: 0,
        following: 0,
        stories: 0);

    return List.generate(
      count,
      (index) => Story(
        id: 'story_$index',
        title: "Echoes Tomorrow: Part ${index + 1}",
        description: "A scientist discovers hidden messages...",
        coverImage: "assets/images/example.png",
        authorId: dummyUser.id,
        authorName: dummyUser.name,
        likes: 1800 + index * 50,
        views: 3700 + index * 100,
        publishedDate: DateTime.now().subtract(Duration(days: count - index)),
        lastEdited: DateTime.now().subtract(Duration(hours: index * 2)),
        storyType: index % 2 == 0 ? 'Chapter-based' : 'Single Story',
        status: index % 3 == 0 ? StoryStatus.draft : StoryStatus.published,
        genres: ['Sci-Fi', 'Mystery'],
        chapters: index % 2 == 0
            ? [
                Chapter(
                    id: 'c${index}_1', title: 'Chapter 1', isComplete: true),
                Chapter(
                    id: 'c${index}_2', title: 'Chapter 2', isComplete: false),
              ]
            : null,
      ),
    );
  }
}
