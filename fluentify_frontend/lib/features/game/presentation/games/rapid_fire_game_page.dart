import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../domain/entities/rapid_fire_level_entity.dart';
import '../../domain/entities/rapid_fire_challenge_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../../user/presentation/bloc/user_event.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RapidFireGamePage extends StatefulWidget {
  final RapidFireLevelEntity level;
  final VoidCallback onLevelComplete;

  const RapidFireGamePage(
      {super.key, required this.level, required this.onLevelComplete});

  @override
  State<RapidFireGamePage> createState() => _RapidFireGamePageState();
}

class _RapidFireGamePageState extends State<RapidFireGamePage>
    with TickerProviderStateMixin {
  late List<RapidFireChallengeEntity> _challenges;
  int _currentChallengeIndex = 0;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _timeLeft = 0;
  int _totalTime = 0;

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _challenges = widget.level.challenges;
    _progressController = AnimationController(vsync: this);
    _startChallenge();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startChallenge() {
    if (_currentChallengeIndex >= _challenges.length) return;

    final challenge = _challenges[_currentChallengeIndex];

    setState(() {
      _controller.clear();
      _timeLeft = challenge.timeLimitSeconds;
      _totalTime = challenge.timeLimitSeconds;
    });

    _progressController.duration = Duration(seconds: _totalTime);
    _progressController.reverse(from: 1.0);

    _focusNode.requestFocus();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame(false);
      }
    });
  }

  void _checkAnswer() {
    final challenge = _challenges[_currentChallengeIndex];
    final answer = _controller.text.trim().toLowerCase();

    final isCorrect = challenge.acceptableAnswers
        .any((element) => element.toLowerCase() == answer);

    if (isCorrect) {
      _endGame(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Incorrect, try again!"),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.red),
      );
    }
  }

  void _endGame(bool success) {
    _timer?.cancel();
    _progressController.stop();

    if (success) {
      _showResultDialog(true);
    } else {
      _showResultDialog(false);
    }
  }

  void _showResultDialog(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor:
            success ? Colors.red[50] : Colors.grey[50], // Theme adjust
        title: Text(success ? "FAST!" : "Too Slow!",
            style: TextStyle(
                color: success ? Colors.red : Colors.grey[800],
                fontWeight: FontWeight.bold)),
        content: Text(success
            ? "You nailed it in ${_totalTime - _timeLeft}s!"
            : "Time ran out."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (success)
                _nextChallenge();
              else
                _startChallenge(); // Retry
            },
            child: Text(success ? "Next" : "Retry",
                style: const TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  void _nextChallenge() {
    if (_currentChallengeIndex < _challenges.length - 1) {
      setState(() => _currentChallengeIndex++);
      _startChallenge();
    } else {
      // Level Complete
      if (mounted) {
        final currentUser = context.read<UserBloc>().state;
        int currentLevel = 1;
        if (currentUser is UserLoaded) {
          currentLevel = currentUser.user.rapidFireLevel;
        }

        if (widget.level.level >= currentLevel) {
          context.read<UserBloc>().add(
                UpdateUserProfileEvent(rapidFireLevel: widget.level.level + 1),
              );
        }
      }

      widget.onLevelComplete();
      Navigator.pop(context); // Go back to levels
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentChallengeIndex >= _challenges.length)
      return const SizedBox.shrink();
    final challenge = _challenges[_currentChallengeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2), // Red 50
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer Dial
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: CircularProgressIndicator(
                      value: _timeLeft / _totalTime,
                      strokeWidth: 8.w,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation(Colors.red),
                    ),
                  ),
                  Text("$_timeLeft",
                      style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                ],
              ),
              SizedBox(height: 48.h),

              Text("RAPID FIRE",
                  style: TextStyle(
                      fontSize: 16.sp,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[300])),
              SizedBox(height: 16.h),
              Text(challenge.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF7F1D1D))),

              SizedBox(height: 48.h),

              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "Type answer...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                ),
                onSubmitted: (_) => _checkAnswer(),
              )
                  .animate(
                      onPlay: (controller) =>
                          controller.repeat(reverse: true, period: 2000.ms))
                  .shimmer(
                      duration: 1500.ms, color: Colors.red.withOpacity(0.1)),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                  elevation: 10,
                  shadowColor: Colors.red.withOpacity(0.5),
                ),
                child: const Icon(Icons.arrow_forward,
                    size: 32, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
