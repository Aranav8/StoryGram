// data/models/story_model.dart

// Assuming user_model.dart exists (as per your provided code for dummy data)
class User {
  final String id;
  final String name;
  final String? bio;
  final String? location;
  final String? profileImageUrl;
  final int followers;
  final int following;
  final int stories;

  User({
    required this.id,
    required this.name,
    this.bio,
    this.location,
    this.profileImageUrl,
    this.followers = 0,
    this.following = 0,
    this.stories = 0,
  });
}

enum StoryStatus {
  draft,
  published,
  archived,
}

enum CollaboratorRole { owner, editor, reviewer }

// --- Helper Functions for Parsing ---
String collaboratorRoleToString(CollaboratorRole role) {
  switch (role) {
    case CollaboratorRole.owner:
      return 'Owner';
    case CollaboratorRole.editor:
      return 'Editor';
    case CollaboratorRole.reviewer:
      return 'Reviewer';
  }
}

StoryStatus _parseStoryStatus(String? statusStr) {
  if (statusStr == null) return StoryStatus.draft;
  return StoryStatus.values.firstWhere(
      (e) =>
          e.toString().split('.').last.toLowerCase() ==
          statusStr.toLowerCase().trim(),
      orElse: () => StoryStatus.draft);
}

CollaboratorRole _parseCollaboratorRole(String? roleStr) {
  if (roleStr == null)
    return CollaboratorRole.editor; // Default or handle error
  return CollaboratorRole.values.firstWhere(
      (e) =>
          e.toString().split('.').last.toLowerCase() ==
          roleStr.toLowerCase().trim(),
      orElse: () => CollaboratorRole.editor); // Default if parsing fails
}

DateTime? _parseDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  try {
    return DateTime.parse(dateStr);
  } catch (e) {
    print("Error parsing date: $dateStr. Error: $e");
    return null; // Return null if parsing fails
  }
}

class Chapter {
  final String id;
  String title;
  String content;
  bool isComplete;

  Chapter({
    required this.id,
    required this.title,
    this.content = '',
    this.isComplete = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String? ??
          json['ID'] as String? ??
          'unknown_chapter_id',
      title: json['title'] as String? ??
          json['Title'] as String? ??
          'Untitled Chapter',
      content: json['content'] as String? ?? json['Content'] as String? ?? '',
      isComplete:
          json['isComplete'] as bool? ?? json['IsComplete'] as bool? ?? false,
    );
  }

  Chapter copyWith({
    String? id,
    String? title,
    String? content,
    bool? isComplete,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  String toString() {
    return 'Chapter(id: $id, title: "$title", isComplete: $isComplete, content: "${content.substring(0, (content.length > 20 ? 20 : content.length))}...")';
  }
}

class Collaborator {
  final String userId;
  final String name;
  final String? avatarUrl;
  final CollaboratorRole role;
  final DateTime joinedDate;

  Collaborator({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.role,
    required this.joinedDate,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      userId: json['userId'] as String? ??
          json['UserID'] as String? ??
          json['user_id'] as String? ??
          'unknown_user_id',
      name: json['name'] as String? ??
          json['Name'] as String? ??
          'Unknown Collaborator',
      avatarUrl: json['avatarUrl'] as String? ??
          json['AvatarURL'] as String? ??
          json['avatar_url'] as String?,
      role: _parseCollaboratorRole(
          json['role'] as String? ?? json['Role'] as String?),
      joinedDate: _parseDate(json['joinedDate'] as String? ??
              json['JoinedDate'] as String? ??
              json['joined_date'] as String?) ??
          DateTime.now(),
    );
  }

  Collaborator copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    CollaboratorRole? role,
    DateTime? joinedDate,
  }) {
    return Collaborator(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}

class PendingReviewRequest {
  final String requestId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String details;
  final DateTime requestedDate;
  final String? chapterId;

  PendingReviewRequest({
    required this.requestId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.details,
    required this.requestedDate,
    this.chapterId,
  });

  factory PendingReviewRequest.fromJson(Map<String, dynamic> json) {
    return PendingReviewRequest(
      requestId: json['requestId'] as String? ??
          json['RequestID'] as String? ??
          json['request_id'] as String? ??
          'unknown_req_id',
      userId: json['userId'] as String? ??
          json['UserID'] as String? ??
          json['user_id'] as String? ??
          'unknown_user_id',
      userName: json['userName'] as String? ??
          json['UserName'] as String? ??
          'Unknown User',
      userAvatarUrl: json['userAvatarUrl'] as String? ??
          json['UserAvatarURL'] as String? ??
          json['user_avatar_url'] as String?,
      details: json['details'] as String? ??
          json['Details'] as String? ??
          'No details',
      requestedDate: _parseDate(json['requestedDate'] as String? ??
              json['RequestedDate'] as String? ??
              json['requested_date'] as String?) ??
          DateTime.now(),
      chapterId: json['chapterId'] as String? ??
          json['ChapterID'] as String? ??
          json['chapter_id'] as String?,
    );
  }
}

class Story {
  final int id;
  final String title;
  final String? description;
  final String? coverImage;
  final String authorId; // Owner's ID
  final String authorName; // Owner's Name
  final int likes;
  final int views;
  final DateTime? publishedDate;
  DateTime lastEdited;
  final List<Chapter> chapters; // Non-nullable
  final String storyType;
  StoryStatus status;
  final List<String> genres; // Non-nullable

  // Collaboration fields
  List<Collaborator> collaborators;
  List<PendingReviewRequest> pendingReviewRequests; // Non-nullable
  bool isShareableLinkActive;
  bool isReviewSystemActive;

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
    List<Chapter>? chapters, // Nullable for constructor flexibility
    required this.storyType,
    this.status = StoryStatus.draft,
    List<String>? genres, // Nullable for constructor flexibility
    List<Collaborator>? collaborators, // Nullable for constructor flexibility
    List<PendingReviewRequest>?
        pendingReviewRequests, // Nullable for constructor flexibility
    this.isShareableLinkActive = false,
    this.isReviewSystemActive = true,
  })  : chapters = chapters ?? [], // Initialize to empty list if null
        genres = genres ?? [], // Initialize to empty list if null
        pendingReviewRequests =
            pendingReviewRequests ?? [], // Initialize to empty list if null
        collaborators =
            collaborators ?? // Initialize with owner if not provided
                [
                  Collaborator(
                    userId: authorId,
                    name: authorName,
                    avatarUrl: null,
                    role: CollaboratorRole.owner,
                    joinedDate: lastEdited,
                  )
                ];

  factory Story.fromJson(Map<String, dynamic> json) {
    // Helper to safely cast list elements
    List<T> _parseList<T>(
        dynamic listJson, T Function(Map<String, dynamic>) fromJson) {
      if (listJson is List) {
        return listJson
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    final List<Chapter> parsedChapters = _parseList(
      json['Chapters'] ?? json['chapters'],
      (c) => Chapter.fromJson(c),
    );

    List<Collaborator> parsedCollaborators = _parseList(
      json['Collaborators'] ?? json['collaborators'],
      (c) => Collaborator.fromJson(c),
    );

    final List<PendingReviewRequest> parsedPendingReviewRequests = _parseList(
      json['PendingReviewRequests'] ??
          json['pendingReviewRequests'] ??
          json['pending_review_requests'],
      (r) => PendingReviewRequest.fromJson(r),
    );

    final List<String> parsedGenres = (json['Genres'] as List<dynamic>? ??
            json['genres'] as List<dynamic>? ??
            [])
        .map((g) => g.toString())
        .toList();

    final String effectiveAuthorId = json['AuthorID'] as String? ??
        json['authorId'] as String? ??
        json['author_id'] as String? ??
        'unknown_author_id';
    final String effectiveAuthorName = json['AuthorName'] as String? ??
        json['authorName'] as String? ??
        json['author_name'] as String? ??
        'Unknown Author';
    final DateTime effectiveLastEdited = _parseDate(
            json['LastEdited'] as String? ??
                json['lastEdited'] as String? ??
                json['last_edited'] as String?) ??
        DateTime.now();

    // Ensure owner is present in collaborators list
    if (!parsedCollaborators.any((c) => c.role == CollaboratorRole.owner)) {
      parsedCollaborators.insert(
          0,
          Collaborator(
            userId: effectiveAuthorId,
            name: effectiveAuthorName,
            role: CollaboratorRole.owner,
            joinedDate: effectiveLastEdited, // Or a creation date if available
          ));
    }
    // Remove duplicates if any, preferring the one explicitly marked as owner or first one.
    final uniqueCollaborators = <String, Collaborator>{};
    for (var collaborator in parsedCollaborators) {
      if (!uniqueCollaborators.containsKey(collaborator.userId) ||
          collaborator.role == CollaboratorRole.owner) {
        uniqueCollaborators[collaborator.userId] = collaborator;
      }
    }
    parsedCollaborators = uniqueCollaborators.values.toList();

    return Story(
      id: json['ID'] as int? ?? json['id'] as int? ?? 0,
      title: json['Title'] as String? ??
          json['title'] as String? ??
          'Untitled Story',
      description:
          json['Description'] as String? ?? json['description'] as String?,
      coverImage: json['CoverImage'] as String? ??
          json['coverImage'] as String? ??
          json['cover_image'] as String?,
      authorId: effectiveAuthorId,
      authorName: effectiveAuthorName,
      likes: json['Likes'] as int? ?? json['likes'] as int? ?? 0,
      views: json['Views'] as int? ?? json['views'] as int? ?? 0,
      publishedDate: _parseDate(json['PublishedDate'] as String? ??
          json['publishedDate'] as String? ??
          json['published_date'] as String?),
      lastEdited: effectiveLastEdited,
      chapters: parsedChapters,
      storyType: json['StoryType'] as String? ??
          json['storyType'] as String? ??
          json['story_type'] as String? ??
          'Single Story',
      status: _parseStoryStatus(
          json['Status'] as String? ?? json['status'] as String?),
      genres: parsedGenres,
      collaborators: parsedCollaborators,
      pendingReviewRequests: parsedPendingReviewRequests,
      isShareableLinkActive: json['IsShareableLinkActive'] as bool? ??
          json['isShareableLinkActive'] as bool? ??
          json['is_shareable_link_active'] as bool? ??
          false,
      isReviewSystemActive: json['IsReviewSystemActive'] as bool? ??
          json['isReviewSystemActive'] as bool? ??
          json['is_review_system_active'] as bool? ??
          true,
    );
  }

  Story copyWith({
    int? id,
    String? title,
    String? description,
    String? coverImage,
    bool clearCoverImage = false,
    String? authorId,
    String? authorName,
    int? likes,
    int? views,
    DateTime? publishedDate,
    bool clearPublishedDate = false,
    DateTime? lastEdited,
    List<Chapter>? chapters,
    bool clearChapters = false,
    String? storyType,
    StoryStatus? status,
    List<String>? genres,
    List<Collaborator>? collaborators,
    List<PendingReviewRequest>? pendingReviewRequests,
    bool? isShareableLinkActive,
    bool? isReviewSystemActive,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: clearCoverImage ? null : (coverImage ?? this.coverImage),
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      publishedDate:
          clearPublishedDate ? null : (publishedDate ?? this.publishedDate),
      lastEdited: lastEdited ?? this.lastEdited,
      chapters: clearChapters
          ? []
          : (chapters ?? this.chapters), // Use [] if clearing
      storyType: storyType ?? this.storyType,
      status: status ?? this.status,
      genres: genres ?? this.genres,
      collaborators: collaborators ?? this.collaborators,
      pendingReviewRequests:
          pendingReviewRequests ?? this.pendingReviewRequests,
      isShareableLinkActive:
          isShareableLinkActive ?? this.isShareableLinkActive,
      isReviewSystemActive: isReviewSystemActive ?? this.isReviewSystemActive,
    );
  }

  static List<Story> generateDummyStories(int count) {
    final dummyOwner = User(
        id: 'user_owner_0',
        name: 'Aranav Kumar',
        bio: 'A passionate storyteller exploring the echoes of tomorrow.',
        location: 'Cyber City',
        profileImageUrl: null,
        followers: 1250,
        following: 150,
        stories: count ~/ 2);

    return List.generate(
      count,
      (index) {
        bool isChapterBased = index % 2 == 0;
        StoryStatus currentStatus;
        switch (index % 3) {
          case 0:
            currentStatus = StoryStatus.draft;
            break;
          case 1:
            currentStatus = StoryStatus.published;
            break;
          default:
            currentStatus = StoryStatus.archived;
            break;
        }

        List<Chapter> storyChapters = []; // Initialize as non-nullable
        if (isChapterBased) {
          storyChapters = [
            Chapter(
                id: 'c${index}_1',
                title: 'The Anomaly Begins',
                content: '...',
                isComplete: true),
            Chapter(
                id: 'c${index}_2',
                title: 'Echoes in the Machine',
                content: '...',
                isComplete: index % 4 == 0),
            Chapter(
                id: 'c${index}_3',
                title: 'The Revelation',
                content: '...',
                isComplete: false),
          ];
        }

        DateTime storyCreationTime =
            DateTime.now().subtract(Duration(days: (count - index) * 7 + 14));
        DateTime lastEditedTime = DateTime.now()
            .subtract(Duration(hours: index * 2 + 1, minutes: index * 15));

        List<Collaborator> storyCollaborators = [
          Collaborator(
            userId: dummyOwner.id,
            name: dummyOwner.name,
            role: CollaboratorRole.owner,
            joinedDate: storyCreationTime,
            avatarUrl: dummyOwner.profileImageUrl,
          ),
          if (index % 2 != 0)
            Collaborator(
              userId: 'user_editor_${index}',
              name: 'Sam Editor',
              role: CollaboratorRole.editor,
              joinedDate: storyCreationTime.add(Duration(days: 5 + index % 3)),
              avatarUrl: null,
            ),
          if (index % 3 == 1)
            Collaborator(
              userId: 'user_reviewer_${index}',
              name: 'Pat Reviewer',
              role: CollaboratorRole.reviewer,
              joinedDate: storyCreationTime.add(Duration(days: 2 + index % 2)),
              avatarUrl: null,
            ),
        ];

        List<PendingReviewRequest> currentRequests = [];
        if (index == 0 &&
            storyCollaborators.any((c) =>
                c.role == CollaboratorRole.editor &&
                c.userId.startsWith('user_editor'))) {
          final editor = storyCollaborators.firstWhere((c) =>
              c.role == CollaboratorRole.editor &&
              c.userId.startsWith('user_editor'));
          currentRequests.add(PendingReviewRequest(
            requestId: 'req_1_story_$index',
            userId: editor.userId,
            userName: editor.name,
            userAvatarUrl: editor.avatarUrl,
            details: 'Edits to Chapter 3',
            requestedDate: DateTime.now().subtract(const Duration(hours: 2)),
            chapterId: storyChapters.length > 2 ? storyChapters[2].id : null,
          ));
        } else if (index == 2 &&
            storyCollaborators.any((c) =>
                c.role == CollaboratorRole.reviewer &&
                c.userId.startsWith('user_reviewer'))) {
          final reviewer = storyCollaborators.firstWhere((c) =>
              c.role == CollaboratorRole.reviewer &&
              c.userId.startsWith('user_reviewer'));
          currentRequests.add(PendingReviewRequest(
            requestId: 'req_2_story_$index',
            userId: reviewer.userId,
            userName: reviewer.name,
            userAvatarUrl: reviewer.avatarUrl,
            details: 'Review request for Chapter 1',
            requestedDate: DateTime.now().subtract(const Duration(hours: 5)),
            chapterId: storyChapters.isNotEmpty ? storyChapters[0].id : null,
          ));
        }

        return Story(
          id: index.toInt(),
          title: "Echoes Tomorrow: Part ${index + 1}",
          description: isChapterBased
              ? "A brilliant scientist..."
              : "A standalone tale...",
          coverImage: "assets/images/example.png",
          authorId: dummyOwner.id,
          authorName: dummyOwner.name,
          likes: 1800 + index * 53,
          views: 3700 + index * 112,
          publishedDate: currentStatus == StoryStatus.published
              ? storyCreationTime.add(Duration(days: 7))
              : null,
          lastEdited: lastEditedTime,
          storyType: isChapterBased ? 'Chapter-based' : 'Single Story',
          status: currentStatus,
          genres: ['Sci-Fi', 'Mystery', if (index % 3 == 0) 'Thriller'],
          chapters: storyChapters, // Pass the non-nullable list
          collaborators:
              storyCollaborators, // Pass the pre-built list with owner
          pendingReviewRequests: currentRequests, // Pass the non-nullable list
          isShareableLinkActive: index % 2 == 0,
          isReviewSystemActive: true,
        );
      },
    );
  }

  @override
  String toString() {
    return 'Story(id: $id, title: "$title", type: $storyType, status: $status, chapters: ${chapters.length}, collaborators: ${collaborators.length})';
  }
}
