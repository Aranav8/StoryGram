import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/assets.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../create/create_screen.dart';
import '../library/library_screen.dart';
import '../profile/profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/filter_widget.dart';
import '../widgets/story_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedNavIndex = 0;

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
      create: (_) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 10),
                            _buildSearchBar(),
                            FilterWidget(
                              filterNames: viewModel.filters,
                              selectedFilter: viewModel.selectedFilter,
                              onFilterSelected: viewModel.selectFilter,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Explore Featured Stories',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'A collection of must-read stories.',
                              style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 300,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: viewModel.stories.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: StoryCard(
                                        story: viewModel.stories[index]),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Personalized for You',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Stories tailored to your interests and reading habits.',
                            style: TextStyle(
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 15),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: viewModel.stories.length,
                            itemBuilder: (context, index) {
                              return StoryCard(
                                story: viewModel.stories[index],
                                isGridItem: true,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(radius: 25),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Hello!', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 5),
                SvgPicture.asset(AppAssets.wavingHand),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Aranav Kumar',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
          ],
        ),
        const Spacer(),
        SvgPicture.asset(AppAssets.notification),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SvgPicture.asset(AppAssets.search),
            ),
            const Text(
              'Find stories, writers, or inspiration...',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
