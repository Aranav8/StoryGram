import 'package:collabwrite/core/constants/assets.dart';
import 'package:collabwrite/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../home/home_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/story_type_option.dart';

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

  void _onNavItemTapped(int index) {
    if (index == _selectedNavIndex) return;

    final screens = [
      const HomeScreen(),
      const CreateScreen(),
    ];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screens[index]),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        cursorColor: Colors.black,
        maxLines: null,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Saving...',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text('Story Type',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['Single Story', 'Chapter-based'].map((type) {
                    return StoryTypeOption(
                      text: type,
                      isSelected: _selectedStoryType == type,
                      onTap: () => setState(() => _selectedStoryType = type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                const Text('Story Details',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _buildTextField(
                    controller: _titleController,
                    hint: 'Enter your story title...'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.containerBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: AppColors.tint),
                          child: SvgPicture.asset(AppAssets.add,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text('Add Cover Image',
                            style:
                                TextStyle(color: AppColors.tint, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                    controller: _descriptionController,
                    hint: 'Write a short description...'),
                const SizedBox(height: 10),
                _buildTextField(
                    controller: _genreController,
                    hint: 'Fiction, Fantasy, Adventure...'),
                const SizedBox(height: 22),
                const Text('Writing Tools',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textGrey, width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _writingController,
                    cursorColor: Colors.black,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText:
                          'Tap to start writing or dictating your story...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 45,
                        width: 115,
                        decoration: BoxDecoration(
                          color: AppColors.containerBackground,
                          border: Border.all(
                            color: AppColors.border,
                            width: .5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Preview',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Container(
                        height: 45,
                        width: 115,
                        decoration: BoxDecoration(
                          color: AppColors.containerBackground,
                          border: Border.all(
                            color: AppColors.border,
                            width: .5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Save Draft',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Container(
                        height: 45,
                        width: 115,
                        decoration: BoxDecoration(
                          color: AppColors.containerBackground,
                          border: Border.all(
                            color: AppColors.border,
                            width: .5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Publish',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onItemTapped: _onNavItemTapped,
      ),
    );
  }
}
