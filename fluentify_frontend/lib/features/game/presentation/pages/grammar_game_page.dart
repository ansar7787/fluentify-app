import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/grammar_level_entity.dart';
import '../../domain/entities/grammar_challenge_entity.dart'; // Updated import
import '../../../../core/di/service_locator.dart';
import '../../../../features/user/domain/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GrammarGamePage extends StatefulWidget {
  final GrammarLevelEntity level; // Updated type
  final VoidCallback onLevelComplete;

  const GrammarGamePage({
    super.key,
    required this.level,
    required this.onLevelComplete,
  });

  @override
  State<GrammarGamePage> createState() => _GrammarGamePageState();
}

class _GrammarGamePageState extends State<GrammarGamePage> {
  late List<GrammarChallengeEntity> _challenges; // Updated type
  int _currentIndex = 0;
  int? _selectedIndex;
  bool? _isCorrect;
  int _coins = 0;
  bool _levelHadMistakes = false;

  @override
  void initState() {
    super.initState();
    _challenges = widget.level.challenges;
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final result = await getIt<UserRepository>().getProfile();
      result.fold(
        (failure) {
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
      setState(() {
        _coins = prefs.getInt('user_coins') ?? 100;
      });
    }
  }

  Future<void> _addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _coins += amount;
    });
    await prefs.setInt('user_coins', _coins);
    try {
      await getIt<UserRepository>().addCoins(amount);
    } catch (e) {
      debugPrint('Failed to sync coins: $e');
    }
  }

  void _checkAnswer(int index) {
    if (_isCorrect != null && _isCorrect!) {
      return;
    }

    setState(() {
      _selectedIndex = index;
      _isCorrect = index == _challenges[_currentIndex].correctOptionIndex;
    });

    if (_isCorrect!) {
      _addCoins(15);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct! +15 Coins'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      _levelHadMistakes = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not quite right. Try again!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _retryChallenge() {
    setState(() {
      _selectedIndex = null;
      _isCorrect = null;
    });
  }

  void _nextChallenge() {
    if (_currentIndex < _challenges.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _isCorrect = null;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    // Determine title and message based on performance
    String title =
        _levelHadMistakes ? 'Level Completed!' : 'Perfect Performance!';
    String message = _levelHadMistakes
        ? 'Great job finishing level ${widget.level.level}.'
        : 'You mastered level ${widget.level.level} without any mistakes!';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          title: Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog
                widget.onLevelComplete();
                Navigator.pop(context); // Page
              },
              child: const Text('Continue',
                  style: TextStyle(color: AppTheme.primaryYellow)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final challenge = _challenges[_currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Grammar Quest',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22.sp,
                letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: isDark ? Colors.white : AppColors.textHeadline,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on_rounded,
                    color: AppTheme.primaryYellow, size: 18.w),
                SizedBox(width: 6.w),
                Text('$_coins',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: isDark ? Colors.white : AppColors.textHeadline)),
              ],
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.background,
        ),
        child: Stack(
          children: [
            _buildBackgroundGlow(isDark),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    _buildProgressBar(),
                    SizedBox(height: 40.h),
                    _buildQuestionCard(isDark, challenge),
                    SizedBox(height: 40.h),
                    _buildOptionsGrid(isDark, challenge),
                    const Spacer(),
                    if (_isCorrect != null)
                      ElevatedButton(
                        onPressed:
                            _isCorrect! ? _nextChallenge : _retryChallenge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCorrect!
                              ? AppTheme.primaryYellow
                              : Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_isCorrect! ? 'Continue' : 'Try Again',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            SizedBox(width: 8.w),
                            Icon(
                                _isCorrect!
                                    ? Icons.arrow_forward
                                    : Icons.refresh,
                                color: Colors.black),
                          ],
                        ),
                      ).animate().scale().fadeIn(),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${_currentIndex + 1} of ${_challenges.length}',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600)),
            Text('${((_currentIndex + 1) / _challenges.length * 100).toInt()}%',
                style: TextStyle(
                    color: AppTheme.primaryYellow,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 12.h),
        Stack(
          children: [
            Container(
              height: 8.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            FractionallySizedBox(
              widthFactor: (_currentIndex + 1) / _challenges.length,
              child: Container(
                height: 8.h,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ).animate().shimmer(duration: 2.seconds, color: Colors.white30),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard(bool isDark, GrammarChallengeEntity challenge) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology_outlined,
                color: AppColors.primary, size: 32.w),
          ),
          SizedBox(height: 24.h),
          Text(
            challenge.question,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textHeadline,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          if (_isCorrect != null && _isCorrect!)
            Padding(
              padding: EdgeInsets.only(top: 24.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.success, size: 20.w),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        challenge.explanation,
                        style: TextStyle(
                            color: isDark ? Colors.white70 : AppColors.success,
                            fontSize: 14.sp,
                            height: 1.4,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(bool isDark, GrammarChallengeEntity challenge) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 2.2,
      ),
      itemCount: challenge.options.length,
      itemBuilder: (context, index) {
        bool isSelected = _selectedIndex == index;
        bool isCorrectChoice = index == challenge.correctOptionIndex;

        Color cardColor =
            isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white;
        if (_isCorrect != null) {
          if (isCorrectChoice) {
            cardColor = Colors.green.withValues(alpha: 0.2);
          } else if (isSelected) {
            cardColor = Colors.red.withValues(alpha: 0.2);
          }
        } else if (isSelected) {
          cardColor = AppTheme.accentBlue.withValues(alpha: 0.3);
        }

        return GestureDetector(
          onTap: () => _checkAnswer(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _isCorrect != null && isCorrectChoice
                    ? Colors.green
                    : (_isCorrect != null && isSelected
                        ? Colors.red
                        : Colors.white12),
                width: isSelected || (_isCorrect != null && isCorrectChoice)
                    ? 2
                    : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              challenge.options[index],
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideX();
      },
    );
  }

  Widget _buildBackgroundGlow(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -100.h,
          right: -100.w,
          child: Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentBlue.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentBlue.withValues(alpha: 0.15),
                  blurRadius: 100,
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -50.h,
          left: -100.w,
          child: Container(
            width: 400.w,
            height: 400.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryYellow.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                  blurRadius: 120,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
