import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../../peer/presentation/pages/matching_page.dart';

// Game Pages
import '../../../game/presentation/pages/grammar_levels_page.dart';
import '../../../game/presentation/pages/speaking_levels_page.dart';
import '../../../game/presentation/pages/word_match_levels_page.dart';
import '../../../game/presentation/pages/typing_levels_page.dart';
import '../../../game/presentation/pages/dictation_levels_page.dart';
import '../../../game/presentation/pages/rapid_fire_levels_page.dart';
import '../../../streak/presentation/pages/streak_page.dart';
import '../../../../config/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetUserProfileEvent());
    Future.delayed(const Duration(milliseconds: 800), () {
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
            backgroundColor: Color(0xFFF1F5F9), // Slate 100
            body: Center(
                child: CircularProgressIndicator(color: AppTheme.accentBlue)),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // Slate 50
          extendBody: true, // Important for floating nav bar
          body: Stack(
            children: [
              // 1. Background Elements
              Positioned(
                top: -150,
                right: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.2),
                        const Color(0xFF3B82F6).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Main Scrollable Content
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildModernAppBar(context, firstName, avatarUrl),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 10),

                        // Hero Section (Stats)
                        _buildHeroStats(context, streak, coins, level)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 32),

                        // Section Title
                        _buildSectionHeader("Start Learning", "Pick a mode"),
                        const SizedBox(height: 16),

                        // Game Grid (Bento Style)
                        _buildBentoGrid(context)
                            .animate()
                            .fadeIn(delay: 200.ms),

                        const SizedBox(height: 32),

                        // Daily Challenge Promo
                        _buildDailyChallengeCard(context)
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .scale(),

                        const SizedBox(
                            height: 120), // Bottom padding for floating nav
                      ]),
                    ),
                  ),
                ],
              ),

              // 3. Floating Navigation Dock
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: _buildFloatingDock(context),
              ).animate().slideY(
                  begin: 1,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOutQuart),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernAppBar(
      BuildContext context, String name, String? avatarUrl) {
    return SliverAppBar(
      expandedHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $name",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "Ready to master English?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.accentBlue.withValues(alpha: 0.3),
                    width: 2),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.accentBlue.withValues(alpha: 0.1),
                backgroundImage: avatarUrl != null
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: const TextStyle(
                            color: AppTheme.accentBlue,
                            fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStats(
      BuildContext context, int streak, int coins, String level) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatPill(
            context,
            icon: Icons.local_fire_department_rounded,
            value: "$streak",
            label: "Streak",
            color: const Color(0xFFF97316),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const StreakPage())),
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatPill(
            context,
            icon: Icons.monetization_on_rounded,
            value: "$coins",
            label: "Credits",
            color: const Color(0xFFF59E0B),
            onTap: () {},
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatPill(
            context,
            icon: Icons.star_rounded,
            value: level,
            label: "Level",
            color: const Color(0xFF3B82F6),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(BuildContext context,
      {required IconData icon,
      required String value,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        // IconButton(
        //   onPressed: () {},
        //   icon: Icon(Icons.arrow_forward_rounded, color: AppTheme.accentBlue),
        // )
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    // A simplified Bento Grid implementation using Column + Rows
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 6,
              child: _buildBigGameCard(
                context,
                title: 'Grammar',
                subtitle: 'Master rules',
                icon: Icons.text_fields_rounded,
                color: const Color(0xFF8B5CF6),
                page: const GrammarLevelsPage(),
                height: 180,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildSmallGameCard(
                    context,
                    title: 'Speed Typer',
                    icon: Icons.keyboard_rounded,
                    color: const Color(0xFFEC4899),
                    page: const TypingLevelsPage(),
                  ),
                  const SizedBox(height: 16),
                  _buildSmallGameCard(
                    context,
                    title: 'Word Match',
                    icon: Icons.extension_rounded,
                    color: const Color(0xFF10B981),
                    page: const WordMatchLevelsPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmallGameCard(
                context,
                title: 'Speaking',
                icon: Icons.mic_rounded,
                color: const Color(0xFF3B82F6),
                page: const SpeakingLevelsPage(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSmallGameCard(
                context,
                title: 'Diction',
                icon: Icons.headphones_rounded,
                color: const Color(0xFFF59E0B),
                page: const DictationLevelsPage(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWideGameCard(
          context,
          title: 'Rapid Fire Quiz',
          subtitle: 'Think fast, answer faster!',
          icon: Icons.timer_rounded,
          color: const Color(0xFFEF4444),
          page: const RapidFireLevelsPage(),
        ),
      ],
    );
  }

  Widget _buildBigGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
    required double height,
  }) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSmallGameCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 16,
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: AssetImage(
              'assets/images/pattern.png'), // Fallback if missing? pattern.png is common.
          opacity: 0.05,
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('DAILY MISSION',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white54, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          const Text('The Great Debate',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Learn how to politely disagree in English.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.5)),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: 0.4,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Text('40% Completed',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFloatingDock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9), // Glassmorphism base
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 0,
            spreadRadius: 0,
          ) // Inner glow hack not needed with high logic
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDockItem(0, Icons.home_rounded, 'Home', () {}),
              _buildDockItem(1, Icons.people_rounded, 'Peers', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MatchingPage()));
              }),
              _buildDockItem(2, Icons.leaderboard_rounded, 'Rank', () {
                Navigator.pushNamed(context, '/leaderboard');
              }),
              _buildDockItem(3, Icons.person_rounded, 'Profile', () {
                Navigator.pushNamed(context, '/profile');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(
      int index, IconData icon, String label, VoidCallback onTap) {
    final isSelected = _navIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _navIndex = index);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accentBlue : Colors.grey[400],
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ).animate().fadeIn().slideX(),
            ]
          ],
        ),
      ),
    );
  }
}
