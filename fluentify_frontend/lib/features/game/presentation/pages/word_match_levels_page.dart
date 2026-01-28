import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/word_match_level_entity.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../games/word_match_game_page.dart';

class WordMatchLevelsPage extends StatefulWidget {
  const WordMatchLevelsPage({super.key});

  @override
  State<WordMatchLevelsPage> createState() => _WordMatchLevelsPageState();
}

class _WordMatchLevelsPageState extends State<WordMatchLevelsPage> {
  int _highestUnlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final state = context.read<UserBloc>().state;
    if (state is UserLoaded) {
      // Assuming user entity has 'wordMatchLevel' or similar, else fallback to prefs
      // Since I can't check User entity right now, I'll use prefs primarily for this demo
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _highestUnlockedLevel = prefs.getInt('word_match_highest_level') ?? 1;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _highestUnlockedLevel = prefs.getInt('word_match_highest_level') ?? 1;
      });
    }
  }

  Future<void> _updateProgress(int completedLevel) async {
    if (completedLevel >= _highestUnlockedLevel) {
      final newLevel = completedLevel + 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('word_match_highest_level', newLevel);

      // context.read<UserBloc>().add(UpdateUserProfileEvent(wordMatchLevel: newLevel));
      // Uncomment if User entity supports it

      setState(() {
        _highestUnlockedLevel = newLevel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF8B5CF6); // Violet

    return BlocProvider(
      create: (context) => getIt<GameBloc>()..add(GetWordMatchLevelsEvent()),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            _buildBackground(isDark, primaryColor),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, isDark, primaryColor),
                  _buildProgressHeader(isDark, primaryColor),
                  Expanded(
                    child: BlocBuilder<GameBloc, GameState>(
                      builder: (context, state) {
                        if (state is GameLoading) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor));
                        } else if (state is WordMatchLevelsLoaded) {
                          return _buildLevelsList(
                              state.levels, isDark, primaryColor);
                        } else if (state is GameError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelsList(
      List<WordMatchLevelEntity> levels, bool isDark, Color color) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.8,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final isUnlocked = level.level <= _highestUnlockedLevel;
        final isCurrent = level.level == _highestUnlockedLevel;
        return _buildLevelCard(level, isUnlocked, isCurrent, isDark, color)
            .animate()
            .scale(delay: Duration(milliseconds: index % 10 * 50));
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87),
          ),
          Text(
            'Word Match',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.extension_rounded, color: color),
          )
        ],
      ),
    );
  }

  Widget _buildProgressHeader(bool isDark, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Level',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                '$_highestUnlockedLevel',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Target: 100',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLevelCard(WordMatchLevelEntity level, bool isUnlocked,
      bool isCurrent, bool isDark, Color color) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordMatchGamePage(
                level: level,
                onLevelComplete: () => _updateProgress(level.level),
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isCurrent ? color : (isDark ? Colors.white12 : Colors.white))
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: isUnlocked && !isCurrent
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
          border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(Icons.lock_rounded, color: Colors.grey[400], size: 24.w)
            else if (isCurrent)
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32.w)
            else
              Text(
                '${level.level}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(bool isDark, Color color) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Icon(Icons.extension, size: 300, color: color),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Icon(Icons.extension_off, size: 300, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
