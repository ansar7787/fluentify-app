import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../../domain/models/speaking_challenge.dart';
import 'speaking_game_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../../user/presentation/bloc/user_state.dart';

class SpeakingLevelsPage extends StatefulWidget {
  const SpeakingLevelsPage({super.key});

  @override
  State<SpeakingLevelsPage> createState() => _SpeakingLevelsPageState();
}

class _SpeakingLevelsPageState extends State<SpeakingLevelsPage> {
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
        _highestUnlockedLevel = state.user.speakingLevel;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _highestUnlockedLevel = prefs.getInt('speaking_highest_level') ?? 1;
      });
    }
  }

  Future<void> _updateProgress(int completedLevel) async {
    if (completedLevel >= _highestUnlockedLevel) {
      final newLevel = completedLevel + 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('speaking_highest_level', newLevel);

      if (mounted) {
        context
            .read<UserBloc>()
            .add(UpdateUserProfileEvent(speakingLevel: newLevel));
      }

      setState(() {
        _highestUnlockedLevel = newLevel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final levels = SpeakingLevel.getLevels();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050505) : Colors.white,
      body: Stack(
        children: [
          _buildNeonBackground(isDark),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isDark),
                Expanded(
                  child: ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      final isUnlocked = level.level <= _highestUnlockedLevel;
                      final isCurrent = level.level == _highestUnlockedLevel;
                      return _buildStageCard(
                          level, isUnlocked, isCurrent, isDark);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Icon(Icons.close_rounded,
                  color: const Color(0xFF10B981), size: 24.w),
            ),
          ),
          Text(
            'Fluency Flow',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 1.5,
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50.w,
                height: 50.w,
                child: CircularProgressIndicator(
                  value: _highestUnlockedLevel / 100,
                  strokeWidth: 4,
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                ),
              ),
              Text(
                '$_highestUnlockedLevel',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard(
      SpeakingLevel level, bool isUnlocked, bool isCurrent, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpeakingGamePage(level: level),
              ),
            ).then((_) => _updateProgress(level.level));
          }
        },
        child: Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: isUnlocked
                ? (isCurrent
                    ? const Color(0xFF10B981)
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.white))
                : (isDark
                    ? Colors.white.withValues(alpha: 0.02)
                    : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: isCurrent
                  ? Colors.white24
                  : (isUnlocked
                      ? const Color(0xFF10B981).withOpacity(0.2)
                      : Colors.transparent),
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.r),
            child: Stack(
              children: [
                if (isUnlocked && !isCurrent)
                  Positioned(
                    right: -20.w,
                    bottom: -20.h,
                    child: Icon(Icons.mic_none_rounded,
                        size: 100.w,
                        color: const Color(0xFF10B981).withOpacity(0.05)),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? Colors.white.withOpacity(0.2)
                              : (isUnlocked
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : Colors.transparent),
                        ),
                        child: Center(
                          child: isUnlocked
                              ? (isCurrent
                                  ? Icon(Icons.play_arrow_rounded,
                                      color: Colors.white, size: 30.w)
                                  : Icon(Icons.mic_rounded,
                                      color: const Color(0xFF10B981),
                                      size: 24.w))
                              : Icon(Icons.lock_rounded,
                                  color:
                                      isDark ? Colors.white12 : Colors.black12,
                                  size: 24.w),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STAGE ${level.level}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? Colors.white70
                                    : (isUnlocked
                                        ? const Color(0xFF10B981)
                                        : Colors.grey.withOpacity(0.5)),
                              ),
                            ),
                            Text(
                              level.level > 70
                                  ? 'Advanced Fluency'
                                  : (level.level > 30
                                      ? 'Skill Talk'
                                      : 'Intro Mastery'),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? Colors.white
                                    : (isUnlocked
                                        ? (isDark
                                            ? Colors.white
                                            : Colors.black87)
                                        : Colors.grey.withOpacity(0.3)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isUnlocked && !isCurrent)
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: const Color(0xFF10B981), size: 16.w),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: level.level % 10 * 60))
        .scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildNeonBackground(bool isDark) {
    if (!isDark) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned(
          top: 200.h,
          left: -100.w,
          child: Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.05),
                    blurRadius: 150,
                    spreadRadius: 50)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
