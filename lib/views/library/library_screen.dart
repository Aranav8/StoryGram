import 'package:collabwrite/core/constants/assets.dart';
import 'package:collabwrite/core/constants/colors.dart';
import 'package:collabwrite/views/home/home_screen.dart';
import 'package:collabwrite/views/create/create_screen.dart';
import 'package:collabwrite/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import '../../data/models/story.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/empty_state.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final int _selectedNavIndex = 2;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Single', 'Chapter-Based', 'Recent'];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  // Sample data - In a real app, this would come from a service or API
  final List<Story> _stories = [
    Story(
      id: '1',
      title: 'Echoes Tomorrow: A Sci-Fi Mystery',
      type: 'Chapter-Based',
      lastEdited: DateTime.now(),
      status: StoryStatus.draft,
      coverImage: 'assets/images/cover1.jpg',
      chapters: [
        Chapter(id: '1', title: 'Chapter 1: The Beginning', isComplete: true),
        Chapter(id: '2', title: 'Chapter 2: The Journey', isComplete: true),
        Chapter(id: '3', title: 'Chapter 3: The Revelation', isComplete: false),
      ],
    ),
    Story(
      id: '2',
      title: 'Echoes Tomorrow: A Sci-Fi Mystery',
      type: 'Single',
      lastEdited: DateTime.now(),
      status: StoryStatus.published,
      coverImage: 'assets/images/cover2.jpg',
    ),
    Story(
      id: '3',
      title: 'Echoes Tomorrow: A Sci-Fi Mystery',
      type: 'Single',
      lastEdited: DateTime.now(),
      status: StoryStatus.draft,
      coverImage: 'assets/images/cover3.jpg',
    ),
    Story(
      id: '4',
      title: 'The Last Frontier',
      type: 'Chapter-Based',
      lastEdited: DateTime.now().subtract(const Duration(days: 2)),
      status: StoryStatus.published,
      coverImage: 'assets/images/cover4.jpg',
      chapters: [
        Chapter(id: '1', title: 'Chapter 1: New Horizons', isComplete: true),
        Chapter(id: '2', title: 'Chapter 2: Discovery', isComplete: true),
      ],
    ),
    Story(
      id: '5',
      title: 'Midnight Chronicles',
      type: 'Single',
      lastEdited: DateTime.now().subtract(const Duration(days: 1)),
      status: StoryStatus.archived,
      coverImage: 'assets/images/cover5.jpg',
    ),
  ];

  List<Story> get _filteredStories {
    List<Story> filtered = List.from(_stories);

    // Apply search filter if search is active
    if (_isSearchActive && _searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((story) => story.title.toLowerCase().contains(query))
          .toList();
    }

    // Apply type filter
    if (_selectedFilter != 'All' && _selectedFilter != 'Recent') {
      filtered =
          filtered.where((story) => story.type == _selectedFilter).toList();
    } else if (_selectedFilter == 'Recent') {
      // Sort by last edited date for Recent filter
      filtered.sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
      // Limit to the most recent 5 stories
      if (filtered.length > 5) {
        filtered = filtered.sublist(0, 5);
      }
    }

    return filtered;
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

  void _navigateToCreateScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateScreen()),
    );
  }

  // void _navigateToStoryDetail(Story story) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => StoryDetailScreen(story: story)),
  //   );
  // }

  void _addNewChapter(Story story) {
    // Show dialog to enter chapter title
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Chapter'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter chapter title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // In a real app, this would update the database
              setState(() {
                final newIndex = story.chapters?.length ?? 0;
                story.chapters?.add(
                  Chapter(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: 'Chapter ${newIndex + 1}: New Chapter',
                    isComplete: false,
                  ),
                );
              });
              Navigator.pop(context);
              _showSnackBar('New chapter added');
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _toggleSearchActive() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Stories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._filters.map((filter) => FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedFilter = filter;
                          });
                          setState(() {});
                        },
                      )),
                  FilterChip(
                    label: const Text('Published'),
                    selected: _selectedFilter == 'Published',
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedFilter = 'Published';
                      });
                      setState(() {});
                    },
                  ),
                  FilterChip(
                    label: const Text('Drafts'),
                    selected: _selectedFilter == 'Drafts',
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedFilter = 'Drafts';
                      });
                      setState(() {});
                    },
                  ),
                  FilterChip(
                    label: const Text('Archived'),
                    selected: _selectedFilter == 'Archived',
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedFilter = 'Archived';
                      });
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedFilter = 'All';
                      });
                      setState(() {});
                    },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStoryOptions(Story story) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              story.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Story'),
              onTap: () {
                Navigator.pop(context);
                // _navigateToStoryDetail(story);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Sharing options coming soon');
              },
            ),
            if (story.status == StoryStatus.draft)
              ListTile(
                leading: const Icon(Icons.publish),
                title: const Text('Publish'),
                onTap: () {
                  setState(() {
                    story.status = StoryStatus.published;
                  });
                  Navigator.pop(context);
                  _showSnackBar('Story published successfully');
                },
              ),
            if (story.status == StoryStatus.published)
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('Archive'),
                onTap: () {
                  setState(() {
                    story.status = StoryStatus.archived;
                  });
                  Navigator.pop(context);
                  _showSnackBar('Story archived');
                },
              ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red[700]),
              title: Text('Delete', style: TextStyle(color: Colors.red[700])),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(story);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Story story) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Story'),
        content: Text(
            'Are you sure you want to delete "${story.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _stories.remove(story);
              });
              Navigator.pop(context);
              _showSnackBar('Story deleted');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildStoryCard(Story story) {
    // For chapter-based stories
    if (story.type == 'Chapter-Based' &&
        story.chapters != null &&
        story.chapters!.isNotEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      story.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${story.chapters!.length} chapters',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showStoryOptions(story),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(left: 8),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              ...story.chapters!.map((chapter) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chapter.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: chapter.isComplete
                                  ? Colors.black87
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                        if (chapter.isComplete)
                          const Icon(Icons.check, color: Colors.green, size: 16)
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Draft',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
              TextButton.icon(
                onPressed: () => _addNewChapter(story),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add New Chapter'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // For single stories
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          story.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            'Last Edited: ${_formatDateTime(story.lastEdited)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _getStatusColor(story.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _getStatusColor(story.status).withOpacity(0.3),
                ),
              ),
              child: Text(
                _getStatusText(story.status),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(story.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showStoryOptions(story),
            ),
          ],
        ),
        // onTap: () => _navigateToStoryDetail(story),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return 'Yesterday, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
    }
  }

  String _getStatusText(StoryStatus status) {
    switch (status) {
      case StoryStatus.draft:
        return 'Draft';
      case StoryStatus.published:
        return 'Published';
      case StoryStatus.archived:
        return 'Archived';
      default:
        return '';
    }
  }

  Color _getStatusColor(StoryStatus status) {
    switch (status) {
      case StoryStatus.draft:
        return Colors.orange[700]!;
      case StoryStatus.published:
        return Colors.green[700]!;
      case StoryStatus.archived:
        return Colors.grey[700]!;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStories = _filteredStories;
    final bool hasContent = filteredStories.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Library',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: _isSearchActive ? 0 : 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600]),
                    const SizedBox(width: 10),
                    if (_isSearchActive)
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (value) => setState(() {}),
                          autofocus: true,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _toggleSearchActive,
                        child: Text(
                          'Search',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    if (_isSearchActive)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _toggleSearchActive,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._filters.map((filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),
                        )),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterBottomSheet,
                      tooltip: 'More filters',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: hasContent
                    ? ListView.builder(
                        itemCount: filteredStories.length,
                        itemBuilder: (context, index) =>
                            _buildStoryCard(filteredStories[index]),
                      )
                    : EmptyState(
                        icon: Icons.menu_book,
                        title: 'No stories found',
                        message:
                            'Try adjusting your filters or create a new story',
                        actionLabel: 'Create New Story',
                        onAction: _navigateToCreateScreen,
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateScreen,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onItemTapped: _onNavItemTapped,
      ),
    );
  }
}
