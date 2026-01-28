import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/grammar_level_entity.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../../user/presentation/bloc/user_state.dart';
import 'grammar_game_page.dart';

class GrammarLevelsPage extends StatefulWidget {
  const GrammarLevelsPage({super.key});

  @override
  State<GrammarLevelsPage> createState() => _GrammarLevelsPageState();
}

class _GrammarLevelsPageState extends State<GrammarLevelsPage> {
  int _highestUnlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final state = context.read<UserBloc>().state;
    if (state is UserLoaded) {
      setState(() {
        _highestUnlockedLevel = state.user.grammarLevel;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _highestUnlockedLevel = prefs.getInt('grammar_highest_level') ?? 1;
      });
    }
  }

  Future<void> _updateProgress(int completedLevel) async {
    if (completedLevel >= _highestUnlockedLevel) {
      final newLevel = completedLevel + 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('grammar_highest_level', newLevel);

      if (mounted) {
        context
            .read<UserBloc>()
            .add(UpdateUserProfileEvent(grammarLevel: newLevel));
      }

      setState(() {
        _highestUnlockedLevel = newLevel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => getIt<GameBloc>()..add(GetGrammarLevelsEvent()),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            _buildCircuitBackground(isDark),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, isDark),
                  _buildProgressHeader(isDark),
                  Expanded(
                    child: BlocBuilder<GameBloc, GameState>(
                      builder: (context, state) {
                        if (state is GameLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is GrammarLevelsLoaded) {
                          return _buildLevelsList(state.levels, isDark);
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

  Widget _buildLevelsList(List<GrammarLevelEntity> levels, bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      physics: const BouncingScrollPhysics(),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final isUnlocked = level.level <= _highestUnlockedLevel;
        final isCurrent = level.level == _highestUnlockedLevel;
        return _buildLevelNode(
            level, isUnlocked, isCurrent, isDark, index == levels.length - 1);
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
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
            'Grammar Quest',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
            color:
                isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            value: _highestUnlockedLevel / 100,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
            strokeWidth: 8,
          ),
          SizedBox(width: 20.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mastery Level',
                style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                '$_highestUnlockedLevel / 100',
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelNode(GrammarLevelEntity level, bool isUnlocked,
      bool isCurrent, bool isDark, bool isLast) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (isUnlocked) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GrammarGamePage(
                    level: level,
                    onLevelComplete: () => _updateProgress(level.level),
                  ),
                ),
              );
            }
          },
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? (isCurrent
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF8B5CF6).withValues(alpha: 0.2))
                      : (isDark ? Colors.white10 : Colors.black12),
                  border: Border.all(
                    color: isCurrent
                        ? Colors.white
                        : (isUnlocked
                            ? const Color(0xFF8B5CF6)
                            : Colors.transparent),
                    width: isCurrent ? 3 : 1,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.5),
                              blurRadius: 15,
                              spreadRadius: 2)
                        ]
                      : null,
                ),
                child: Center(
                  child: isUnlocked
                      ? (isCurrent
                          ? Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 30.w)
                          : Icon(Icons.check_rounded,
                              color: const Color(0xFF8B5CF6), size: 24.w))
                      : Icon(Icons.lock_rounded,
                          color: isDark ? Colors.white24 : Colors.black26,
                          size: 20.w),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                    border: isCurrent
                        ? Border.all(
                            color:
                                const Color(0xFF8B5CF6).withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEVEL ${level.level}',
                        style: TextStyle(
                          color: isUnlocked
                              ? const Color(0xFF8B5CF6)
                              : (isDark ? Colors.white24 : Colors.black26),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        level.title, // Use title from entity
                        style: TextStyle(
                          color: isUnlocked
                              ? (isDark ? Colors.white : Colors.black87)
                              : (isDark ? Colors.white10 : Colors.black12),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            height: 40.h,
            width: 2,
            margin: EdgeInsets.only(left: 29.w),
            color: isUnlocked
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                : (isDark ? Colors.white10 : Colors.black12),
          ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: level.level % 10 * 50))
        .slideX(begin: -0.1);
  }

  Widget _buildCircuitBackground(bool isDark) {
    return Opacity(
      opacity: isDark ? 0.3 : 0.05,
      child: Stack(
        children: [
          Positioned(
            top: 100.h,
            right: -50.w,
            child: Icon(Icons.hub_outlined,
                size: 300.w, color: const Color(0xFF8B5CF6)),
          ),
          Positioned(
            bottom: 50.h,
            left: -100.w,
            child: Icon(Icons.memory_rounded,
                size: 400.w, color: const Color(0xFF8B5CF6)),
          ),
        ],
      ),
    );
  }
}
