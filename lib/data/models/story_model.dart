class Story {
  final String title;
  final String description;
  final String image;
  final String author;
  final int likes;
  final int views;

  Story({
    required this.title,
    required this.description,
    required this.image,
    required this.author,
    required this.likes,
    required this.views,
  });

  static List<Story> dummyStories = List.generate(
    10,
    (index) => Story(
      title: "Echoes Tomorrow: A Sci-Fi Mystery $index",
      description: "A scientist discovers hidden messages from the future...",
      image: "assets/images/example.png",
      author: "Nathen Wells",
      likes: 1800 + index * 100,
      views: 3700 + index * 200,
    ),
  );
}
