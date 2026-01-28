import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../domain/entities/dictation_level_entity.dart';
import '../../domain/entities/dictation_challenge_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../../user/presentation/bloc/user_event.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DictationGamePage extends StatefulWidget {
  final DictationLevelEntity level;
  final VoidCallback onLevelComplete;

  const DictationGamePage(
      {super.key, required this.level, required this.onLevelComplete});

  @override
  State<DictationGamePage> createState() => _DictationGamePageState();
}

class _DictationGamePageState extends State<DictationGamePage> {
  late List<DictationChallengeEntity> _challenges;
  int _currentChallengeIndex = 0;
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();

  bool _isPlayingAudio = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _challenges = widget.level.challenges;
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  void _playAudio() async {
    if (_currentChallengeIndex >= _challenges.length) return;
    setState(() => _isPlayingAudio = true);
    await _flutterTts.speak(_challenges[_currentChallengeIndex].correctText);
  }

  void _checkAnswer() {
    final challenge = _challenges[_currentChallengeIndex];
    final userAnswer = _controller.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '');
    final correctAnswer =
        challenge.correctText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    if (userAnswer == correctAnswer) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(isCorrect ? Icons.check_circle : Icons.error,
                color: isCorrect ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(isCorrect ? "PerfectMatch!" : "Oops!"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isCorrect
                ? "You heard it correctly."
                : "That's not quite right."),
            const SizedBox(height: 12),
            if (!isCorrect) ...[
              const Text("Correct text:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(_challenges[_currentChallengeIndex].correctText,
                  style: const TextStyle(color: Colors.green)),
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              if (isCorrect) {
                _nextChallenge();
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
        _controller.clear();
        _showHint = false;
      });
    } else {
      // Level Complete
      if (mounted) {
        final currentUser = context.read<UserBloc>().state;
        int currentLevel = 1;
        if (currentUser is UserLoaded) {
          currentLevel = currentUser.user.dictationLevel;
        }

        if (widget.level.level >= currentLevel) {
          context.read<UserBloc>().add(
                UpdateUserProfileEvent(dictationLevel: widget.level.level + 1),
              );
        }
      }

      widget.onLevelComplete();
      Navigator.pop(context); // Back to levels
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentChallengeIndex >= _challenges.length)
      return const SizedBox.shrink();
    final challenge = _challenges[_currentChallengeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // Light Green bg
      appBar: AppBar(
        title: Text("Dictation ${widget.level.level}",
            style: TextStyle(fontSize: 20.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF166534),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.w),
        child: Column(
          children: [
            Icon(Icons.headphones_rounded,
                    size: 80.w, color: const Color(0xFF10B981))
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 1000.ms),
            SizedBox(height: 32.h),
            Text(
              "Listen and type exactly what you hear",
              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF166534)),
            ),
            SizedBox(height: 32.h),
            GestureDetector(
              onTap: _isPlayingAudio ? null : _playAudio,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5)
                    ]),
                child: Icon(
                  _isPlayingAudio
                      ? Icons.volume_up_rounded
                      : Icons.play_arrow_rounded,
                  size: 50.w,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
            SizedBox(height: 48.h),
            TextField(
              controller: _controller,
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                  hintText: "Type here...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () => setState(() => _showHint = !_showHint),
                  )),
              maxLines: 3,
            ),
            if (_showHint)
              Padding(
                padding: EdgeInsets.only(top: 16.0.h),
                child: Text("Hint: ${challenge.hint}",
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic)),
              ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // Emerald
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text("Submit",
                    style: TextStyle(
                        fontSize: 18.sp,
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
