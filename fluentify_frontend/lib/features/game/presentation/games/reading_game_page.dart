import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../domain/entities/reading_level_entity.dart';
import '../../domain/entities/reading_challenge_entity.dart';

class ReadingGamePage extends StatefulWidget {
  final ReadingLevelEntity level;
  final VoidCallback onLevelComplete;

  const ReadingGamePage(
      {super.key, required this.level, required this.onLevelComplete});

  @override
  State<ReadingGamePage> createState() => _ReadingGamePageState();
}

class _ReadingGamePageState extends State<ReadingGamePage> {
  late List<ReadingChallengeEntity> _challenges;
  int _currentChallengeIndex = 0;
  int? _selectedOptionIndex;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _challenges = widget.level.challenges;
  }

  void _checkAnswer() {
    if (_selectedOptionIndex == null) return;

    setState(() => _isChecked = true);

    final challenge = _challenges[_currentChallengeIndex];
    if (_selectedOptionIndex == challenge.correctOptionIndex) {
      _showFeedback(true);
    } else {
      _showFeedback(false);
    }
  }

  void _showFeedback(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? "Correct!" : "Incorrect"),
        content: Text(isCorrect
            ? "Excellent comprehension."
            : "Review the passage and try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isCorrect) {
                _nextChallenge();
              } else {
                setState(() {
                  _isChecked = false;
                  _selectedOptionIndex = null;
                });
              }
            },
            child: Text(isCorrect ? "Next" : "Try Again"),
          )
        ],
      ),
    );
  }

  void _nextChallenge() {
    if (_currentChallengeIndex < _challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _selectedOptionIndex = null;
        _isChecked = false;
      });
    } else {
      // Level Complete
      if (mounted) {
        final currentUser = context.read<UserBloc>().state;
        int currentLevel = 1;
        if (currentUser is UserLoaded) {
          currentLevel = currentUser.user.readingLevel;
        }

        if (widget.level.level >= currentLevel) {
          context.read<UserBloc>().add(
                UpdateUserProfileEvent(readingLevel: widget.level.level + 1),
              );
        }
      }

      widget.onLevelComplete();
      Navigator.pop(context); // Back to levels
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentChallengeIndex >= _challenges.length) {
      return const SizedBox.shrink();
    }
    final challenge = _challenges[_currentChallengeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB), // Light Amber
      appBar: AppBar(
        title: Text(widget.level.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.amber.shade200),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.title,
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown)),
                  SizedBox(height: 12.h),
                  Text(challenge.passage,
                      style: TextStyle(
                          fontSize: 16.sp, height: 1.6, color: Colors.black87)),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text("Question:",
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900])),
            SizedBox(height: 8.h),
            Text(challenge.question,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 16.h),
            ...List.generate(challenge.options.length, (index) {
              final isSelected = _selectedOptionIndex == index;
              return GestureDetector(
                onTap: _isChecked
                    ? null
                    : () => setState(() => _selectedOptionIndex = index),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber[100] : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: isSelected ? Colors.amber : Colors.grey.shade300,
                        width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12.r,
                        backgroundColor:
                            isSelected ? Colors.amber : Colors.grey[200],
                        child: Text("${index + 1}",
                            style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontSize: 12.sp)),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: Text(challenge.options[index],
                              style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedOptionIndex != null ? _checkAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm Answer",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
