// data/models/story_model.dart
import 'package:flutter/foundation.dart'; // For kDebugMode

// User class (as provided by you previously, ensure this matches your actual User model if different)
class User {
  final String id; // Assuming user ID is a string in your main User model
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
  return role.toString().split('.').last; // Simpler conversion
}

StoryStatus _parseStoryStatus(String? statusStr) {
  if (statusStr == null || statusStr.isEmpty) return StoryStatus.draft;
  return StoryStatus.values.firstWhere(
      (e) =>
          e.toString().split('.').last.toLowerCase() ==
          statusStr.toLowerCase().trim(), orElse: () {
    if (kDebugMode)
      print(
          "Warning: Could not parse story status '$statusStr', defaulting to draft.");
    return StoryStatus.draft;
  });
}

CollaboratorRole _parseCollaboratorRole(String? roleStr) {
  if (roleStr == null || roleStr.isEmpty)
    return CollaboratorRole.editor; // Default
  return CollaboratorRole.values.firstWhere(
      (e) =>
          e.toString().split('.').last.toLowerCase() ==
          roleStr.toLowerCase().trim(), orElse: () {
    if (kDebugMode)
      print(
          "Warning: Could not parse collaborator role '$roleStr', defaulting to editor.");
    return CollaboratorRole.editor;
  });
}

DateTime? _parseDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  try {
    return DateTime.parse(dateStr)
        .toLocal(); // Parse and convert to local time if stored as UTC
  } catch (e) {
    if (kDebugMode) print("Error parsing date: $dateStr. Error: $e");
    return null;
  }
}

class Chapter {
  final String
      id; // Keep as String if backend sends it as String, or int if backend sends int
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
      id: (json['id'] ?? json['ID'] ?? 'unknown_chapter_id').toString(),
      title: json['title'] as String? ??
          json['Title'] as String? ??
          'Untitled Chapter',
      content: json['content'] as String? ?? json['Content'] as String? ?? '',
      isComplete:
          json['isComplete'] as bool? ?? json['IsComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id, // Assuming backend expects 'ID' for chapter ID
      'Title': title,
      'Content': content,
      'IsComplete': isComplete,
    };
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
}

class Collaborator {
  final String userId; // User ID stored as String
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
      userId: (json['userId'] ??
              json['UserID'] ??
              json['user_id'] ??
              'unknown_user_id')
          .toString(),
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

  Map<String, dynamic> toJson() {
    return {
      // Assuming backend expects UserID (int) for collaborator's user ID
      'UserID':
          int.tryParse(userId), // Convert String userId back to int for payload
      'Name': name,
      'AvatarURL': avatarUrl,
      'Role': collaboratorRoleToString(role),
      'JoinedDate': joinedDate.toUtc().toIso8601String(),
    };
  }
}

class PendingReviewRequest {
  final String requestId;
  final String userId; // Stored as String
  final String userName;
  final String? userAvatarUrl;
  final String details;
  final DateTime requestedDate;
  final String? chapterId; // Stored as String

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
      requestId: (json['requestId'] ??
              json['RequestID'] ??
              json['request_id'] ??
              'unknown_req_id')
          .toString(),
      userId: (json['userId'] ??
              json['UserID'] ??
              json['user_id'] ??
              'unknown_user_id')
          .toString(),
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
      chapterId: (json['chapterId'] ?? json['ChapterID'] ?? json['chapter_id'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RequestID': requestId,
      'UserID': int.tryParse(userId), // Convert String userId back to int
      'UserName': userName,
      'UserAvatarURL': userAvatarUrl,
      'Details': details,
      'RequestedDate': requestedDate.toUtc().toIso8601String(),
      'ChapterID':
          chapterId, // Send as string if it is string, or int.tryParse if needed
    };
  }
}

class Story {
  final int
      id; // Story's own ID, typically int from backend (e.g., "ID": 1747000419)
  final String title;
  final String? description;
  final String? coverImage;
  final String
      authorId; // Owner's user ID - Stored as String (parsed from int UserID in JSON)
  final String authorName;
  final int likes;
  final int views;
  final DateTime? publishedDate;
  DateTime lastEdited;
  final List<Chapter> chapters;
  final String storyType;
  StoryStatus status;
  final List<String> genres;

  List<Collaborator> collaborators;
  List<PendingReviewRequest> pendingReviewRequests;
  bool isShareableLinkActive;
  bool isReviewSystemActive;

  Story({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    required this.authorId, // Expect a string here (e.g., "11")
    required this.authorName,
    this.likes = 0,
    this.views = 0,
    this.publishedDate,
    required this.lastEdited,
    List<Chapter>? chapters,
    required this.storyType,
    this.status = StoryStatus.draft,
    List<String>? genres,
    List<Collaborator>? collaborators,
    List<PendingReviewRequest>? pendingReviewRequests,
    this.isShareableLinkActive = false,
    this.isReviewSystemActive = true,
  })  : chapters = chapters ?? [],
        genres = genres ?? [],
        pendingReviewRequests = pendingReviewRequests ?? [],
        collaborators = collaborators ??
            [
              // Default collaborator is the owner
              Collaborator(
                userId: authorId, // authorId is already a string
                name: authorName,
                role: CollaboratorRole.owner,
                joinedDate:
                    lastEdited, // Or a more appropriate creation/join date
              )
            ];

  factory Story.fromJson(Map<String, dynamic> json) {
    List<T> _parseList<T>(
        dynamic listJson, T Function(Map<String, dynamic>) fromJson) {
      if (listJson is List) {
        return listJson
            .map((item) {
              try {
                return fromJson(item as Map<String, dynamic>);
              } catch (e) {
                if (kDebugMode)
                  print("Error parsing item in list: $item. Error: $e");
                return null; // Or throw, or return a default
              }
            })
            .whereType<T>()
            .toList(); // Filter out nulls if any item fails to parse
      }
      return [];
    }

    String parsedAuthorId;
    final dynamic rawAuthorId = json['UserID'] ??
        json['user_id'] ??
        json['AuthorID'] ??
        json['author_id'];
    if (rawAuthorId != null) {
      parsedAuthorId =
          rawAuthorId.toString(); // Convert int from JSON to String
    } else {
      if (kDebugMode)
        print(
            "Story.fromJson Warning: UserID/AuthorID not found. Defaulting authorId to '0'. JSON: $json");
      parsedAuthorId = "0";
    }

    String parsedAuthorName = json['AuthorName'] as String? ??
        json['author_name'] as String? ??
        (json['author'] as Map<String, dynamic>?)?['name']
            as String? ?? // If author is a nested object
        'Unknown Author';

    DateTime effectiveLastEdited = _parseDate(
            json['LastEdited'] as String? ?? json['last_edited'] as String?) ??
        DateTime.now().toUtc();

    List<Collaborator> parsedCollaborators = _parseList(
        json['Collaborators'] ?? json['collaborators'],
        (c) => Collaborator.fromJson(c));

    if (parsedAuthorId != "0" &&
        !parsedCollaborators.any((c) =>
            c.userId == parsedAuthorId && c.role == CollaboratorRole.owner)) {
      parsedCollaborators.insert(
        0,
        Collaborator(
          userId: parsedAuthorId,
          name: parsedAuthorName,
          role: CollaboratorRole.owner,
          joinedDate: _parseDate(json['PublishedDate'] as String?) ??
              effectiveLastEdited, // Use published or last edited as join date for owner
        ),
      );
    }
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
      coverImage:
          json['CoverImage'] as String? ?? json['cover_image'] as String?,
      authorId: parsedAuthorId, // Use the String ID
      authorName: parsedAuthorName,
      likes: json['Likes'] as int? ?? json['likes'] as int? ?? 0,
      views: json['Views'] as int? ?? json['views'] as int? ?? 0,
      publishedDate: _parseDate(json['PublishedDate'] as String? ??
          json['published_date'] as String?),
      lastEdited: effectiveLastEdited,
      chapters: _parseList(
          json['Chapters'] ?? json['chapters'], (c) => Chapter.fromJson(c)),
      storyType: json['StoryType'] as String? ??
          json['story_type'] as String? ??
          'Single Story',
      status: _parseStoryStatus(
          json['Status'] as String? ?? json['status'] as String?),
      genres: (json['Genres'] as List<dynamic>? ??
              json['genres'] as List<dynamic>? ??
              [])
          .map((g) => g.toString())
          .toList(),
      collaborators: parsedCollaborators,
      pendingReviewRequests: _parseList(
          json['PendingReviewRequests'] ?? json['pending_review_requests'],
          (r) => PendingReviewRequest.fromJson(r)),
      isShareableLinkActive: json['IsShareableLinkActive'] as bool? ??
          json['is_shareable_link_active'] as bool? ??
          false,
      isReviewSystemActive: json['IsReviewSystemActive'] as bool? ??
          json['is_review_system_active'] as bool? ??
          true,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert String authorId back to int for user_id field when sending to backend
    int? authorIdAsInt = int.tryParse(authorId);
    if (authorIdAsInt == null) {
      if (kDebugMode)
        print(
            "Story.toJson Error: authorId ('$authorId') is not a valid integer string. Sending null for 'user_id' / 'UserID'.");
    }

    return {
      // Match your backend's expected keys for story POST/PUT/PATCH
      'ID': id, // Or 'id'
      'Title': title,
      'Description': description,
      'CoverImage': coverImage,
      'UserID': authorIdAsInt, // Backend expects UserID (int) or user_id (int)
      'Likes': likes,
      'Views': views,
      'PublishedDate': publishedDate?.toUtc().toIso8601String(),
      'LastEdited': lastEdited.toUtc().toIso8601String(),
      'StoryType': storyType,
      'Status': status.toString().split('.').last.toLowerCase(),
      'Genres': genres,
      'Chapters': chapters.map((c) => c.toJson()).toList(),
      'Collaborators': collaborators.map((c) => c.toJson()).toList(),
      'PendingReviewRequests':
          pendingReviewRequests.map((r) => r.toJson()).toList(),
      'IsShareableLinkActive': isShareableLinkActive,
      'IsReviewSystemActive': isReviewSystemActive,
    };
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
          : (chapters ??
              List<Chapter>.from(this
                  .chapters
                  .map((c) => c.copyWith()))), // Deep copy chapters
      storyType: storyType ?? this.storyType,
      status: status ?? this.status,
      genres: genres ?? List<String>.from(this.genres), // Deep copy genres
      collaborators: collaborators ??
          List<Collaborator>.from(this
              .collaborators), // Consider deep copy if Collaborator is mutable
      pendingReviewRequests: pendingReviewRequests ??
          List<PendingReviewRequest>.from(
              this.pendingReviewRequests), // Deep copy
      isShareableLinkActive:
          isShareableLinkActive ?? this.isShareableLinkActive,
      isReviewSystemActive: isReviewSystemActive ?? this.isReviewSystemActive,
    );
  }

  // generateDummyStories as provided by you
  static List<Story> generateDummyStories(int count) {
    final dummyOwner = User(
        id: 'user_owner_0', // String ID
        name: 'Aranav Kumar',
        bio: 'A passionate storyteller exploring the echoes of tomorrow.',
        location: 'Cyber City',
        profileImageUrl: null, // This is fine
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

        List<Chapter> storyChapters = [];
        if (isChapterBased) {
          storyChapters = [
            Chapter(
                id: 'c${index}_1',
                title: 'The Anomaly Begins',
                content: 'Content for chapter 1...',
                isComplete: true),
            Chapter(
                id: 'c${index}_2',
                title: 'Echoes in the Machine',
                content: 'Content for chapter 2...',
                isComplete: index % 4 == 0),
            Chapter(
                id: 'c${index}_3',
                title: 'The Revelation',
                content: 'Content for chapter 3...',
                isComplete: false),
          ];
        }

        DateTime storyCreationTime =
            DateTime.now().subtract(Duration(days: (count - index) * 7 + 14));
        DateTime lastEditedTime = DateTime.now()
            .subtract(Duration(hours: index * 2 + 1, minutes: index * 15));

        // Create owner collaborator using string ID
        List<Collaborator> storyCollaborators = [
          Collaborator(
            userId: dummyOwner.id, // String ID
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
                joinedDate:
                    storyCreationTime.add(Duration(days: 5 + index % 3)),
                avatarUrl: null),
          if (index % 3 == 1)
            Collaborator(
                userId: 'user_reviewer_${index}',
                name: 'Pat Reviewer',
                role: CollaboratorRole.reviewer,
                joinedDate:
                    storyCreationTime.add(Duration(days: 2 + index % 2)),
                avatarUrl: null),
        ];

        List<PendingReviewRequest> currentRequests = [];
        // ... (pending review request logic can stay same, ensure userId is string)

        return Story(
          id: index, // Story ID is int
          title: "Echoes Tomorrow: Part ${index + 1}",
          description: isChapterBased
              ? "A brilliant scientist uncovers a temporal anomaly with far-reaching consequences, forcing them to confront the echoes of decisions not yet made."
              : "A standalone tale of digital ghosts and forgotten futures, where memories linger in the static between worlds.",
          coverImage: "assets/images/example.png", // Ensure this asset exists
          authorId: dummyOwner.id, // Pass the String ID
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
          chapters: storyChapters,
          collaborators: storyCollaborators,
          pendingReviewRequests: currentRequests,
          isShareableLinkActive: index % 2 == 0,
          isReviewSystemActive: true,
        );
      },
    );
  }
}
