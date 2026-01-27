import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'game_levels_page.dart'; // We will reuse or refactor this

class GameHomePage extends StatelessWidget {
  const GameHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final games = [
      _GameItem(
        title: 'Sentence Master',
        description: 'Unscramble words to build correct sentences.',
        icon: Icons.text_fields_rounded,
        color: const Color(0xFFF59E0B), // Amber
        route: 'scramble',
      ),
      _GameItem(
        title: 'Word Match',
        description: 'Match synonyms and antonyms.',
        icon: Icons.compare_arrows_rounded,
        color: const Color(0xFFEC4899), // Pink
        route: 'word_match',
      ),
      _GameItem(
        title: 'Speed Typer',
        description: 'Type fast before the time runs out!',
        icon: Icons.keyboard_rounded,
        color: const Color(0xFF3B82F6), // Blue
        route: 'typing',
      ),
      _GameItem(
        title: 'Dictation Master',
        description: 'Listen and write what you hear.',
        icon: Icons.headset_mic_rounded,
        color: const Color(0xFF10B981), // Emerald
        route: 'dictation',
      ),
      _GameItem(
        title: 'Reading Quest',
        description: 'Read passages and answer questions.',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF8B5CF6), // Violet
        route: 'reading',
      ),
      _GameItem(
        title: 'Rapid Fire',
        description: 'Speak answers quickly!',
        icon: Icons.timer_rounded,
        color: const Color(0xFFEF4444), // Red
        route: 'rapid_fire',
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Arcade',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28.sp,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4)
                ])),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
                ? [
                    const Color(0xFF0F172A), // Slate 900
                    const Color(0xFF1E1B4B), // Indigo 950
                  ]
                : [
                    const Color(0xFFEEF2FF), // Indigo 50
                    const Color(0xFFE0E7FF), // Indigo 100
                  ],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundOnes(isDark),
            SafeArea(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                itemCount: games.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildGameCard(context, games[index], index, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
      BuildContext context, _GameItem game, int index, bool isDark) {
    return GestureDetector(
      onTap: () {
        // Navigate to levels page, passing the game type
        // For now, we reuse GameLevelsPage but pass arguments or update it to handle generic modes
        // Since GameLevelsPage is currently hardcoded for Scramble, we need to refactor it.
        // For this step, I will point to GameLevelsPage and assume we will refactor it next.
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GameLevelsPage(gameMode: game.route)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        height: 140.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: game.color.withValues(alpha: 0.3),
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
                    color: game.color.withValues(alpha: 0.1),
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
                        color: game.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: game.color.withValues(alpha: 0.3)),
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
                  color: Colors.blue.withValues(alpha: 0.05),
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
  final String route;

  _GameItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
