import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/mission_entity.dart';
import 'mission_detail_page.dart';
import '../../../peer/presentation/pages/matching_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../../user/presentation/bloc/user_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../game/presentation/pages/game_home_page.dart';
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
    context.read<UserBloc>().add(GetUserProfileEvent());
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        String firstName = 'Learner';
        int streak = 0;
        int coins = 0;
        String level = 'A1';
        String? avatarUrl;

        if (state is UserLoaded) {
          firstName = state.user.fullName.split(' ')[0];
          streak = state.user.streakCount;
          coins = state.user.coins;
          level = state.user.level;
          avatarUrl = state.user.profileImage;
        } else {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            firstName = authState.user.fullName.split(' ')[0];
            avatarUrl = authState.user.profileImage;
          }
        }

        if (_isLoading || state is UserLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // Slate 50
          bottomNavigationBar: _buildBottomNav(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, firstName, avatarUrl),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStatsRow(streak, coins, level),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Arcade Arena', () {}),
                    const SizedBox(height: 16),
                    _buildGameCarousel(context),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Daily Missions', () {}),
                    const SizedBox(height: 16),
                    _buildMissionItem(
                      context,
                      "Self Introduction",
                      "Master the art of introducing yourself.",
                      Icons.mic_rounded,
                      Colors.blue,
                      10,
                      false,
                    ),
                    const SizedBox(height: 16),
                    _buildMissionItem(
                      context,
                      "Business Negotiation",
                      "Learn key phrases for making deals.",
                      Icons.business_center_rounded,
                      Colors.purple,
                      20,
                      true,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Explore More', () {}),
                    const SizedBox(height: 16),
                    _buildPromoCard(context),
                    const SizedBox(height: 100), // Spacing for fab/bottom nav
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, String name, String? avatarUrl) {
    return SliverAppBar(
      expandedHeight: 140,
      backgroundColor: const Color(0xFF2563EB), // Best Blue
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Welcome back,",
                        style:
                            TextStyle(color: Colors.blue[100], fontSize: 14)),
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            backgroundImage: avatarUrl != null
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int streak, int coins, String level) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Streak', '$streak Days',
              Icons.local_fire_department_rounded, Colors.orange),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem(
              'Credits', '$coins', Icons.monetization_on_rounded, Colors.amber),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem('Level', level, Icons.verified_rounded, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String val, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(val,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1E293B))),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A))),
        // GestureDetector(
        //   onTap: onTap,
        //   child: const Text('See All', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
        // ),
      ],
    );
  }

  Widget _buildGameCarousel(BuildContext context) {
    final games = [
      {
        'title': 'Arcade Arena',
        'desc': 'Play mini-games',
        'color': Colors.indigo,
        'icon': Icons.games,
        'page': const GameHomePage()
      },
      {
        'title': 'Grammar Quest',
        'desc': 'Master rules',
        'color': Colors.purple,
        'icon': Icons.text_fields,
        'page': const GrammarLevelsPage()
      },
      {
        'title': 'Fluency Flow',
        'desc': 'Speak confidently',
        'color': Colors.teal,
        'icon': Icons.mic,
        'page': const SpeakingLevelsPage()
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final game = games[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => game['page'] as Widget));
            },
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (game['color'] as Color).withOpacity(0.8),
                    (game['color'] as Color)
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: (game['color'] as Color).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(game['icon'] as IconData, color: Colors.white),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(game['title'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(game['desc'] as String,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMissionItem(BuildContext context, String title, String subtitle,
      IconData icon, Color color, int reward, bool isLocked) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MissionDetailPage(
              mission: MissionEntity(
                id: 'mission_${title.hashCode}',
                title: title,
                description: subtitle,
                level: isLocked ? 'Intermediate' : 'Beginner',
                coins: reward,
                content:
                    'Mission content for $title. Practice your skills here.',
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B))),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock_rounded, color: Colors.grey)
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('+$reward',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            fontSize: 12)),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
              'https://img.freepik.com/free-vector/gradient-technological-background_23-2148884155.jpg'), // Placeholder or asset
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(8)),
            child: const Text('NEW',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          const Text('Join the Tournament',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Compete with others and win exclusive badges.',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Register Now'),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey[400],
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 1)
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MatchingPage()));
          else if (index == 2)
            Navigator.pushNamed(context, '/leaderboard');
          else if (index == 3) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded), label: 'Peers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_rounded), label: 'Rank'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
