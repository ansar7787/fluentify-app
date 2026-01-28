import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../domain/entities/typing_level_entity.dart';
import '../../domain/entities/typing_challenge_entity.dart';

class TypingGamePage extends StatefulWidget {
  final TypingLevelEntity level;
  final VoidCallback onLevelComplete;

  const TypingGamePage(
      {super.key, required this.level, required this.onLevelComplete});

  @override
  State<TypingGamePage> createState() => _TypingGamePageState();
}

class _TypingGamePageState extends State<TypingGamePage> {
  late List<TypingChallengeEntity> _challenges;
  int _currentChallengeIndex = 0;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _targetText = "";
  String _typedText = "";

  Timer? _timer;
  int _timeLeft = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _challenges = widget.level.challenges;
    _startChallenge();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startChallenge() {
    if (_currentChallengeIndex >= _challenges.length) return;

    final challenge = _challenges[_currentChallengeIndex];

    setState(() {
      _targetText = challenge.textToType;
      _typedText = "";
      _controller.clear();
      _timeLeft = challenge.timeLimitSeconds;
      _isPlaying = true;
    });

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

  void _handleInput(String value) {
    if (!_isPlaying) return;

    setState(() {
      _typedText = value;
    });

    if (_typedText == _targetText) {
      _endGame(true);
    }
  }

  void _endGame(bool success) {
    _timer?.cancel();
    setState(() => _isPlaying = false);

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
        title: Text(success ? "Challenge Complete!" : "Time's Up"),
        content: Text(success
            ? "Great job! You typed it correctly."
            : "Don't worry, try again!"),
        actions: [
          if (success)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _nextChallenge();
              },
              child: const Text("Next"),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startChallenge(); // Retry
              },
              child: const Text("Retry"),
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
          currentLevel = currentUser.user.typingLevel;
        }

        if (widget.level.level >= currentLevel) {
          context.read<UserBloc>().add(
                UpdateUserProfileEvent(typingLevel: widget.level.level + 1),
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

    return Scaffold(
      appBar: AppBar(
        title: Text("Level ${widget.level.level}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: _timeLeft /
                  _challenges[_currentChallengeIndex].timeLimitSeconds,
              color: _timeLeft < 10 ? Colors.red : Colors.blue,
              minHeight: 6.h,
            ),
            SizedBox(height: 32.h),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: RichText(
                text: TextSpan(
                  children: _buildTextSpans(),
                  style: TextStyle(
                      fontSize: 24.sp,
                      height: 1.5,
                      fontFamily: 'Courier',
                      color: Colors.black87),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _handleInput,
              style: TextStyle(fontSize: 18.sp),
              decoration: InputDecoration(
                hintText: "Type here...",
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16.w),
              ),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    List<TextSpan> spans = [];
    for (int i = 0; i < _targetText.length; i++) {
      Color color = Colors.grey;
      if (i < _typedText.length) {
        if (_typedText[i] == _targetText[i]) {
          color = Colors.green;
        } else {
          color = Colors.red;
        }
      }
      spans.add(TextSpan(
          text: _targetText[i],
          style: TextStyle(color: color, fontSize: 24.sp)));
    }
    return spans;
  }
}
