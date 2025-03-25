// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// class Home extends StatefulWidget {
//   const Home({super.key});
//
//   @override
//   State<Home> createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//   List<String> filters = ["+", "Trending", "Genres", "Collaboration"];
//   int selectedFilter = 1;
//
//   void selectedFilterIndex(int index) {
//     setState(() {
//       selectedFilter = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               height: 665,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF030507),
//               ),
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 25,
//                         ),
//                         SizedBox(width: 10),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   'Hello!',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                                 SizedBox(width: 5),
//                                 SvgPicture.asset(
//                                     'assets/icons/waving_hand.svg'),
//                               ],
//                             ),
//                             SizedBox(height: 2),
//                             Text(
//                               'Aranav Kumar',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 16),
//                             ),
//                           ],
//                         ),
//                         Spacer(),
//                         SvgPicture.asset('assets/icons/notification.svg'),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 18),
//                       child: Container(
//                         height: 45,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF1C1E1F),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 10),
//                               child:
//                                   SvgPicture.asset('assets/icons/search.svg'),
//                             ),
//                             Text(
//                               'Find stories, writers, or inspiration...',
//                               style: TextStyle(color: Color(0xFF56585A)),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     _BuildFilters(
//                       filterNames: filters,
//                       selectedFilter: selectedFilter,
//                       onFilterSelected: selectedFilterIndex,
//                     ),
//                     SizedBox(height: 30),
//                     Text(
//                       'Explore Featured Stories',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.w700),
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       'A collection of must-read stories.',
//                       style: TextStyle(
//                           color: Color(0xFF56585A),
//                           fontWeight: FontWeight.w500),
//                     ),
//                     SizedBox(
//                       height: 340,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: 10,
//                         itemBuilder: (context, index) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 10),
//                             child: StoryCard(),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _BuildFilters extends StatelessWidget {
//   _BuildFilters({
//     super.key,
//     required this.filterNames,
//     required this.selectedFilter,
//     required this.onFilterSelected,
//   });
//
//   final List<String> filterNames;
//   final int selectedFilter;
//   final Function(int) onFilterSelected;
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 35,
//       child: ListView.builder(
//           itemCount: filterNames.length,
//           scrollDirection: Axis.horizontal,
//           itemBuilder: (context, index) {
//             bool isSelected = selectedFilter == index;
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 5),
//               child: IntrinsicWidth(
//                 child: GestureDetector(
//                   onTap: () => onFilterSelected(index),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 25),
//                     decoration: BoxDecoration(
//                         color: isSelected
//                             ? const Color(0xFFF05119)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: !isSelected
//                               ? const Color(0xFF56585A)
//                               : Colors.transparent,
//                         )),
//                     child: Center(
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             filterNames[index],
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                           if (index == 2)
//                             Padding(
//                               padding: const EdgeInsets.only(left: 5),
//                               child: SvgPicture.asset(
//                                   'assets/icons/down_arrow.svg',
//                                   height: 16),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }),
//     );
//   }
// }
//
// class StoryCard extends StatelessWidget {
//   const StoryCard({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 170,
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.asset(
//                 'assets/images/example.png',
//                 width: double.infinity,
//                 height: 120,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Echoes Tomorrow: A Sci-Fi Mystery',
//               style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 5),
//             Text(
//               'When a scientist discovers hidden messages from the future...',
//               style: TextStyle(color: Colors.white, fontSize: 12),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Text(
//                   '1.8K Likes',
//                   style: TextStyle(color: Color(0xFF56585A), fontSize: 12),
//                 ),
//                 SizedBox(width: 8),
//                 Container(
//                   height: 6,
//                   width: 6,
//                   decoration: BoxDecoration(
//                     color: Color(0xFF56585A),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   '3.7K Views',
//                   style: TextStyle(color: Color(0xFF56585A), fontSize: 12),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Row(
//               children: [
//                 CircleAvatar(radius: 15),
//                 SizedBox(width: 5),
//                 Text(
//                   'Nathen Wells',
//                   style: TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.w400),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
