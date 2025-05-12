import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:collabwrite/data/models/story_model.dart';
import 'package:collabwrite/viewmodel/story_reader_viewmodel.dart';
import 'package:collabwrite/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:collabwrite/data/models/user_model.dart' as app_user;
import 'package:share_plus/share_plus.dart';

class StoryReaderScreen extends StatelessWidget {
  final Story story;

  const StoryReaderScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryReaderViewModel(story: story),
      child: Consumer<StoryReaderViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _buildStoryContent(context, viewModel),
            bottomNavigationBar: viewModel.isLoading
                ? null
                : _buildBottomActionBar(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildStoryContent(
      BuildContext context, StoryReaderViewModel viewModel) {
    final story = viewModel.story;
    final author = viewModel.author;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          floating: false,
          pinned: true,
          stretch: true,
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            title: Text(
              story.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            background: story.coverImage != null && story.coverImage!.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        story.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: AppColors.secondary),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(color: AppColors.secondary),
          ),
          actions: [
            IconButton(
              icon: Icon(
                viewModel.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
              ),
              tooltip: viewModel.isSaved ? 'Remove Bookmark' : 'Bookmark',
              onPressed: () => viewModel.toggleSaveStory(),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              tooltip: 'More options',
              onPressed: () {/* TODO: Implement more options */},
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorSection(context, author, viewModel),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(Icons.thumb_up_alt_outlined,
                        "${viewModel.likesCount} Likes"),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.visibility_outlined,
                        "${viewModel.viewsCount} Views"),
                    const Spacer(),
                    if (story.publishedDate != null)
                      Text(
                        'Published: ${DateFormat.yMMMd().format(story.publishedDate!)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (story.genres.isNotEmpty)
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: story.genres
                        .map((genre) => Chip(
                              label: Text(genre,
                                  style: const TextStyle(fontSize: 11)),
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                const Divider(height: 30, thickness: 0.8),
                MarkdownBody(
                  data: viewModel.storyContent,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                        fontSize: 17, height: 1.65, color: Color(0xFF333333)),
                    h2: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.background,
                        height: 1.8,
                        letterSpacing: -0.5),
                    code: const TextStyle(
                        backgroundColor: AppColors.containerBackground,
                        fontFamily: "monospace"),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorSection(BuildContext context, app_user.User? author,
      StoryReaderViewModel viewModel) {
    if (author == null) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage:
              author.profileImage != null && author.profileImage!.isNotEmpty
                  ? NetworkImage(author.profileImage!)
                  : null,
          child: author.profileImage == null || author.profileImage!.isEmpty
              ? Text(author.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 20))
              : null,
          backgroundColor: AppColors.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.name,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background),
              ),
              Text(
                author.bio.isNotEmpty ? author.bio : 'Storyteller',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () => viewModel.toggleFollowAuthor(),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                viewModel.isFollowingAuthor ? Colors.white : AppColors.primary,
            backgroundColor: viewModel.isFollowingAuthor
                ? AppColors.primary
                : Colors.transparent,
            side: BorderSide(color: AppColors.primary.withOpacity(0.7)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            textStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(viewModel.isFollowingAuthor ? 'Following' : 'Follow'),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12.5, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildBottomActionBar(
      BuildContext context, StoryReaderViewModel viewModel) {
    return Material(
      elevation: 8.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarTheme.color ??
              Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _actionButton(
              context,
              icon: viewModel.isLiked
                  ? Icons.thumb_up_alt_rounded
                  : Icons.thumb_up_alt_outlined,
              label: '${viewModel.likesCount}',
              color: viewModel.isLiked ? AppColors.primary : Colors.grey[700],
              onPressed: () => viewModel.toggleLike(),
            ),
            _actionButton(
              context,
              icon: Icons.comment_outlined,
              label: 'Comment',
              color: Colors.grey[700],
              onPressed: () {/* TODO: Implement comment functionality */},
            ),
            _actionButton(
              context,
              icon: Icons.share_outlined,
              label: 'Share',
              color: Colors.grey[700],
              onPressed: () {
                final String shareText =
                    'Check out this story: "${viewModel.story.title}" by ${viewModel.story.authorName}!\n${viewModel.story.description ?? ""}\n#CollabWriteApp';
                Share.share(shareText,
                    subject: 'Story: ${viewModel.story.title}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context,
      {required IconData icon,
      required String label,
      Color? color,
      VoidCallback? onPressed}) {
    return TextButton.icon(
      icon: Icon(icon,
          color: color ?? Theme.of(context).iconTheme.color, size: 20),
      label: Text(label,
          style: TextStyle(
              color: color ?? Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 13)),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
