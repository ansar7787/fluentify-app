import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/scramble_level_entity.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../games/word_match_game_page.dart';
import '../games/typing_game_page.dart';
import '../games/dictation_game_page.dart';
import '../games/reading_game_page.dart';
import '../games/rapid_fire_game_page.dart';
import '../../domain/entities/word_match_level_entity.dart';
import '../../domain/entities/typing_level_entity.dart';
import '../../domain/entities/dictation_level_entity.dart';
import '../../domain/entities/reading_level_entity.dart';
import '../../domain/entities/rapid_fire_level_entity.dart';
import 'game_page.dart';

class GameLevelsPage extends StatefulWidget {
  final String
      gameMode; // 'scramble', 'word_match', 'typing', 'dictation', 'reading', 'rapid_fire'

  const GameLevelsPage({super.key, required this.gameMode});

  @override
  State<GameLevelsPage> createState() => _GameLevelsPageState();
}

class _GameLevelsPageState extends State<GameLevelsPage> {
  int _highestUnlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final state = context.read<UserBloc>().state;
    // Note: ideally we should have separate progress per game mode in User entity
    // For now, we share 'gameLevel' for simplicity or use specific keys in SharedPreferences
    // Assume shared level for MVP or use generic key
    if (state is UserLoaded) {
      setState(() {
        _highestUnlockedLevel = state.user.gameLevel;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _highestUnlockedLevel =
            prefs.getInt('game_highest_level_${widget.gameMode}') ?? 1;
      });
    }
  }

  Future<void> _updateProgress(int completedLevel) async {
    if (completedLevel >= _highestUnlockedLevel) {
      final newLevel = completedLevel + 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('game_highest_level_${widget.gameMode}', newLevel);

      if (mounted) {
        // Only update central user level if this is the main game or aggregate
        context
            .read<UserBloc>()
            .add(UpdateUserProfileEvent(gameLevel: newLevel));
      }

      setState(() {
        _highestUnlockedLevel = newLevel;
      });
    }
  }

  String _getTitle() {
    switch (widget.gameMode) {
      case 'word_match':
        return 'Word Match';
      case 'typing':
        return 'Speed Typer';
      case 'dictation':
        return 'Dictation Master';
      case 'reading':
        return 'Reading Quest';
      case 'rapid_fire':
        return 'Rapid Fire';
      default:
        return 'Sentence Master';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) {
        final bloc = getIt<GameBloc>();
        switch (widget.gameMode) {
          case 'word_match':
            bloc.add(GetWordMatchLevelsEvent());
            break;
          case 'typing':
            bloc.add(GetTypingLevelsEvent());
            break;
          case 'dictation':
            bloc.add(GetDictationLevelsEvent());
            break;
          case 'reading':
            bloc.add(GetReadingLevelsEvent());
            break;
          case 'rapid_fire':
            bloc.add(GetRapidFireLevelsEvent());
            break;
          default:
            bloc.add(GetScrambleLevelsEvent());
        }
        return bloc;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(_getTitle(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
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
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
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
                      const Color(0xFF1E1B4B), // Deep Indigo
                      const Color(0xFF4C1D95), // Deep Violet
                      const Color(0xFF0F172A), // Slate
                    ]
                  : [
                      const Color(0xFF4F46E5), // Indigo 600
                      const Color(0xFF818CF8), // Indigo 400
                      const Color(0xFFE0E7FF), // Indigo 50
                    ],
            ),
          ),
          child: Stack(
            children: [
              _buildBackgroundAuroras(isDark),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    Expanded(
                      child: BlocBuilder<GameBloc, GameState>(
                        builder: (context, state) {
                          List<dynamic> levels = [];

                          if (state is GameLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (state is ScrambleLevelsLoaded) {
                            levels = state.levels;
                          } else if (state is WordMatchLevelsLoaded) {
                            levels = state.levels;
                          } else if (state is TypingLevelsLoaded) {
                            levels = state.levels;
                          } else if (state is DictationLevelsLoaded) {
                            levels = state.levels;
                          } else if (state is ReadingLevelsLoaded) {
                            levels = state.levels;
                          } else if (state is RapidFireLevelsLoaded) {
                            levels = state.levels;
                          } else if (state is GameError) {
                            return Center(
                                child: Text(state.message,
                                    style:
                                        const TextStyle(color: Colors.white)));
                          }

                          if (levels.isEmpty) return const SizedBox.shrink();

                          return GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding:
                                EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 20.w,
                              mainAxisSpacing: 24.h,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: levels.length,
                            itemBuilder: (context, index) {
                              final level = levels[index];
                              final isUnlocked = index < _highestUnlockedLevel;
                              final isCurrent =
                                  (index + 1) == _highestUnlockedLevel;
                              return _buildLevelCard(
                                  level, isUnlocked, isCurrent, isDark);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 20.h),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Level',
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Unlocked: $_highestUnlockedLevel/100',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryYellow.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]),
              child: Icon(Icons.emoji_events_rounded,
                  color: Colors.white, size: 28.w),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(
      dynamic level, bool isUnlocked, bool isCurrent, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          void onComplete() => _updateProgress(level.level);
          Widget page;

          switch (widget.gameMode) {
            case 'word_match':
              page = WordMatchGamePage(
                  level: level as WordMatchLevelEntity,
                  onLevelComplete: onComplete);
              break;
            case 'typing':
              page = TypingGamePage(
                  level: level as TypingLevelEntity,
                  onLevelComplete: onComplete);
              break;
            case 'dictation':
              page = DictationGamePage(
                  level: level as DictationLevelEntity,
                  onLevelComplete: onComplete);
              break;
            case 'reading':
              page = ReadingGamePage(
                  level: level as ReadingLevelEntity,
                  onLevelComplete: onComplete);
              break;
            case 'rapid_fire':
              page = RapidFireGamePage(
                  level: level as RapidFireLevelEntity,
                  onLevelComplete: onComplete);
              break;
            default:
              // Scramble (Sentence Master)
              page = GamePage(
                  level: level as ScrambleLevelEntity,
                  onLevelComplete: onComplete);
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          ).then((_) => _loadProgress());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            content: const Text("Complete previous levels to unlock this one!"),
            duration: const Duration(milliseconds: 1500),
          ));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: isUnlocked
              ? (isCurrent
                  ? AppTheme.primaryYellow
                  : Colors.white.withValues(alpha: 0.2))
              : Colors.black.withValues(alpha: 0.2),
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCurrent
                      ? [AppTheme.primaryYellow, Colors.orangeAccent]
                      : [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1)
                        ])
              : null,
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : (isUnlocked
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null),
          border: Border.all(
            color: isCurrent
                ? Colors.white.withValues(alpha: 0.8)
                : (isUnlocked
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1)),
            width: isCurrent ? 2 : 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Level Number
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isUnlocked) ...[
                  Text(
                    '${level.level}',
                    style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ]),
                  ),
                  if (isCurrent)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 20.w),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Icon(Icons.star_rate_rounded,
                          color: Colors.amber[300], size: 16.w),
                    )
                ] else
                  Icon(Icons.lock_rounded, color: Colors.white24, size: 28.w),
              ],
            ),

            // Sparkle for Current
            if (isCurrent)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 16.w)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .rotate(duration: 2.seconds),
              )
          ],
        ),
      ).animate().scale(
            delay:
                Duration(milliseconds: level.level > 20 ? 0 : level.level * 30),
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildBackgroundAuroras(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -100.h,
          right: -50.w,
          child: Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentBlue.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentBlue.withValues(alpha: 0.3),
                  blurRadius: 80,
                  spreadRadius: 20,
                )
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: 50.h, duration: 6.seconds),
        ),
        Positioned(
          bottom: -50.h,
          left: -100.w,
          child: Container(
            width: 400.w,
            height: 400.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryYellow.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.15),
                  blurRadius: 100,
                  spreadRadius: 10,
                )
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(begin: 0, end: 30.w, duration: 8.seconds),
        ),
      ],
    );
  }
}
