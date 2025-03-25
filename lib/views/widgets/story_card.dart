import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/story_model.dart';

class StoryCard extends StatelessWidget {
  final Story story;
  final bool isGridItem;

  const StoryCard({
    super.key,
    required this.story,
    this.isGridItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isGridItem ? null : 200,
      margin: isGridItem ? EdgeInsets.zero : const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            child: Image.asset(
              story.image,
              height: isGridItem ? 100 : 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: isGridItem
                ? const EdgeInsets.fromLTRB(8, 8, 8, 0)
                : const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  story.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isGridItem ? 14 : 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: isGridItem ? 2 : 4),
                Text(
                  story.author,
                  style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: isGridItem ? 12 : 14),
                ),
                SizedBox(height: isGridItem ? 2 : 4),
                Text(
                  story.description,
                  maxLines: isGridItem ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: isGridItem ? 10 : 12),
                ),
                SizedBox(height: isGridItem ? 4 : 8),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite,
                              color: Colors.red, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${story.likes}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.visibility,
                              color: Colors.blueAccent, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${story.views}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
