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
    final double imageHeight = isGridItem ? 100 : 120;
    final double titleSize = isGridItem ? 14 : 16;
    final double authorSize = isGridItem ? 12 : 14;
    final double descriptionSize = isGridItem ? 10 : 12;
    final double statsSize = 11;

    return Container(
      width: isGridItem ? null : 200,
      margin: isGridItem ? EdgeInsets.zero : const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              height: imageHeight,
              width: double.infinity,
              color: AppColors.textGrey.withOpacity(0.2),
              child: story.coverImage != null && story.coverImage!.isNotEmpty
                  ? Image.asset(
                      story.coverImage!,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppColors.textGrey,
                            size: imageHeight * 0.4,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textGrey,
                        size: imageHeight * 0.4,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
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
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: isGridItem ? 3 : 5),
                Text(
                  story.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: authorSize,
                  ),
                ),
                SizedBox(height: isGridItem ? 3 : 5),
                if (story.description != null && story.description!.isNotEmpty)
                  Text(
                    story.description ?? '',
                    maxLines: isGridItem ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: descriptionSize,
                      height: 1.3,
                    ),
                  ),
                SizedBox(height: isGridItem ? 5 : 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildStatIcon(
                      Icons.favorite,
                      Colors.red,
                      story.likes,
                      statsSize,
                    ),
                    const SizedBox(width: 15),
                    _buildStatIcon(
                      Icons.visibility,
                      Colors.blueAccent,
                      story.views,
                      statsSize,
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

  Widget _buildStatIcon(
      IconData icon, Color color, int value, double textSize) {
    return Row(
      children: [
        Icon(icon, color: color, size: textSize + 3),
        const SizedBox(width: 4),
        Text(
          _formatCount(value),
          style: TextStyle(color: Colors.white, fontSize: textSize),
        ),
      ],
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
}
