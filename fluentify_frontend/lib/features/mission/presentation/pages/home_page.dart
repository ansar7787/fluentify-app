import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import '../../../game/presentation/pages/word_match_levels_page.dart';
import '../../../game/presentation/pages/typing_levels_page.dart';
import '../../../game/presentation/pages/dictation_levels_page.dart';
import '../../../game/presentation/pages/reading_levels_page.dart';
import '../../../game/presentation/pages/rapid_fire_levels_page.dart';
import '../../../game/presentation/pages/game_levels_page.dart'; // 8th Game
import '../../../streak/presentation/pages/streak_page.dart'; // Import StreakPage
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../domain/entities/mission_entity.dart'; // Actually needed for MissionDetailPage if used
import 'mission_detail_page.dart'; // Actually needed

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
          extendBodyBehindAppBar: true,
          backgroundColor: const Color(0xFFF8FAFC),
          bottomNavigationBar: _buildBottomNav(context),
          body: Stack(
            children: [
              // Background Gradient
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
                    ),
                  ),
                ),
              ),
              // Decorative Blobs
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.2),
                        blurRadius: 50,
                      )
                    ],
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.2, 1.2),
                        duration: 4.seconds),
              ),

              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context, firstName, avatarUrl),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildStatsRow(context, streak, coins, level)
                            .animate()
                            .fadeIn()
                            .slideY(begin: 0.2, curve: Curves.easeOutBack),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Arcade Arena', () {}),
                        const SizedBox(height: 16),
                        _buildGameCarousel(context)
                            .animate()
                            .fadeIn(delay: 200.ms),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Daily Missions', () {}),
                        const SizedBox(height: 16),
                        _buildMissionItem(
                          context,
                          "Self Introduction",
                          "Master the art of introducing yourself.",
                          Icons.mic_rounded,
                          const Color(0xFF3B82F6),
                          10,
                          false,
                        ).animate().fadeIn(delay: 300.ms).slideX(),
                        const SizedBox(height: 16),
                        _buildMissionItem(
                          context,
                          "Business Negotiation",
                          "Learn key phrases for making deals.",
                          Icons.business_center_rounded,
                          const Color(0xFF8B5CF6),
                          20,
                          true,
                        ).animate().fadeIn(delay: 400.ms).slideX(),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Explore More', () {}),
                        const SizedBox(height: 16),
                        _buildPromoCard(context)
                            .animate()
                            .fadeIn(delay: 500.ms)
                            .scale(),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
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
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              alignment: Alignment.bottomLeft,
              child: Text("Hello, $name 👋",
                  style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: avatarUrl != null
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: avatarUrl == null
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold))
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
      BuildContext context, int streak, int coins, String level) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, 'Streak', '$streak Days',
              Icons.local_fire_department_rounded, const Color(0xFFF97316), () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const StreakPage()));
          }),
          Container(width: 1, height: 30, color: Colors.grey[200]),
          _buildStatItem(context, 'Credits', '$coins',
              Icons.monetization_on_rounded, const Color(0xFFF59E0B), () {}),
          Container(width: 1, height: 30, color: Colors.grey[200]),
          _buildStatItem(context, 'Level', level, Icons.verified_rounded,
              const Color(0xFF3B82F6), () {}),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String val,
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(val,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E293B))),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildGameCarousel(BuildContext context) {
    final games = [
      {
        'title': 'Word Match',
        'desc': 'Connect pairs',
        'color': const Color(0xFF8B5CF6),
        'icon': Icons.extension_rounded,
        'page': const WordMatchLevelsPage()
      },
      {
        'title': 'Speed Typer',
        'desc': 'Race time',
        'color': const Color(0xFFEC4899),
        'icon': Icons.keyboard_rounded,
        'page': const TypingLevelsPage()
      },
      {
        'title': 'Diction',
        'desc': 'Hear & type',
        'color': const Color(0xFF10B981),
        'icon': Icons.headphones_rounded,
        'page': const DictationLevelsPage()
      },
      {
        'title': 'Reading',
        'desc': 'Comprehend',
        'color': const Color(0xFFF59E0B),
        'icon': Icons.menu_book_rounded,
        'page': const ReadingLevelsPage()
      },
      {
        'title': 'Rapid Fire',
        'desc': 'Quick quiz',
        'color': const Color(0xFFEF4444),
        'icon': Icons.timer_rounded,
        'page': const RapidFireLevelsPage()
      },
      {
        'title': 'Grammar',
        'desc': 'Rules logic',
        'color': Colors.purple,
        'icon': Icons.text_fields_rounded,
        'page': const GrammarLevelsPage()
      },
      {
        'title': 'Speaking',
        'desc': 'Fluency',
        'color': Colors.teal,
        'icon': Icons.mic_rounded,
        'page': const SpeakingLevelsPage()
      },
      {
        'title': 'Scramble',
        'desc': 'Build sentences',
        'color': Colors.indigo,
        'icon': Icons.sort_by_alpha_rounded,
        'page': const GameLevelsPage(gameMode: 'scramble') // 8th Game
      },
    ];

    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 4),
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
              width: 170,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (game['color'] as Color).withValues(alpha: 0.9),
                    (game['color'] as Color)
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: (game['color'] as Color).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      game['icon'] as IconData,
                      size: 100,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16)),
                        child: Icon(game['icon'] as IconData,
                            color: Colors.white, size: 28),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(game['title'] as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          const SizedBox(height: 6),
                          Text(game['desc'] as String,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13)),
                        ],
                      )
                    ],
                  ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          if (isLocked)
            const Icon(Icons.lock_rounded, color: Colors.grey, size: 20)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFEDD5))),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_rounded,
                      size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('+$reward',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 12)),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1E293B).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(8)),
            child: const Text('TOURNAMENT',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          const Text('Weekly Challenges',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Compete with others and win exclusive badges.',
              style:
                  TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Join Now',
                style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    // Use standard BottomNavigationBar wrapped in container for styling
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -5))
      ]),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: GNav(
            gap: 8,
            activeColor: const Color(0xFF2563EB),
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: const Color(0xFFEFF6FF),
            color: Colors.grey[400],
            tabs: [
              GButton(
                icon: Icons.home_rounded,
                text: 'Home',
                onPressed: () {},
              ),
              GButton(
                icon: Icons.people_rounded,
                text: 'Peers',
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MatchingPage()));
                },
              ),
              GButton(
                icon: Icons.leaderboard_rounded,
                text: 'Rank',
                onPressed: () {
                  Navigator.pushNamed(context, '/leaderboard');
                },
              ),
              GButton(
                icon: Icons.person_rounded,
                text: 'Profile',
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple implementation of Google Nav Bar (GNav) style button since we can't easily add packages
class GButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool active;

  const GButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.onPressed,
      this.active = false});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder for GButton logic, usually handled by a package like google_nav_bar.
    // Since I can't guarantee the package is installed, I will revert to standard navigation
    // but styled nicely in the main class.
    return const SizedBox.shrink();
  }
}

class GNav extends StatefulWidget {
  final List<GButton> tabs;
  final Color? activeColor;
  final Color? color;
  final Color? tabBackgroundColor;
  final double gap;
  final EdgeInsetsGeometry padding;
  final Duration duration;
  final double iconSize;

  const GNav(
      {super.key,
      required this.tabs,
      this.activeColor,
      this.color,
      this.tabBackgroundColor,
      required this.gap,
      required this.padding,
      required this.duration,
      required this.iconSize});

  @override
  State<GNav> createState() => _GNavState();
}

class _GNavState extends State<GNav> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.tabs.length, (index) {
        final tab = widget.tabs[index];
        final isActive = _selectedIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedIndex = index);
            tab.onPressed();
          },
          child: AnimatedContainer(
            duration: widget.duration,
            padding: widget.padding,
            decoration: BoxDecoration(
                color:
                    isActive ? widget.tabBackgroundColor : Colors.transparent,
                borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Icon(tab.icon,
                    color: isActive ? widget.activeColor : widget.color,
                    size: widget.iconSize),
                if (isActive) ...[
                  SizedBox(width: widget.gap),
                  Text(tab.text,
                      style: TextStyle(
                          color: widget.activeColor,
                          fontWeight: FontWeight.bold))
                ]
              ],
            ),
          ),
        );
      }),
    );
  }
}
