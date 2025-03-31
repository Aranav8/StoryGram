import 'dart:io';

import 'package:collabwrite/core/constants/colors.dart';
import 'package:collabwrite/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../library/library_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/story_type_option.dart';
import 'package:image_picker/image_picker.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final int _selectedNavIndex = 1;
  String _selectedStoryType = 'Single Story';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _writingController = TextEditingController();

  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String? _coverImagePath;
  final List<String> _availableStoryTypes = [
    'Single Story',
    'Chapter-based',
    'Collaborative'
  ];
  final List<String> _popularGenres = [
    'Fiction',
    'Fantasy',
    'Adventure',
    'Romance',
    'Sci-Fi',
    'Mystery',
    'Thriller',
    'Horror',
    'Historical',
    'Non-Fiction'
  ];

  @override
  void initState() {
    super.initState();
    _setupTextControllerListeners();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    _writingController.dispose();
    super.dispose();
  }

  void _setupTextControllerListeners() {
    void listener() => setState(() => _hasUnsavedChanges = true);
    _titleController.addListener(listener);
    _descriptionController.addListener(listener);
    _genreController.addListener(listener);
    _writingController.addListener(listener);
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedNavIndex) return;

    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog(index);
      return;
    }

    _navigateToScreen(index);
  }

  void _navigateToScreen(int index) {
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

  Future<void> _showUnsavedChangesDialog(int targetIndex) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'You have unsaved changes. Would you like to save your draft before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save Draft'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _saveDraft();
    }

    if (mounted) {
      _navigateToScreen(targetIndex);
    }
  }

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _coverImagePath = image.path;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveDraft() async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Please add a title to save your story');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Simulate saving with a delay
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _hasUnsavedChanges = false;
        _isSaving = false;
      });
      _showSnackBar('Draft saved successfully');
    } catch (e) {
      setState(() => _isSaving = false);
      _showSnackBar('Failed to save draft: ${e.toString()}');
    }
  }

  Future<void> _publishStory() async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Please add a title to publish your story');
      return;
    }

    if (_writingController.text.isEmpty) {
      _showSnackBar('Please add some content to publish your story');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Simulate publishing with a delay
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _hasUnsavedChanges = false;
        _isSaving = false;
      });
      _showSnackBar('Story published successfully');
    } catch (e) {
      setState(() => _isSaving = false);
      _showSnackBar('Failed to publish: ${e.toString()}');
    }
  }

  void _previewStory() {
    if (_titleController.text.isEmpty || _writingController.text.isEmpty) {
      _showSnackBar('Add title and content to preview your story');
      return;
    }

    // Show preview dialog or navigate to preview screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _titleController.text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (_coverImagePath != null)
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('Cover Image Preview')),
              ),
            if (_descriptionController.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _descriptionController.text,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _writingController.text,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int? maxLines,
    TextInputAction? textInputAction,
    bool? expands,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 15, vertical: maxLines != null ? 5 : 0),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        cursorColor: AppColors.primary,
        maxLines: maxLines,
        expands: expands ?? false,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCoverImageSelector() {
    return GestureDetector(
      onTap: _pickCoverImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _coverImagePath != null
              ? Colors.transparent
              : AppColors.containerBackground,
          borderRadius: BorderRadius.circular(12),
          image: _coverImagePath != null
              ? DecorationImage(
                  image: FileImage(File(_coverImagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _coverImagePath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.tint,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tint.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add Cover Image',
                    style: TextStyle(
                      color: AppColors.tint,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Recommended size: 800x400',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, color: AppColors.tint, size: 16),
                  ),
                  onPressed: _pickCoverImage,
                ),
              ),
      ),
    );
  }

  Widget _buildGenreSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _genreController,
          hint: 'Fiction, Fantasy, Adventure...',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularGenres.map((genre) {
            return GestureDetector(
              onTap: () {
                if (_genreController.text.isEmpty) {
                  _genreController.text = genre;
                } else if (!_genreController.text.contains(genre)) {
                  _genreController.text = '${_genreController.text}, $genre';
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.tint.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.tint.withOpacity(0.3)),
                ),
                child: Text(
                  genre,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.tint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWritingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Writing Tools',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.text_format, size: 20),
                  onPressed: () {}, // Text formatting
                  tooltip: 'Format text',
                ),
                IconButton(
                  icon: const Icon(Icons.mic, size: 20),
                  onPressed: () {}, // Voice dictation
                  tooltip: 'Voice dictation',
                ),
                IconButton(
                  icon: const Icon(Icons.text_fields, size: 20),
                  onPressed: () {}, // AI assistance
                  tooltip: 'AI writing assistance',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 300,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(
                color: AppColors.textGrey.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: TextField(
            controller: _writingController,
            cursorColor: AppColors.primary,
            maxLines: null,
            expands: true,
            style: const TextStyle(fontSize: 16, height: 1.6),
            decoration: const InputDecoration(
              hintText: 'Tap to start writing or dictating your story...',
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${_writingController.text.split(' ').where((w) => w.isNotEmpty).length} words',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomButton(
            text: 'Preview',
            icon: Icons.visibility_outlined,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            borderColor: AppColors.border,
            onPressed: _previewStory,
          ),
          CustomButton(
            text: 'Save Draft',
            icon: Icons.save_outlined,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            borderColor: AppColors.border,
            isLoading: _isSaving,
            onPressed: _saveDraft,
          ),
          CustomButton(
            text: 'Publish',
            icon: Icons.publish_outlined,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            onPressed: _publishStory,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          _showUnsavedChangesDialog(0); // 0 is home screen
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create New Story',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      if (_isSaving)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Saving...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      else if (_hasUnsavedChanges)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Unsaved changes',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Story Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableStoryTypes.length,
                      itemBuilder: (context, index) {
                        final type = _availableStoryTypes[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: StoryTypeOption(
                            text: type,
                            isSelected: _selectedStoryType == type,
                            onTap: () =>
                                setState(() => _selectedStoryType = type),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Story Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _titleController,
                    hint: 'Enter your story title...',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 15),
                  _buildCoverImageSelector(),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _descriptionController,
                    hint: 'Write a short description...',
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 15),
                  _buildGenreSelector(),
                  const SizedBox(height: 25),
                  _buildWritingSection(),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedNavIndex,
          onItemTapped: _onNavItemTapped,
        ),
      ),
    );
  }
}
