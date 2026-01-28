import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'grammar_levels_page.dart';
import 'speaking_levels_page.dart';
import 'word_match_levels_page.dart';
import 'typing_levels_page.dart';
import 'dictation_levels_page.dart';
import 'reading_levels_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/user/presentation/bloc/user_bloc.dart';
import '../../../../features/user/presentation/bloc/user_state.dart';
import '../../../../features/user/presentation/bloc/leaderboard_bloc.dart';
import '../../../../features/user/presentation/bloc/leaderboard_event.dart';
import '../../../../features/user/presentation/bloc/leaderboard_state.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import 'rapid_fire_levels_page.dart';
import 'game_levels_page.dart';

class GameHomePage extends StatefulWidget {
  const GameHomePage({super.key});

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // For glassmorphism effect on nav bar if we want
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Arcade Arena'
              : (_selectedIndex == 1 ? 'Your Stats' : 'Leaderboard'),
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24.sp,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4)
              ]),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundOnes(isDark),
            SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildGameList(isDark),
                  _buildStatsTab(isDark),
                  _buildLeaderboardTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87)),
          indicatorColor: const Color(0xFF8B5CF6).withOpacity(0.2),
          iconTheme: MaterialStateProperty.all(IconThemeData(size: 24.sp)),
        ),
        child: NavigationBar(
          height: 70.h,
          elevation: 0,
          backgroundColor: isDark
              ? const Color(0xFF0F172A).withOpacity(0.8)
              : Colors.white.withOpacity(0.8),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
            if (index == 2) {
              context.read<LeaderboardBloc>().add(GetLeaderboardEvent());
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.games_outlined),
              selectedIcon: Icon(Icons.games_rounded, color: Color(0xFF8B5CF6)),
              label: 'Play',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded),
              selectedIcon:
                  Icon(Icons.bar_chart_rounded, color: Color(0xFF8B5CF6)),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon:
                  Icon(Icons.emoji_events_rounded, color: Color(0xFF8B5CF6)),
              label: 'Rank',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameList(bool isDark) {
    final games = [
      _GameItem(
        title: 'Word Match',
        description: 'Match synonyms and antonyms.',
        icon: Icons.extension_rounded,
        color: const Color(0xFF8B5CF6), // Violet
        page: const WordMatchLevelsPage(),
      ),
      _GameItem(
        title: 'Speed Typer',
        description: 'Type fast before the time runs out!',
        icon: Icons.keyboard_rounded,
        color: const Color(0xFFEC4899), // Pink
        page: const TypingLevelsPage(),
      ),
      _GameItem(
        title: 'Diction Master',
        description: 'Listen and write what you hear.',
        icon: Icons.record_voice_over_rounded,
        color: const Color(0xFF10B981), // Emerald
        page: const DictationLevelsPage(),
      ),
      _GameItem(
        title: 'Reading Quest',
        description: 'Read passages and answer questions.',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFF59E0B), // Amber
        page: const ReadingLevelsPage(),
      ),
      _GameItem(
        title: 'Rapid Fire',
        description: 'Think fast, answer faster!',
        icon: Icons.timer_rounded,
        color: const Color(0xFFEF4444), // Red
        page: const RapidFireLevelsPage(),
      ),
      _GameItem(
        title: 'Grammar Quest',
        description: 'Master grammar rules.',
        icon: Icons.text_fields_rounded,
        color: Colors.purple,
        page: const GrammarLevelsPage(),
      ),
      _GameItem(
        title: 'Fluency Flow',
        description: 'Practice speaking confidently.',
        icon: Icons.mic_rounded,
        color: Colors.teal,
        page: const SpeakingLevelsPage(),
      ),
      _GameItem(
        title: 'Sentence Master',
        description: 'Unscramble words to build sentences.',
        icon: Icons.sort_by_alpha_rounded,
        color: Colors.indigo,
        page: const GameLevelsPage(gameMode: 'scramble'),
      ),
    ];

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
      itemCount: games.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return _buildGameCard(context, games[index], index, isDark);
      },
    );
  }

  Widget _buildStatsTab(bool isDark) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoaded) {
          final user = state.user;
          return ListView(
            padding: EdgeInsets.fromLTRB(20.w, 100.h, 20.w, 100.h),
            children: [
              _buildStatCard(
                "Total Coins",
                "${user.coins}",
                Icons.monetization_on_rounded,
                Colors.amber,
                isDark,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Word Match",
                      "Lvl ${user.gameLevel}",
                      Icons.extension_rounded,
                      const Color(0xFF8B5CF6),
                      isDark,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      "Grammar",
                      "Lvl ${user.grammarLevel}",
                      Icons.text_fields_rounded,
                      Colors.purple,
                      isDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Speaking",
                      "Lvl ${user.speakingLevel}",
                      Icons.mic_rounded,
                      Colors.teal,
                      isDark,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      "Missions",
                      "${user.missionsCompleted}",
                      Icons.task_alt_rounded,
                      Colors.blue,
                      isDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                    color:
                        isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        color: Colors.orange, size: 32.w),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Current Streak",
                            style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 14.sp)),
                        Text("${user.streakCount} Days",
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2),
            ],
          );
        } else if (state is UserLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Center(
              child: Text("Could not load stats",
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)));
        }
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.w),
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildLeaderboardTab(bool isDark) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LeaderboardLoaded) {
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 120.h, 20.w, 100.h),
            itemCount: state.rankings.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final user = state.rankings[index];
              return _buildLeaderboardItem(user, index + 1, isDark);
            },
          );
        } else if (state is LeaderboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.w, color: Colors.red),
                SizedBox(height: 16.h),
                Text(state.message,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black)),
                TextButton(
                  onPressed: () => context
                      .read<LeaderboardBloc>()
                      .add(GetLeaderboardEvent()),
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildLeaderboardItem(UserEntity user, int rank, bool isDark) {
    Color rankColor;
    if (rank == 1)
      rankColor = Colors.amber;
    else if (rank == 2)
      rankColor = Colors.grey.shade400;
    else if (rank == 3)
      rankColor = Colors.brown.shade400;
    else
      rankColor = isDark ? Colors.white30 : Colors.black26;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: rank <= 3 ? rankColor.withOpacity(0.5) : Colors.transparent,
          )),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  rank <= 3 ? rankColor.withOpacity(0.1) : Colors.transparent,
            ),
            child: Text(
              "#$rank",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: rankColor,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            backgroundImage: user.profileImage != null
                ? NetworkImage(user.profileImage!)
                : null,
            child: user.profileImage == null
                ? Text(user.fullName.isNotEmpty
                    ? user.fullName[0].toUpperCase()
                    : "?")
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: isDark ? Colors.white : Colors.black87),
                ),
                Text(
                  "${user.gameLevel + user.grammarLevel + user.speakingLevel} Levels",
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white54 : Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on_rounded,
                    size: 16.w, color: Colors.amber),
                SizedBox(width: 4.w),
                Text(
                  "${user.coins}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildGameCard(
      BuildContext context, _GameItem game, int index, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => game.page),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        height: 140.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: game.color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -5,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              // Decorative Circle
              Positioned(
                right: -30.w,
                top: -30.h,
                child: Container(
                  width: 150.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    color: game.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: game.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: game.color.withOpacity(0.3)),
                      ),
                      child: Icon(game.icon, color: game.color, size: 32.w),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            game.title,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            game.description,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .slideY(
              begin: 0.2,
              end: 0,
              delay: Duration(milliseconds: index * 100),
              duration: 500.ms,
              curve: Curves.easeOutBack)
          .fadeIn(delay: Duration(milliseconds: index * 100)),
    );
  }

  Widget _buildBackgroundOnes(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: 100.h,
          left: -50.w,
          child: Container(
            width: 200.w,
            height: 200.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.05),
                  blurRadius: 50,
                  spreadRadius: 20,
                )
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: 30, duration: 5.seconds),
        )
      ],
    );
  }
}

class _GameItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget page;

  _GameItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.page,
  });
}
