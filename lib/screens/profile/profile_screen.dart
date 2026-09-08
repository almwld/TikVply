import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../models/user/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          final stats = authProvider.userStats;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 260,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBg
                    : Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(user, stats),
                ),
                title: user != null
                    ? Text('@${user.username}',
                        style: const TextStyle(fontWeight: FontWeight.bold))
                    : null,
                actions: [
                  IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showSettingsSheet(context),
                  ),
                ],
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.dark,
                    indicatorWeight: 2,
                    labelColor: AppColors.dark,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.bookmark_outline)),
                      Tab(icon: Icon(Icons.favorite_border)),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVideoGrid(),
                    _buildSavedGrid(),
                    _buildLikedGrid(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user, stats) {
    return Container(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: ClipOval(
              child: user?.avatarUrl != null
                  ? Image.network(user!.avatarUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar())
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user?.fullName ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (user?.isVerified == true) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: AppColors.primary, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 4),
          if (user?.bio != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(user!.bio!, textAlign: TextAlign.center, maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(stats.followingCount.toString(), 'Following'),
                _buildStatItem(stats.followersCount.toString(), 'Followers'),
                _buildStatItem(stats.likesCount.toString(), 'Likes'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() => Container(color: AppColors.primary, child: const Icon(Icons.person, color: Colors.white, size: 50));

  Widget _buildStatItem(String count, String label) => Column(
    children: [
      Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
    ],
  );

  Widget _buildVideoGrid() => Consumer<VideoProvider>(
    builder: (context, videoProvider, child) => GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 9 / 16,
      ),
      itemCount: videoProvider.videos.length,
      itemBuilder: (context, index) {
        final video = videoProvider.videos[index];
        return GestureDetector(
          onTap: () => videoProvider.setCurrentIndex(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              video.thumbnailUrl != null
                  ? Image.network(video.thumbnailUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
              Positioned(
                left: 6, bottom: 6,
                child: Row(children: [
                  const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                  const SizedBox(width: 2),
                  Text(video.formatViews(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                ]),
              ),
            ],
          ),
        );
      },
    ),
  );

  Widget _placeholder() => Container(color: AppColors.primary.withValues(alpha: 0.3), child: const Icon(Icons.play_arrow, color: Colors.white, size: 40));

  Widget _buildSavedGrid() => const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.bookmark_border, size: 64, color: Colors.grey), SizedBox(height: 16),
    Text('No saved videos yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
  ]));

  Widget _buildLikedGrid() => const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.favorite_border, size: 64, color: Colors.grey), SizedBox(height: 16),
    Text('Videos you liked will appear here', style: TextStyle(fontSize: 16, color: Colors.grey)),
  ]));

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Privacy'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.qr_code), title: const Text('QR Code'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.bookmark_border), title: const Text('Saved'), onTap: () => Navigator.pop(context)),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(context); }),
        ]),
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('User Profile')), body: Center(child: Text('Profile for user: $userId')));
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);
  @override double get minExtent => tabBar.preferredSize.height;
  @override double get maxExtent => tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(
    color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBg : Colors.white,
    child: tabBar,
  );
  @override bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
