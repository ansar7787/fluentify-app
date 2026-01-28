import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../features/mission/domain/entities/mission_entity.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/theme/app_theme.dart';
import '../../domain/entities/speaking_level_entity.dart';
import '../../domain/entities/speaking_challenge_entity.dart';
import '../../../mission/presentation/bloc/mission_bloc.dart';
import '../../../mission/presentation/bloc/mission_event.dart';
import '../../../mission/presentation/bloc/mission_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/user/domain/repositories/user_repository.dart';

class SpeakingGamePage extends StatefulWidget {
  final SpeakingLevelEntity level;
  final VoidCallback onLevelComplete;

  const SpeakingGamePage({
    super.key,
    required this.level,
    required this.onLevelComplete,
  });

  @override
  State<SpeakingGamePage> createState() => _SpeakingGamePageState();
}

class _SpeakingGamePageState extends State<SpeakingGamePage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late List<SpeakingChallengeEntity> _challenges;
  int _currentIndex = 0;
  bool _isRecording = false;
  String? _recordedFilePath;
  bool _isPlaying = false;
  int _coins = 0;

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

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final directory = await getApplicationDocumentsDirectory();
      String filePath =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(const RecordConfig(), path: filePath);
      setState(() {
        _isRecording = true;
        _recordedFilePath = null;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordedFilePath = path;
    });
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath != null && !_isPlaying) {
      setState(() => _isPlaying = true);
      try {
        await _audioPlayer.setFilePath(_recordedFilePath!);
        await _audioPlayer.play();
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (mounted) {
              setState(() => _isPlaying = false);
            }
          }
        });
      } catch (e) {
        debugPrint('Error playing audio: $e');
        setState(() => _isPlaying = false);
      }
    } else if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    }
  }

  void _submitRecording() {
    if (_recordedFilePath != null) {
      final challenge = _challenges[_currentIndex];
      // Note: Using MissionBloc for analysis. Assuming generic mission structure maps to speaking challenge.
      // Ideally Game would have its own submission logic, but reusing MissionBloc is efficient here.
      // Mapping parameters: id -> missionId

      context.read<MissionBloc>().add(
            SubmitMissionAttempt(
              missionId: challenge.id,
              audioPath: _recordedFilePath!,
            ),
          );
    }
  }

  void _showFeedbackDialog(MissionSubmissionResultEntity result, bool passed) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Container(
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              passed ? 'Great Job!' : 'Keep Practicing',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: passed ? AppTheme.secondaryGreen : Colors.orange,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Score: ${(result.score).toStringAsFixed(1)} / 10',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      result.feedback.feedback,
                      style: TextStyle(fontSize: 16.sp, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    if (result.feedback.transcript.isNotEmpty) ...[
                      const Text(
                        'Transcript:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        result.feedback.transcript,
                        style: TextStyle(
                            fontSize: 14.sp, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ]
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (passed) {
                  _addCoins(30);
                  _nextChallenge();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    passed ? AppTheme.secondaryGreen : Colors.orange,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
              ),
              child: Text(passed ? 'Next Stage' : 'Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _nextChallenge() {
    if (_currentIndex < _challenges.length - 1) {
      setState(() {
        _currentIndex++;
        _recordedFilePath = null;
      });
    } else {
      widget.onLevelComplete();
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
        title: Text('Fluency Flow',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Row(
              children: [
                Icon(Icons.monetization_on,
                    color: AppTheme.primaryYellow, size: 20.w),
                SizedBox(width: 4.w),
                Text('$_coins',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ],
            ),
          )
        ],
      ),
      body: BlocListener<MissionBloc, MissionState>(
        listener: (context, state) {
          if (state is MissionSubmitted) {
            // Check if score >= 5.0 (Assuming score is 0-10 or similar)
            bool passed = state.result.score >= 5.0;
            _showFeedbackDialog(state.result, passed);
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
                  ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                  : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        _buildProgressBar(),
                        SizedBox(height: 40.h),
                        Text(
                          challenge.title,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            challenge.prompt,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.sp,
                              height: 1.5,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (_recordedFilePath != null) ...[
                          IconButton(
                            onPressed: _playRecording,
                            icon: Icon(
                                _isPlaying
                                    ? Icons.stop_circle_outlined
                                    : Icons.play_circle_fill,
                                size: 60.w,
                                color: AppTheme.accentBlue),
                          ),
                          const Text('Tap to play',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildBottomControls(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: LinearProgressIndicator(
        value: (_currentIndex + 1) / _challenges.length,
        minHeight: 8.h,
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation(AppTheme.accentBlue),
      ),
    );
  }

  Widget _buildBottomControls(bool isDark) {
    return Container(
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 80.w,
                  width: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : AppTheme.accentBlue,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : AppTheme.accentBlue)
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 40.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (_recordedFilePath != null && !_isRecording)
            ElevatedButton(
              onPressed: _submitRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryGreen,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Text(
                'Submit Answer',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ).animate().fadeIn().slideY(begin: 0.2),
        ],
      ),
    );
  }
}
