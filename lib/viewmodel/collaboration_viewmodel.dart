// viewmodel/collaboration_viewmodel.dart
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:collabwrite/data/models/story_model.dart'; // Adjust import path

enum CollaborationTab { collaborators, versionHistory }

class CollaborationViewModel extends ChangeNotifier {
  Story _story; // The story being managed
  CollaborationTab _selectedTab = CollaborationTab.collaborators;

  // --- Getters to expose data to the UI ---
  String get storyTitle => _story.title;
  int get chapterCount => _story.chapters?.length ?? 0;
  List<Collaborator> get collaborators =>
      List.unmodifiable(_story.collaborators); // Return unmodifiable list
  List<PendingReviewRequest> get pendingReviewRequests => List.unmodifiable(
      _story.pendingReviewRequests); // Return unmodifiable list
  bool get isShareableLinkActive => _story.isShareableLinkActive;
  bool get isReviewSystemActive => _story.isReviewSystemActive;

  CollaborationTab get selectedTab => _selectedTab;

  /// Returns the current state of the story object managed by this ViewModel.
  /// Useful for passing the story back when a screen is popped.
  Story get storyObjectForViewModel => _story;

  // --- Constructor ---
  CollaborationViewModel({required Story story}) : _story = story;

  // --- UI Actions ---
  void selectTab(CollaborationTab tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();
    }
  }

  // --- Data Modification Methods (Simulated) ---

  /// Simulates inviting a collaborator.
  /// In a real app, this would involve an API call.
  Future<void> inviteCollaborator(String emailOrUsername) async {
    if (kDebugMode) {
      print('Inviting $emailOrUsername to collaborate on "${_story.title}"');
    }
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // --- Example: How you might update state after a successful API call ---
    // This is commented out as it's a simulation.
    /*
    final newCollaborator = Collaborator(
      userId: 'new_user_${DateTime.now().millisecondsSinceEpoch}', // Generate a unique ID
      name: emailOrUsername.contains('@') ? emailOrUsername.split('@').first : emailOrUsername, // Basic name extraction
      role: CollaboratorRole.editor, // Default role for new invite
      joinedDate: DateTime.now(),
      avatarUrl: null, // Placeholder
    );

    // Create a new list of collaborators and update the story
    final updatedCollaborators = List<Collaborator>.from(_story.collaborators)..add(newCollaborator);
    _story = _story.copyWith(collaborators: updatedCollaborators);
    notifyListeners();
    */

    // For now, no actual state change, just a simulation message.
    // The UI will show a SnackBar based on this action.
  }

  /// Toggles the shareable link status for the story.
  Future<void> toggleShareableLink(bool isActive) async {
    if (kDebugMode) {
      print('Setting shareable link for "${_story.title}" to $isActive');
    }
    // Update the local story state
    _story = _story.copyWith(isShareableLinkActive: isActive);
    notifyListeners();

    // TODO: Implement API call to persist this change on the backend.
    // Example:
    // try {
    //   await ApiService.updateStorySettings(_story.id, shareableLink: isActive);
    // } catch (e) {
    //   if (kDebugMode) print("Error updating shareable link: $e");
    //   // Optionally revert state and show error
    //   _story = _story.copyWith(isShareableLinkActive: !isActive);
    //   notifyListeners();
    // }
  }

  /// Toggles the review system status for the story.
  Future<void> toggleReviewSystem(bool isActive) async {
    if (kDebugMode) {
      print('Setting review system for "${_story.title}" to $isActive');
    }
    // Update the local story state
    _story = _story.copyWith(isReviewSystemActive: isActive);
    notifyListeners();

    // TODO: Implement API call to persist this change on the backend.
  }

  /// Simulates reviewing a pending request (approving or rejecting).
  Future<void> reviewPendingRequest(String requestId,
      {required bool approve}) async {
    if (kDebugMode) {
      print(
          '${approve ? "Approving" : "Rejecting"} request $requestId for "${_story.title}"');
    }
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Remove the request from the list
    final updatedRequests = _story.pendingReviewRequests
        .where((req) => req.requestId != requestId)
        .toList();
    _story = _story.copyWith(pendingReviewRequests: updatedRequests);
    notifyListeners();

    // TODO: Implement API call to:
    // 1. Mark the request as reviewed (approved/rejected).
    // 2. If approved, potentially merge changes associated with the request.
  }

  /// Method to refresh the ViewModel's story from an external source.
  /// This is useful if another part of the app modified the story and this
  /// ViewModel needs to be updated (e.g., after popping back from another screen).
  void refreshStory(Story updatedStory) {
    // Check if the story actually changed to avoid unnecessary rebuilds,
    // though `copyWith` and `notifyListeners` handle this well.
    if (_story.id == updatedStory.id) {
      // Basic check, could be more thorough
      _story = updatedStory;
      notifyListeners();
    }
  }
}
