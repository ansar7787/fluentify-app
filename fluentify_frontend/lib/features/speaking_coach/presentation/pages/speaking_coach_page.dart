import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/speaking_coach_bloc.dart';
import '../bloc/speaking_coach_event.dart';
import '../bloc/speaking_coach_state.dart';

class SpeakingCoachPage extends StatefulWidget {
  final String transcript;
  final String prompt;
  final String learnerLevel;

  const SpeakingCoachPage({
    super.key,
    required this.transcript,
    required this.prompt,
    this.learnerLevel = 'Intermediate',
  });

  @override
  State<SpeakingCoachPage> createState() => _SpeakingCoachPageState();
}

class _SpeakingCoachPageState extends State<SpeakingCoachPage> {
  @override
  void initState() {
    super.initState();
    context.read<SpeakingCoachBloc>().add(
          SpeakingCoachAnalyzeRequested(
            transcript: widget.transcript,
            prompt: widget.prompt,
            learnerLevel: widget.learnerLevel,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Speaking Coach'),
      ),
      body: BlocBuilder<SpeakingCoachBloc, SpeakingCoachState>(
        builder: (context, state) {
          if (state is SpeakingCoachLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SpeakingCoachError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SpeakingCoachBloc>().add(
                              SpeakingCoachAnalyzeRequested(
                                transcript: widget.transcript,
                                prompt: widget.prompt,
                                learnerLevel: widget.learnerLevel,
                              ),
                            );
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! SpeakingCoachLoaded) {
            return const SizedBox.shrink();
          }

          final data = state.feedback;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF7FAFC), Color(0xFFE6F0FF)],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overall Band: ${data.overallBand.toStringAsFixed(1)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(data.summary),
                      const SizedBox(height: 12),
                      _ScoreRow(label: 'Fluency', value: data.fluency),
                      _ScoreRow(label: 'Grammar', value: data.grammar),
                      _ScoreRow(label: 'Vocabulary', value: data.vocabulary),
                      _ScoreRow(
                          label: 'Pronunciation', value: data.pronunciation),
                    ],
                  ),
                ),
                _Card(
                  title: 'Strengths',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.strengths
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('• $item'),
                            ))
                        .toList(),
                  ),
                ),
                _Card(
                  title: 'Priority Focus',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.priorities
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('• $item'),
                            ))
                        .toList(),
                  ),
                ),
                _Card(
                  title: 'Corrections',
                  child: Column(
                    children: data.corrections
                        .map((item) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Original: ${item.original}'),
                                  const SizedBox(height: 4),
                                  Text('Corrected: ${item.corrected}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('Why: ${item.reason}'),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
                _Card(
                  title: 'Daily Drills',
                  child: Column(
                    children: data.drills
                        .map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.title),
                              subtitle: Text(item.instruction),
                              trailing: Text('${item.durationMinutes}m'),
                            ))
                        .toList(),
                  ),
                ),
                _Card(
                  title: '7-Day Plan',
                  child: Column(
                    children: data.weeklyPlan
                        .map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.day),
                              subtitle: Text('${item.focus}: ${item.task}'),
                            ))
                        .toList(),
                  ),
                ),
                _Card(
                  title: 'Next Prompt',
                  child: Text(data.nextPrompt),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String? title;
  final Widget child;

  const _Card({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double value;

  const _ScoreRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(value.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: (value / 10).clamp(0.0, 1.0)),
        ],
      ),
    );
  }
}
