import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../models/post_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_bottom_navbar.dart';
import '../../widgets/header_action_buttons.dart';
import 'create_post_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final CommunityService _communityService = CommunityService();

  @override
  void initState() {
    super.initState();
    // Silently trigger a cleanup of expired posts when entering this page
    _communityService.deleteExpiredPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 20.0,
        title: const Text('Community', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: const [
          HeaderActionButtons(),
          SizedBox(width: 20),
        ],
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _communityService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'No posts yet. Be the first to share an idea!',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
              final isLiked = post.likes.contains(currentUserId);
              final isOwner = currentUserId == post.userId;

              return PostCard(
                post: post,
                currentUserId: currentUserId,
                communityService: _communityService,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostPage()),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}

class PostCard extends StatefulWidget {
  final PostModel post;
  final String? currentUserId;
  final CommunityService communityService;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.communityService,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.likes.contains(widget.currentUserId);
    final isOwner = widget.currentUserId == widget.post.userId;
    // Check if description is long enough to need a "See more" button
    final bool isLongDescription = widget.post.description.length > 100;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: const Icon(Icons.person, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTime(widget.post.timestamp),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      widget.communityService.deletePost(
                        widget.post.id,
                        imageUrl: widget.post.imageUrl,
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              widget.post.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            if (widget.post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.post.imageUrl!.startsWith('http')
                    ? Image.network(
                        widget.post.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        height: 250,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      )
                    : Image.memory(
                        base64Decode(widget.post.imageUrl!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        height: 250,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      ),
              ),
            ],

            const SizedBox(height: 12),

            // Description
            Text(
              widget.post.description,
              maxLines: _isExpanded ? null : 3,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),

            // "See more" / "See less" Button
            if (isLongDescription)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _isExpanded ? "See less" : "See more",
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            // Footer (Likes & Share)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  label: Text(
                    '${widget.post.likes.length}',
                    style: TextStyle(color: isLiked ? Colors.red : Colors.grey),
                  ),
                  onPressed: () {
                    widget.communityService.toggleLike(
                      widget.post.id,
                      widget.post.likes,
                    );
                  },
                ),
                Text(
                  'Share your ideas',
                  style: TextStyle(color: Colors.green[300], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
