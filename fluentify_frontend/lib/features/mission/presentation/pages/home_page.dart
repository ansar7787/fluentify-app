import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/mission_entity.dart';
import 'mission_detail_page.dart';
import '../../../peer/presentation/pages/matching_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../../user/presentation/bloc/user_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../game/presentation/pages/game_levels_page.dart';
import '../../../game/presentation/pages/grammar_levels_page.dart';
import '../../../game/presentation/pages/speaking_levels_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch fresh user data
    context.read<UserBloc>().add(GetUserProfileEvent());

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluentify'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                String? avatarUrl;
                if (state is UserLoaded) {
                  avatarUrl = state.user.profileImage;
                } else {
                  // Fallback to AuthBloc if UserBloc not ready
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    avatarUrl = authState.user.profileImage;
                  }
                }

                return CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: avatarUrl != null
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (_isLoading || state is UserLoading) {
            return _buildSkeleton(context);
          }

          String firstName = 'Learner';
          int streak = 0;
          int coins = 0;
          String level = 'A1';

          if (state is UserLoaded) {
            firstName = state.user.fullName.split(' ')[0];
            streak = state.user.streakCount;
            coins = state.user.coins;
            level = state.user.level;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(context, firstName, streak),
                const SizedBox(height: 32),
                _buildStatsGrid(context, coins, "1.2k", level),
                const SizedBox(height: 32),
                _buildSectionHeader('English Games', () {}),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildGameCard(
                        context,
                        'Sentence Scramble',
                        'Master syntax by reordering words!',
                        [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                        Icons.extension,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GameLevelsPage()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildGameCard(
                        context,
                        'Grammar Quest',
                        'Choose the correct verb forms & rules!',
                        [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
                        Icons.g_translate,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GrammarLevelsPage()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildGameCard(
                        context,
                        'Fluency Flow',
                        'Speak and get real-time AI feedback!',
                        [const Color(0xFF10B981), const Color(0xFF047857)],
                        Icons.record_voice_over,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SpeakingLevelsPage()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('Daily Missions', () {}),
                const SizedBox(height: 16),
                _buildMissionCard(
                  context,
                  'Self Introduction',
                  'Master the art of introducing yourself in interviews.',
                  'Beginner',
                  10,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildMissionCard(
                  context,
                  'Conflict Resolution',
                  'Learn how to handle disagreements with coworkers.',
                  'Intermediate',
                  25,
                  Colors.orange,
                  isPremium: true,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('Recommended for You', () {}),
                const SizedBox(height: 16),
                _buildTrackCard(
                  context,
                  'Tech Interview Pro',
                  '12 Missions • 4 Tracks',
                  '85% Learners achieved B2 level',
                  Icons.code,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MatchingPage()),
            );
          } else if (index == 2) {
            Navigator.pushNamed(context, '/leaderboard');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Practice'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Peers'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card Skeleton
          AppShimmer.rect(
              width: double.infinity, height: 200, borderRadius: 24),
          const SizedBox(height: 32),
          // Stats Skeleton
          Row(
            children: [
              Expanded(
                  child: AppShimmer.rect(
                      width: double.infinity, height: 100, borderRadius: 20)),
              const SizedBox(width: 16),
              Expanded(
                  child: AppShimmer.rect(
                      width: double.infinity, height: 100, borderRadius: 20)),
              const SizedBox(width: 16),
              Expanded(
                  child: AppShimmer.rect(
                      width: double.infinity, height: 100, borderRadius: 20)),
            ],
          ),
          const SizedBox(height: 32),
          // Header Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmer.rect(width: 150, height: 24, borderRadius: 4),
              AppShimmer.rect(width: 60, height: 20, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          // Mission Card Skeletons
          AppShimmer.rect(
              width: double.infinity, height: 120, borderRadius: 20),
          const SizedBox(height: 16),
          AppShimmer.rect(
              width: double.infinity, height: 120, borderRadius: 20),
          const SizedBox(height: 32),
          // Header Skeleton 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmer.rect(width: 200, height: 24, borderRadius: 4),
              AppShimmer.rect(width: 60, height: 20, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          // Track Card Skeleton
          AppShimmer.rect(
              width: double.infinity, height: 180, borderRadius: 24),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String name, int streak) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D62ED), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keep it up, $name! 🔥',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'You are on a $streak-day streak.',
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/subscription'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2D62ED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Go Premium'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2D62ED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start Practice'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
      BuildContext context, int coins, String words, String level) {
    return Row(
      children: [
        _buildStatItem(coins.toString(), 'Coins earned',
            Icons.monetization_on_outlined, Colors.amber),
        const SizedBox(width: 16),
        _buildStatItem(
            words, 'Words spoken', Icons.forum_outlined, Colors.teal),
        const SizedBox(width: 16),
        _buildStatItem(level, 'Curr. Level', Icons.auto_graph, Colors.blue),
      ],
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(val,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }

  Widget _buildMissionCard(
    BuildContext context,
    String title,
    String desc,
    String level,
    int coins,
    Color color, {
    bool isPremium = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MissionDetailPage(
              mission: MissionEntity(
                id: isPremium ? 'premium_1' : 'free_1',
                title: title,
                description: desc,
                level: level,
                coins: coins,
                content: title == 'Self Introduction'
                    ? 'Introduce yourself to a prospective employer. Focus on your background, skills, and why you are a good fit for the role.'
                    : 'A coworker is pushing back on a deadline. Construct a response that is professional yet assertive.',
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Icon(isPremium ? Icons.workspace_premium : Icons.mic_none,
                  color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text('PRO',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(desc,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackCard(BuildContext context, String title, String stats,
      String promo, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Text(stats, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Text(promo,
                style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    String subtitle,
    List<Color> colors,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors[1], size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
