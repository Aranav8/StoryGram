// views/collaboration/collaboration_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'package:collabwrite/core/constants/colors.dart';
import 'package:collabwrite/data/models/story_model.dart';
import 'package:collabwrite/viewmodel/collaboration_viewmodel.dart';
import 'package:collabwrite/views/widgets/custom_bottom_nav_bar.dart';
// Import other screens for bottom nav
import 'package:collabwrite/views/home/home_screen.dart';
import 'package:collabwrite/views/create/create_screen.dart';
import 'package:collabwrite/views/library/library_screen.dart';
import 'package:collabwrite/views/profile/profile_screen.dart';

class CollaborationScreen extends StatelessWidget {
  final Story story;

  const CollaborationScreen({super.key, required this.story});

  static const String routeName = '/collaboration'; // Define static routeName

  @override
  Widget build(BuildContext context) {
    // ... rest of the build method providing CollaborationViewModel
    return ChangeNotifierProvider(
      create: (_) => CollaborationViewModel(story: story),
      child: const _CollaborationScreenContent(),
    );
  }
}

class _CollaborationScreenContent extends StatefulWidget {
  const _CollaborationScreenContent();

  @override
  State<_CollaborationScreenContent> createState() =>
      _CollaborationScreenContentState();
}

class _CollaborationScreenContentState
    extends State<_CollaborationScreenContent> {
  final int _initialSelectedNavIndex = 2;

  void _onNavItemTapped(
      BuildContext context, int index, CollaborationViewModel viewModel) {
    // If any unsaved changes on this screen (e.g. pending API calls for settings)
    // you might want a similar unsaved changes dialog. For now, direct navigation.
    if (index == _initialSelectedNavIndex) return;

    _navigateToScreen(context, index, viewModel.storyObjectForViewModel);
  }

  void _navigateToScreen(
      BuildContext context, int index, Story currentStoryState) {
    final screens = [
      const HomeScreen(),
      const CreateScreen(),
      const LibraryScreen(), // Consider passing currentStoryState if LibraryScreen needs it immediately
      const ProfileScreen(),
    ];
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => screens[index],
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    ).then((_) {
      // This `then` might not be directly useful here as we are removing all routes.
      // State should be managed via providers.
    });
  }

  void _showInviteDialog(
      BuildContext context, CollaborationViewModel viewModel) {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Invite Collaborator'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: 'Enter email or username',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (emailController.text.trim().isNotEmpty) {
                  viewModel.inviteCollaborator(emailController.text.trim());
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    // Use main context
                    SnackBar(
                        content: Text(
                            'Invitation sent to ${emailController.text.trim()} (simulated)')),
                  );
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter an email or username')),
                  );
                }
              },
              child: const Text('Invite'),
            ),
          ],
        );
      },
    );
  }

  Color _getRoleColor(CollaboratorRole role) {
    switch (role) {
      case CollaboratorRole.owner:
        return Colors.green.shade600;
      case CollaboratorRole.editor:
        return AppColors.primary;
      case CollaboratorRole.reviewer:
        return Colors.amber.shade800;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime); // For older dates
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CollaborationViewModel>();

    return WillPopScope(
      onWillPop: () async {
        // Pass back the potentially modified story when popping with system back button
        Navigator.of(context).pop(viewModel.storyObjectForViewModel);
        return false; // We handle the pop manually
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1.0,
          shadowColor: Colors.grey[200],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.background),
            onPressed: () => Navigator.of(context).pop(
                viewModel.storyObjectForViewModel), // Pass back the story state
          ),
          title: const Text(
            'Collaborations & Versions',
            style: TextStyle(
                color: AppColors.background,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Story Info Banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        viewModel.storyTitle,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Chip(
                      label: Text('${viewModel.chapterCount} Chapters',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      labelPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tabs
              Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Collaborators',
                      isSelected: viewModel.selectedTab ==
                          CollaborationTab.collaborators,
                      onTap: () =>
                          viewModel.selectTab(CollaborationTab.collaborators),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TabButton(
                      label: 'Version History',
                      isSelected: viewModel.selectedTab ==
                          CollaborationTab.versionHistory,
                      onTap: () =>
                          viewModel.selectTab(CollaborationTab.versionHistory),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tab Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: viewModel.selectedTab == CollaborationTab.collaborators
                    ? _buildCollaboratorsTab(context, viewModel)
                    : _buildVersionHistoryTab(context, viewModel),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _initialSelectedNavIndex,
          onItemTapped: (index) => _onNavItemTapped(context, index, viewModel),
        ),
      ),
    );
  }

  Widget _buildCollaboratorsTab(
      BuildContext context, CollaborationViewModel viewModel) {
    return Column(
      key: const ValueKey('collaboratorsTab'), // For AnimatedSwitcher
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Current Collaborators',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 20, color: AppColors.tint),
              label: const Text('Invite+',
                  style: TextStyle(
                      color: AppColors.tint, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: () => _showInviteDialog(context, viewModel),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (viewModel.collaborators.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text('No collaborators yet. Invite someone!')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.collaborators.length,
            itemBuilder: (ctx, index) {
              final collaborator = viewModel.collaborators[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0.5,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: collaborator.avatarUrl != null &&
                            collaborator.avatarUrl!.isNotEmpty
                        ? NetworkImage(collaborator.avatarUrl!)
                            as ImageProvider // Cast for type safety
                        : null,
                    child: (collaborator.avatarUrl == null ||
                            collaborator.avatarUrl!.isEmpty)
                        ? Text(
                            collaborator.name.isNotEmpty
                                ? collaborator.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                  title: Text(collaborator.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${collaboratorRoleToString(collaborator.role)} • ${collaborator.role == CollaboratorRole.owner ? "Created" : "Joined"} ${_formatRelativeTime(collaborator.joinedDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  trailing: Chip(
                    label: Text(collaboratorRoleToString(collaborator.role)),
                    backgroundColor:
                        _getRoleColor(collaborator.role).withOpacity(0.15),
                    labelStyle: TextStyle(
                        color: _getRoleColor(collaborator.role),
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 25),
        const Text('Collaboration Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _SettingItem(
          title: 'Shareable Link',
          subtitle: 'Anyone with the link can request access',
          isActive: viewModel.isShareableLinkActive,
          onChanged: (value) => viewModel.toggleShareableLink(value),
        ),
        _SettingItem(
          title: 'Review System',
          subtitle: 'Approve edits before publishing',
          isActive: viewModel.isReviewSystemActive,
          onChanged: (value) => viewModel.toggleReviewSystem(value),
        ),
        if (viewModel.pendingReviewRequests.isNotEmpty) ...[
          const SizedBox(height: 25),
          Text(
              'Pending Review Requests (${viewModel.pendingReviewRequests.length})',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.pendingReviewRequests.length,
            itemBuilder: (ctx, index) {
              final request = viewModel.pendingReviewRequests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0.5,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: request.userAvatarUrl != null &&
                            request.userAvatarUrl!.isNotEmpty
                        ? NetworkImage(request.userAvatarUrl!) as ImageProvider
                        : null,
                    child: (request.userAvatarUrl == null ||
                            request.userAvatarUrl!.isEmpty)
                        ? Text(
                            request.userName.isNotEmpty
                                ? request.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                  title: Text(request.details,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      'By ${request.userName} • Requested ${_formatRelativeTime(request.requestedDate)}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  trailing: ElevatedButton(
                    onPressed: () {
                      viewModel.reviewPendingRequest(request.requestId,
                          approve: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Request from ${request.userName} marked as reviewed (simulated)')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tint,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    child: const Text('Review', style: TextStyle(fontSize: 12)),
                  ),
                ),
              );
            },
          ),
        ]
      ],
    );
  }

  Widget _buildVersionHistoryTab(
      BuildContext context, CollaborationViewModel viewModel) {
    return Center(
      key: const ValueKey('versionHistoryTab'), // For AnimatedSwitcher
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_toggle_off_outlined,
                size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Version History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Track changes, compare versions, and revert to previous states of your story. This feature is coming soon!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Tab Buttons
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.tint : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : AppColors.textGrey,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: isSelected ? 2 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }
}

// Helper Widget for Setting Items
class _SettingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const _SettingItem({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        value: isActive,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        dense: true,
      ),
    );
  }
}
