import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'dart:ui';
import '../../../../config/theme/app_theme.dart';
import '../../domain/models/game_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/user/domain/repositories/user_repository.dart';

class GamePage extends StatefulWidget {
  final GameLevel level;
  final VoidCallback? onLevelComplete;
  const GamePage({super.key, required this.level, this.onLevelComplete});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _currentChallengeIndex = 0;
  List<String> _shuffledWords = [];
  List<String> _selectedWords = [];
  bool? _isCorrect;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    // Try to fetch from server first for accurate balance
    try {
      final result = await getIt<UserRepository>().getProfile();
      result.fold(
        (failure) {
          // Fallback to local
          setState(() {
            _coins = prefs.getInt('user_coins') ?? 100;
          });
        },
        (user) {
          setState(() {
            _coins = user.coins;
          });
          prefs.setInt('user_coins', _coins);
        },
      );
    } catch (e) {
      // Fallback
      setState(() {
        _coins = prefs.getInt('user_coins') ?? 100;
      });
    }
  }

  Future<void> _addCoins(int amount) async {
    // 1. Optimistic Update (Local)
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _coins += amount;
    });
    await prefs.setInt('user_coins', _coins);

    // 2. Sync to Server
    try {
      await getIt<UserRepository>().addCoins(amount);
      // We could re-fetch boolean success but optimistic is better for game feel
    } catch (e) {
      debugPrint('Failed to sync coins: $e');
    }
  }

  void _loadChallenge() {
    final challenge = widget.level.challenges[_currentChallengeIndex];
    setState(() {
      _shuffledWords = List.from(challenge.shuffledWords);
      _selectedWords = [];
      _isCorrect = null;
    });
  }

  void _selectWord(String word) {
    if (_isCorrect == true) return;
    setState(() {
      _shuffledWords.remove(word);
      _selectedWords.add(word);
    });
  }

  void _unselectWord(String word) {
    if (_isCorrect == true) return;
    setState(() {
      _selectedWords.remove(word);
      _shuffledWords.add(word);
    });
  }

  void _checkSentence() {
    final challenge = widget.level.challenges[_currentChallengeIndex];
    final userSentence = _selectedWords.join(' ');

    setState(() {
      _isCorrect = userSentence.trim().toLowerCase() ==
          challenge.correctSentence.trim().toLowerCase();
    });

    if (_isCorrect!) {
      _addCoins(10); // Reward 10 coins
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8.w),
              const Text('Correct! +10 Coins',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not quite right. Try again!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _nextChallenge() {
    if (_currentChallengeIndex < widget.level.challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _loadChallenge();
      });
    } else {
      // Level Complete
      if (widget.onLevelComplete != null) {
        widget.onLevelComplete!();
      }
      _showLevelComplete();
    }
  }

  void _showLevelComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20.w),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_rounded,
                        color: AppTheme.primaryYellow, size: 80.w)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                SizedBox(height: 20.h),
                Text('Level Complete!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 10.h),
                Text('You unlocked the next level!',
                    style: TextStyle(color: Colors.white70, fontSize: 16.sp)),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Dialog
                        Navigator.pop(context); // Page
                      },
                      child: Text('Levels',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.sp)),
                    ),
                    SizedBox(width: 20.w),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _navigateToNextLevel();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryYellow,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                        minimumSize:
                            Size(120.w, 48.h), // Override global infinite width
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r)),
                      ),
                      child: const Text('Next Level'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToNextLevel() {
    // Find next level
    final allLevels = GameLevel.getLevels();
    final currentLevelNum = widget.level.level;
    if (currentLevelNum < allLevels.length) {
      final nextLevel = allLevels[
          currentLevelNum]; // index is levelNum (since 0-based is lv1)
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => GamePage(
                    level: nextLevel,
                    // Chain the callback to ensure persistent progress continues
                    onLevelComplete: widget.onLevelComplete != null
                        ? () => _updateProgressExternal(nextLevel.level)
                        : null,
                  )));
    } else {
      Navigator.pop(context); // Finished all levels
    }
  }

  // Helper to call the original parent callback if needed,
  // though easier is just to rely on GameLevelsPage passing a callback that handles 'updates' generically.
  // Actually, standardizing: The callback passed from LevelsPage handles 'completed level N'.
  void _updateProgressExternal(int level) {
    // We assume the parent passed a logic that updates based on the COMPLETED level.
    // But if we navigate deeply, we lose the direct parent context.
    // Ideally, we should just update SharedPreferences here too or use a singleton.
    // But for now, we'll try to re-use the callback mechanism if it's cleaner,
    // OR just rely on the user going back.
    // Since I implemented logic in _navigateToNextLevel to find next, let's just make sure we save progress.
    // I'll quickly duplicate the save logic here to be safe since callbacks might get lost in pushReplacement chains
    // if not carefully managed.
    _saveProgress(level);
  }

  Future<void> _saveProgress(int completedLevel) async {
    // Only update if higher
    // We can't easily access the parent state update function without passing it down chain.
    // So we'll update shared prefs directly here to ensure it saves.
    // The LevelsPage will reload from SP on focus/init.
    final importSharedPreferences =
        await SharedPreferences.getInstance(); // Requires import
    final currentHighest =
        importSharedPreferences.getInt('game_highest_level') ?? 1;
    if (completedLevel >= currentHighest) {
      await importSharedPreferences.setInt(
          'game_highest_level', completedLevel + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final challenge = widget.level.challenges[_currentChallengeIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1B4B), // Deep Indigo
                    const Color(0xFF312E81), // Rich Indigo
                    const Color(0xFF0F172A), // Slate
                  ]
                : [
                    const Color(0xFFE0F7FA), // Light Cyan
                    const Color(0xFFE1F5FE), // Light Light Blue
                    const Color(0xFFFFF3E0), // Warm tint
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced Background blobs
            _buildBackgroundAuroras(isDark),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Custom Header
                  _buildCustomHeader(context, isDark),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          /* 
                           * PROGRESS & INFO 
                           */
                          SizedBox(height: 10.h),
                          // Level & Progress Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Challenge ${_currentChallengeIndex + 1}',
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey[700],
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2),
                              ),
                              Text(
                                '${widget.level.challenges.length}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey[400],
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          // Custom Progress Bar
                          Container(
                            height: 8.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black12,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (_currentChallengeIndex + 1) /
                                  widget.level.challenges.length,
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppTheme.primaryYellow,
                                        Colors.orangeAccent
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryYellow
                                            .withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]),
                              ),
                            ).animate().shimmer(
                                duration: 2.seconds, color: Colors.white54),
                          ),

                          SizedBox(height: 30.h),

                          /* 
                           * HINT CARD 
                           */
                          _buildDynamicGlassBox(
                            isDark: isDark,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryYellow.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.lightbulb_rounded,
                                      color: AppTheme.primaryYellow,
                                      size: 28.w),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  '"${challenge.hint}"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    fontSize: 18.sp,
                                    height: 1.4,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 30.h),

                          /* 
                           * DROP ZONE (Target) 
                           */
                          Container(
                            constraints: BoxConstraints(minHeight: 140.h),
                            width: double.infinity,
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A).withOpacity(0.5)
                                    : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: _isCorrect == true
                                      ? Colors.greenAccent
                                      : (_isCorrect == false
                                          ? Colors.redAccent
                                          : (isDark
                                              ? Colors.white10
                                              : Colors.black12)),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]),
                            child: _selectedWords.isEmpty
                                ? Center(
                                    child: Text(
                                      'Tap words below to build the sentence',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white30
                                            : Colors.black26,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  )
                                : Wrap(
                                    spacing: 10.w,
                                    runSpacing: 10.h,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    alignment:
                                        WrapAlignment.center, // Center chips
                                    children: _selectedWords.map((word) {
                                      return _buildWordChip(
                                        word: word,
                                        onTap: () => _unselectWord(word),
                                        // Selected State Style
                                        color: AppTheme.accentBlue,
                                        textColor: Colors.white,
                                        elevation: 4,
                                      ).animate().scale(
                                          duration: 200.ms,
                                          curve: Curves.easeOutBack);
                                    }).toList(),
                                  ),
                          ),

                          SizedBox(height: 40.h),

                          /* 
                           * WORD BANK (Source) 
                           */
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12.w,
                            runSpacing: 12.h,
                            children: _shuffledWords.map((word) {
                              return _buildWordChip(
                                word: word,
                                onTap: () => _selectWord(word),
                                // Default State Style
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.white,
                                textColor:
                                    isDark ? Colors.white : Colors.black87,
                                borderColor:
                                    isDark ? Colors.white24 : Colors.grey[300],
                                elevation: 1,
                              )
                                  .animate()
                                  .fadeIn()
                                  .slideY(begin: 0.2, end: 0, duration: 400.ms);
                            }).toList(),
                          ),

                          SizedBox(height: 100.h), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /* 
              * BOTTOM ACTION BUTTON (Floating)
              */
            Positioned(
              bottom: 30.h,
              left: 24.w,
              right: 24.w,
              child: _buildActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Glass Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(14.r),
                border:
                    Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : Colors.black87, size: 20.w),
            ),
          ),

          // Title with Glow
          Column(
            children: [
              Text(
                widget.level.title,
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    shadows: isDark
                        ? [
                            const Shadow(
                                color: Colors.blueAccent, blurRadius: 10)
                          ]
                        : null),
              ),
              Text(
                '$_coins Coins',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryYellow,
                    shadows: [
                      Shadow(
                          color: AppTheme.primaryYellow.withOpacity(0.5),
                          blurRadius: 5)
                    ]),
              )
            ],
          ),

          // Coin Display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border:
                  Border.all(color: AppTheme.primaryYellow.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on_rounded,
                    color: AppTheme.primaryYellow, size: 18.w),
                SizedBox(width: 6.w),
                Text(
                  '$_coins',
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_isCorrect == true) {
      return ElevatedButton(
        onPressed: _nextChallenge,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryGreen,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppTheme.secondaryGreen.withOpacity(0.5),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Next Challenge',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(width: 8.w),
            const Icon(Icons.arrow_forward_rounded)
          ],
        ),
      ).animate().scale(begin: const Offset(0.9, 0.9));
    } else {
      // "Check" button
      final bool isEnabled = _selectedWords.isNotEmpty;
      return ElevatedButton(
        onPressed: isEnabled ? _checkSentence : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? AppTheme.primaryYellow : Colors.grey[400],
          foregroundColor: Colors.black,
          elevation: isEnabled ? 4 : 0,
          shadowColor: AppTheme.primaryYellow.withOpacity(0.4),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        ),
        child: Text('Check Answer',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
      );
    }
  }

  Widget _buildWordChip({
    required String word,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
    Color? borderColor,
    double elevation = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 8)
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 2)
                ],
        ),
        child: Text(
          word,
          style: TextStyle(
              color: textColor, fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDynamicGlassBox({required Widget child, required bool isDark}) {
    // Replaces GlassmorphicContainer with a flexible standard implementation
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.4),
                    isDark
                        ? Colors.white.withOpacity(0.02)
                        : Colors.white.withOpacity(0.1),
                  ])),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundAuroras(bool isDark) {
    return Stack(
      children: [
        // Top Right Glow
        Positioned(
          top: -100.h,
          right: -100.w,
          child: Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryYellow.withOpacity(isDark ? 0.08 : 0.05),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryYellow.withOpacity(isDark ? 0.2 : 0.1),
                  blurRadius: 50,
                  spreadRadius: 20,
                )
              ],
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(begin: 0, end: 50.h, duration: 5.seconds),
        ),
        // Bottom Left Glow
        Positioned(
          bottom: -50.h,
          left: -100.w,
          child: Container(
            width: 400.w,
            height: 400.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentBlue.withOpacity(isDark ? 0.08 : 0.05),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentBlue.withOpacity(isDark ? 0.2 : 0.1),
                  blurRadius: 60,
                  spreadRadius: 20,
                )
              ],
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveX(begin: 0, end: 50.w, duration: 7.seconds),
        ),
        // Additional Floating Element 1 (Top Left)
        Positioned(
          top: 80.h,
          left: 40.w,
          child: Icon(Icons.star_rounded,
                  color: Colors.white.withOpacity(isDark ? 0.05 : 0.1),
                  size: 40.w)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.5, 1.5),
                  duration: 4.seconds)
              .rotate(begin: 0, end: 0.1, duration: 5.seconds),
        ),
        // Additional Floating Element 2 (Right Middle)
        Positioned(
          top: 300.h,
          right: 20.w,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(isDark ? 0.05 : 0.2),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: 30.h, duration: 6.seconds),
        ),
        // Additional Floating Element 3 (Bottom Center)
        Positioned(
          bottom: 150.h,
          left: 150.w,
          child: Icon(Icons.auto_awesome,
                  color:
                      AppTheme.primaryYellow.withOpacity(isDark ? 0.05 : 0.15),
                  size: 60.w)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 2.seconds)
              .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 3.seconds),
        ),
      ],
    );
  }
}
