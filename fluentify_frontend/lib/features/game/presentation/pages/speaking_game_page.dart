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
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/speaking_level_entity.dart';
import '../../domain/entities/speaking_challenge_entity.dart';
import '../../../mission/presentation/bloc/mission_bloc.dart';
import '../../../mission/presentation/bloc/mission_event.dart';
import '../../../mission/presentation/bloc/mission_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/user/domain/repositories/user_repository.dart';
import '../../../speaking_coach/presentation/bloc/speaking_coach_bloc.dart';
import '../../../speaking_coach/presentation/pages/speaking_coach_page.dart';

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
      context.read<MissionBloc>().add(
            SubmitMissionAttempt(
              missionId: challenge.id,
              audioPath: _recordedFilePath!,
            ),
          );

      // Loading dialog with premium style
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 3),
                SizedBox(height: 24.h),
                Text('AI Analyzing Speech...',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: AppColors.textHeadline)),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _showFeedbackDialog(
    MissionSubmissionResultEntity result,
    bool passed,
    String challengePrompt,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ],
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: (passed ? AppColors.success : AppColors.warning)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                passed
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: passed ? AppColors.success : AppColors.warning,
                size: 48.w,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              passed ? 'Great Job!' : 'Keep Practicing',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: passed ? AppColors.success : AppColors.warning,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Fluency Score: ${(result.score).toStringAsFixed(1)} / 10',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeedbackSection(
                        'AI Observations', result.feedback.feedback),
                    if (result.feedback.transcript.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _buildFeedbackSection(
                          'What we heard', result.feedback.transcript,
                          isItalic: true),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (passed) {
                        _addCoins(30);
                        _nextChallenge();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          passed ? AppColors.success : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r)),
                      elevation: 0,
                    ),
                    child: Text(passed ? 'Next Stage' : 'Try Again',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  ),
                ),
              ],
            ),
            if (result.feedback.transcript.isNotEmpty) ...[
              SizedBox(height: 12.h),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => getIt<SpeakingCoachBloc>(),
                        child: SpeakingCoachPage(
                          transcript: result.feedback.transcript,
                          prompt: challengePrompt,
                          learnerLevel: 'Level ${widget.level.level}',
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.psychology_outlined,
                    color: AppColors.primary),
                label: Text('Open AI Coach Plan',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(String title, String content,
      {bool isItalic = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: AppColors.textHeadline)),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.5,
              color: AppColors.textBody,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
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
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22.sp,
                letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.textHeadline,
        elevation: 0,
        centerTitle: false,
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
                        fontWeight: FontWeight.bold, fontSize: 14.sp)),
              ],
            ),
          )
        ],
      ),
      body: BlocListener<MissionBloc, MissionState>(
        listener: (context, state) {
          if (state is MissionSubmitted) {
            Navigator.pop(context); // Close loading dialog
            bool passed = state.result.score >= 5.0;
            _showFeedbackDialog(
              state.result,
              passed,
              challenge.prompt,
            );
          } else if (state is MissionError) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.background,
          ),
          child: Stack(
            children: [
              _buildBackgroundGlow(isDark),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            SizedBox(height: 20.h),
                            _buildProgressBar(),
                            SizedBox(height: 48.h),
                            Text(
                              challenge.title,
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textHeadline,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Container(
                              padding: EdgeInsets.all(32.w),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurface
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10))
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    challenge.prompt,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textHeadline,
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  Text(
                                    'Read the phrase clearly and naturally',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.1, end: 0),
                            const Spacer(),
                            if (_recordedFilePath != null && !_isRecording) ...[
                              _buildAudioPreview(isDark),
                              SizedBox(height: 24.h),
                            ],
                          ],
                        ),
                      ),
                    ),
                    _buildBottomControls(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundGlow(bool isDark) {
    return Positioned(
      top: -100.h,
      right: -100.w,
      child: Container(
        width: 300.w,
        height: 300.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: isDark ? 0.05 : 0.1),
        ),
      ),
    ).animate().fadeIn(duration: 1.seconds);
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Stage ${_currentIndex + 1} of ${_challenges.length}',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600)),
            Text('${((_currentIndex + 1) / _challenges.length * 100).toInt()}%',
                style: TextStyle(
                    color: AppColors.primary,
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

  Widget _buildAudioPreview(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _playRecording,
            child: Icon(
              _isPlaying
                  ? Icons.stop_circle_rounded
                  : Icons.play_circle_filled_rounded,
              color: AppColors.primary,
              size: 40.w,
            ),
          ),
          SizedBox(width: 12.w),
          Text(_isPlaying ? 'Playing...' : 'Review Recording',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp)),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () => setState(() => _recordedFilePath = null),
            icon: Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary, size: 20.w),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildBottomControls(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
          top: 32.h,
          bottom: MediaQuery.of(context).padding.bottom + 32.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: Container(
              height: 90.w,
              width: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isRecording
                    ? LinearGradient(colors: [Colors.red, Colors.red[700]!])
                    : AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : AppColors.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 8,
                  )
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 40.w,
              ),
            )
                .animate(onPlay: (c) => _isRecording ? c.repeat() : c.stop())
                .shake(hz: 2, curve: Curves.easeInOut),
          ),
          SizedBox(height: 24.h),
          if (_recordedFilePath != null && !_isRecording)
            ElevatedButton(
              onPressed: _submitRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 60.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r)),
                elevation: 0,
              ),
              child: Text(
                'Submit Answer',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
              ),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
