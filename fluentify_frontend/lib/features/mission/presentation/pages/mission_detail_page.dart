import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import '../bloc/mission_bloc.dart';
import '../bloc/mission_event.dart';
import '../bloc/mission_state.dart';
import '../../domain/entities/mission_entity.dart';

class MissionDetailPage extends StatefulWidget {
  final MissionEntity mission;

  const MissionDetailPage({super.key, required this.mission});

  @override
  State<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends State<MissionDetailPage> {
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
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

    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      _showSubmissionDialog(path);
    }
  }

  void _showSubmissionDialog(String path) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Recording Captured!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Duration: ${_recordDuration.inSeconds} seconds'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Submit to API through BLoC
                      Navigator.pop(context);
                      _submitMission(path);
                    },
                    child: const Text('Get AI Feedback'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitMission(String path) {
    context.read<MissionBloc>().add(
          SubmitMissionAttempt(
            missionId: widget.mission.id,
            audioPath: path,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mission.title),
        backgroundColor: Colors.transparent,
      ),
      body: BlocListener<MissionBloc, MissionState>(
        listener: (context, state) {
          if (state is MissionSubmitted) {
            _showFeedbackDialog(state.result);
          } else if (state is MissionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLevelBadge(widget.mission.level),
                    const SizedBox(height: 16),
                    Text(
                      widget.mission.description,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('MISSION PROMPT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.mission.content ??
                                'No prompt available for this mission.',
                            style: const TextStyle(fontSize: 18, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<MissionBloc, MissionState>(
              builder: (context, state) {
                if (state is MissionSubmitting) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('AI is analyzing your speech...'),
                      ],
                    ),
                  );
                }
                return _buildRecordArea();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(MissionSubmissionResultEntity result) {
    final feedback = result.feedback;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'AI Analysis Result',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Your Transcription'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  feedback.transcript,
                  style: const TextStyle(
                      fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Linguistic Performance'),
              const SizedBox(height: 16),
              _buildAdvancedScoreRow(
                  'Fluency', feedback.fluencyScore, Colors.green),
              _buildAdvancedScoreRow(
                  'Grammar', feedback.grammarScore, Colors.blue),
              _buildAdvancedScoreRow(
                  'Vocabulary', feedback.vocabularyScore, Colors.orange),
              _buildAdvancedScoreRow(
                  'Pronunciation', feedback.pronunciationScore, Colors.purple),
              const SizedBox(height: 32),
              _buildSectionHeader('Coach Feedback'),
              const SizedBox(height: 12),
              Text(
                feedback.feedback,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.pop(context); // Go back to dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D62ED),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Return to Dashboard',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedScoreRow(String label, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${score.toStringAsFixed(1)}/10',
                  style: TextStyle(
                      color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 10,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLevelBadge(String level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        level.toUpperCase(),
        style: const TextStyle(
            color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildRecordArea() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          if (_isRecording)
            Text(
              '${_recordDuration.inSeconds}s',
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          const SizedBox(height: 24),
          GestureDetector(
            onTapDown: (_) => _startRecording(),
            onTapUp: (_) => _stopRecording(),
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : Colors.blue)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isRecording ? 'TAP TO STOP' : 'TAP TO START SPEAKING',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
