import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<LeaderboardBloc>().add(const GetLeaderboardEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Leaderboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LeaderboardLoaded) {
            final rankings = state.rankings;
            if (rankings.isEmpty) {
              return const Center(child: Text('No rankings yet'));
            }
            return Column(
              children: [
                _buildPodium(rankings),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: rankings.length > 3 ? rankings.length - 3 : 0,
                    itemBuilder: (context, index) {
                      final user = rankings[index + 3];
                      return _buildLeaderboardTile(index + 4, user);
                    },
                  ),
                ),
              ],
            );
          } else if (state is LeaderboardError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildPodium(rankings) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (rankings.length >= 2) _buildPodiumItem(rankings[1], 2, 100),
          if (rankings.length >= 1) _buildPodiumItem(rankings[0], 1, 140),
          if (rankings.length >= 3) _buildPodiumItem(rankings[2], 3, 90),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(user, int rank, double height) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: rank == 1
                      ? Colors.amber
                      : (rank == 2 ? Colors.grey[400]! : Colors.brown[300]!),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 40 : 32,
                backgroundImage: NetworkImage(
                  user.profileImage ??
                      'https://ui-avatars.com/api/?name=${user.fullName}&background=random',
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: rank == 1
                      ? Colors.amber
                      : (rank == 2 ? Colors.grey[400] : Colors.brown[300]),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.fullName.split(' ')[0],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          '${user.coins} ★',
          style: TextStyle(
              color: Colors.amber[800],
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(int rank, user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              rank.toString(),
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
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
                Text('Level: ${user.level}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.coins} coins',
                style: const TextStyle(
                    color: Color(0xFF2D62ED), fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.red, size: 14),
                  Text('${user.streakCount}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
