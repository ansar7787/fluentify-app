import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch top 100
    context.read<LeaderboardBloc>().add(const GetLeaderboardEvent(limit: 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, lbState) {
          if (lbState is LeaderboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (lbState is LeaderboardLoaded) {
            final rankings = lbState.rankings;
            final userRank = lbState.userRank;

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    if (rankings.isNotEmpty)
                      SliverToBoxAdapter(child: _buildPodium(rankings)),
                    if (rankings.length > 3)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 16, 16, 100), // Bottom padding for pinned user
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final user = rankings[index + 3];
                              return _buildLeaderboardTile(index + 4, user);
                            },
                            childCount: rankings.length - 3,
                          ),
                        ),
                      )
                    else if (rankings.isEmpty)
                      const SliverFillRemaining(
                        child: Center(child: Text("No researchers found yet!")),
                      ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildPinnedUser(userRank),
                ),
              ],
            );
          } else if (lbState is LeaderboardError) {
            return Center(child: Text('Error: ${lbState.message}'));
          }
          return const Center(child: SizedBox());
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: const Color(0xFF2563EB),
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<UserEntity> rankings) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (rankings.length >= 2) _buildPodiumItem(rankings[1], 2),
          if (rankings.length >= 1) _buildPodiumItem(rankings[0], 1),
          if (rankings.length >= 3) _buildPodiumItem(rankings[2], 3),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(UserEntity user, int rank) {
    final bool isFirst = rank == 1;
    final double avatarSize = isFirst ? 50 : 35;
    final double heightOffset = isFirst ? 20 : 0;
    final Color color = rank == 1
        ? const Color(0xFFFFD700)
        : (rank == 2 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child:
                  Icon(Icons.workspace_premium, color: Colors.amber, size: 32)),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)
                ],
              ),
              child: CircleAvatar(
                radius: avatarSize,
                backgroundImage: CachedNetworkImageProvider(
                  user.profileImage ??
                      'https://ui-avatars.com/api/?name=${user.fullName}&background=random',
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16 + heightOffset),
        Text(
          user.fullName.split(' ')[0], // First name
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: isFirst ? 16 : 14),
        ),
        const SizedBox(height: 4),
        Text(
          '${user.coins} 🪙',
          style: TextStyle(
              color: Colors.amber[700],
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(int rank, UserEntity user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(
              user.profileImage ??
                  'https://ui-avatars.com/api/?name=${user.fullName}&background=random',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Level ${user.level} • ${user.streakCount} 🔥',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text('${user.coins} 🪙',
                style: TextStyle(
                    color: Colors.amber[800], fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedUser(int rank) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoaded) {
          final user = state.user;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Text(
                    rank > 0 ? '#$rank' : '-', // - if 0 (not found/error)
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user.profileImage != null
                        ? CachedNetworkImageProvider(user.profileImage!)
                        : null,
                    child: user.profileImage == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('You',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${user.coins} Coins',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${user.streakCount} Streak 🔥',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
