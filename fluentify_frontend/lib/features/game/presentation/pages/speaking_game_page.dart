import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'dart:ui';
import '../../../../config/theme/app_theme.dart';
import '../../domain/models/speaking_challenge.dart';
import '../../../mission/presentation/bloc/mission_bloc.dart';
import '../../../mission/presentation/bloc/mission_event.dart';
import '../../../mission/presentation/bloc/mission_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpeakingGamePage extends StatefulWidget {
  final SpeakingLevel level;
  const SpeakingGamePage({super.key, required this.level});

  @override
  State<SpeakingGamePage> createState() => _SpeakingGamePageState();
}

class _SpeakingGamePageState extends State<SpeakingGamePage> {
  late List<SpeakingChallenge> _challenges;
  int _currentIndex = 0;

  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _challenges = widget.level.challenges;
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final path = '${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _recordDuration = Duration.zero;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _recordDuration += const Duration(seconds: 1));
        });
      }
    } catch (e) {
      debugPrint('Recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    _timer?.cancel();
    setState(() => _isRecording = false);
    if (path != null) {
      _submitAttempt(path);
    }
  }

  void _submitAttempt(String path) {
    context.read<MissionBloc>().add(
          SubmitMissionAttempt(
            missionId: _challenges[_currentIndex].id,
            audioPath: path,
          ),
        );
  }

  void _nextChallenge() {
    if (_currentIndex < _challenges.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final challenge = _challenges[_currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:
            Text('Fluency Flow', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: BlocListener<MissionBloc, MissionState>(
        listener: (context, state) {
          if (state is MissionSubmitted) {
            _showFeedbackDialog(state.result);
          } else if (state is MissionError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                  : [const Color(0xFFE0F2F1), const Color(0xFFE0F7FA)],
            ),
          ),
          child: Stack(
            children: [
              _buildFloatingBlobs(isDark),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    _buildChallengeInfo(challenge),
                    const Spacer(),
                    _buildPromptCard(isDark, challenge),
                    const Spacer(),
                    _buildRecordSection(isDark),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
              if (context.watch<MissionBloc>().state is MissionSubmitting)
                _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeInfo(SpeakingChallenge challenge) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBadge(challenge.difficulty, AppTheme.accentBlue),
          _buildBadge(
              '${challenge.durationSeconds}s target', AppTheme.primaryYellow),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12.sp)),
    );
  }

  Widget _buildPromptCard(bool isDark, SpeakingChallenge challenge) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        children: [
          Text(
            challenge.title,
            style: TextStyle(
                color: AppTheme.primaryYellow,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                letterSpacing: 1.2),
          ),
          SizedBox(height: 16.h),
          Text(
            challenge.prompt,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                height: 1.4),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildRecordSection(bool isDark) {
    return Column(
      children: [
        if (_isRecording)
          Text(
            '${_recordDuration.inSeconds}s',
            style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent),
          ).animate().fadeIn().scale(),
        SizedBox(height: 24.h),
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: Container(
            height: 100.w,
            width: 100.w,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.redAccent : AppTheme.accentBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? Colors.redAccent : AppTheme.accentBlue)
                      .withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 10,
                )
              ],
            ),
            child: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white, size: 48.w),
          ),
        )
            .animate(
                onPlay: (c) =>
                    _isRecording ? c.repeat(reverse: true) : c.stop())
            .scale(begin: Offset(1.0, 1.0), end: Offset(1.1, 1.1)),
        SizedBox(height: 16.h),
        Text(
          _isRecording ? 'TAP TO COMPLETE' : 'TAP TO RECORD',
          style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              fontSize: 13.sp),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black26,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryYellow),
              SizedBox(height: 20.h),
              Text('AI Analyzing Fluency...',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(dynamic result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fluency Report',
                      style: TextStyle(
                          fontSize: 24.sp, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close)),
                ],
              ),
              SizedBox(height: 20.h),
              _buildScoreBar(
                  'Fluency', result.feedback.fluencyScore, Colors.green),
              _buildScoreBar(
                  'Grammar', result.feedback.grammarScore, Colors.blue),
              _buildScoreBar(
                  'Vocabulary', result.feedback.vocabularyScore, Colors.orange),
              _buildScoreBar('Pronunciation',
                  result.feedback.pronunciationScore, Colors.purple),
              SizedBox(height: 20.h),
              Text('Coach Feedback',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              Text(result.feedback.feedback,
                  style: TextStyle(
                      fontSize: 15.sp, height: 1.5, color: Colors.black87)),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _nextChallenge();
                },
                child: const Text('Next Challenge'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, double score, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${score.toStringAsFixed(1)}/10',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 6.h),
          LinearProgressIndicator(
              value: score / 10,
              color: color,
              backgroundColor: color.withOpacity(0.1),
              minHeight: 8.h),
        ],
      ),
    );
  }

  Widget _buildFloatingBlobs(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: 100.h,
          left: -50.w,
          child: Container(
            width: 250.w,
            height: 250.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.1),
                  blurRadius: 100,
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 100.h,
          right: -50.w,
          child: Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 100,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
