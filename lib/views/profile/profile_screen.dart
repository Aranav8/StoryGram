import 'package:collabwrite/core/constants/assets.dart';
import 'package:collabwrite/core/constants/colors.dart';
import 'package:collabwrite/data/models/user_model.dart';
import 'package:collabwrite/viewmodel/profile_viewmodel.dart';
import 'package:collabwrite/views/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../create/create_screen.dart';
import '../home/home_screen.dart';
import '../library/library_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final int _selectedNavIndex = 3;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedNavIndex) return;

    final screens = [
      const HomeScreen(),
      const CreateScreen(),
      const LibraryScreen(),
      const ProfileScreen(),
    ];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screens[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading || viewModel.user == null) {
            // Show loading indicator
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _buildProfileHeader(viewModel.user!),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMyStoriesTab(viewModel),
                        _buildCollaborationsTab(viewModel),
                        _buildSavedTab(viewModel),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: CustomBottomNavBar(
              selectedIndex: _selectedNavIndex,
              onItemTapped: _onNavItemTapped,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        AppAssets.notification,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileAvatar(user),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildProfileInfo(user),
                ),
              ],
            ),
          ),
          _buildProfileStats(user),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(User user) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: user.profileImage != null
                ? NetworkImage(user.profileImage!)
                : null,
            backgroundColor: AppColors.secondary,
            child: user.profileImage == null
                ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
        if (user.isVerified)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileInfo(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildEditButton(),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          user.bio,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.textGrey, size: 14),
            const SizedBox(width: 2),
            Text(
              user.location,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            // const Icon(Icons.link, color: AppColors.textGrey, size: 14),
            // const SizedBox(width: 2),
            // Text(
            //   user.website,
            //   style: const TextStyle(
            //     color: AppColors.primary,
            //     fontSize: 12,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Text(
          'Edit',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildProfileStats(User user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border(
          top: BorderSide(
              color: AppColors.textGrey.withOpacity(0.3), width: 0.5),
          bottom: BorderSide(
              color: AppColors.textGrey.withOpacity(0.3), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('${user.followers}', 'Followers'),
          _buildStatDivider(),
          _buildStatItem('${user.following}', 'Following'),
          _buildStatDivider(),
          _buildStatItem('${user.stories}', 'Stories'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.textGrey.withOpacity(0.3),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primary,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textGrey,
      tabs: const [
        Tab(text: 'My Stories'),
        Tab(text: 'Collaborations'),
        Tab(text: 'Saved'),
      ],
    );
  }

  Widget _buildMyStoriesTab(ProfileViewModel viewModel) {
    return viewModel.userStories.isEmpty
        ? _buildEmptyState('You haven\'t published any stories yet.',
            'Create your first story', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CreateScreen()),
            );
          })
        : GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: viewModel.userStories.length,
            itemBuilder: (context, index) {
              final story = viewModel.userStories[index];
              return _buildStoryItem(story);
            },
          );
  }

  Widget _buildCollaborationsTab(ProfileViewModel viewModel) {
    return viewModel.collaborationStories.isEmpty
        ? _buildEmptyState('You haven\'t collaborated on any stories yet.',
            'Find collaborators', () {})
        : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: viewModel.collaborationStories.length,
            itemBuilder: (context, index) {
              final story = viewModel.collaborationStories[index];
              return _buildCollaborationItem(story);
            },
          );
  }

  Widget _buildSavedTab(ProfileViewModel viewModel) {
    return viewModel.savedStories.isEmpty
        ? _buildEmptyState(
            'You haven\'t saved any stories yet.', 'Explore stories', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          })
        : GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: viewModel.savedStories.length,
            itemBuilder: (context, index) {
              final story = viewModel.savedStories[index];
              return _buildStoryItem(story);
            },
          );
  }

  Widget _buildEmptyState(
      String message, String actionText, VoidCallback onAction) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 60,
              color: AppColors.textGrey,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                actionText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(Story story) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: Image.asset(
                  story.image,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(story.views),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatCount(story.likes),
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(story.publishedDate),
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborationItem(Story story) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.asset(
              story.image,
              height: 100,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Collaboration',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(story.publishedDate),
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(
                        story.collaborators.length > 3
                            ? 3
                            : story.collaborators.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                                story.collaborators[index].profileImage!),
                          ),
                        ),
                      ),
                      if (story.collaborators.length > 3)
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            '+${story.collaborators.length - 3}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}
